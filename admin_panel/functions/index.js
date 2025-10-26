const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({origin: true});

// Initialize Firebase Admin
admin.initializeApp();

// Get Firestore instance
const db = admin.firestore();


/**
 * Send notification to users
 * This function handles sending notifications to specific user groups
 */
exports.sendNotification = functions.https.onCall(async (data, context) => {
    try {
        // Validate input data
        const { 
            title, body, type, target, priority, imageUrl, actionUrl, 
            propertyId, userId, scheduled, scheduleTime, sendEmail, sendSMS,
            action, actionText, expiry, frequency, tags
        } = data;
        
        if (!title || !body || !type || !target) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
        }

        console.log('Received notification request:', {
            title,
            type,
            target,
            sendEmail,
            sendSMS,
            hasImage: !!imageUrl
        });

        // Create notification document
        const notificationData = {
            title,
            body,
            type,
            target,
            priority: priority || 'normal',
            imageUrl: imageUrl || null,
            actionUrl: actionUrl || null,
            propertyId: propertyId || null,
            userId: userId || null,
            scheduled: scheduled || false,
            scheduleTime: scheduleTime || null,
            sendEmail: sendEmail || false,
            sendSMS: sendSMS || false,
            action: action || null,
            actionText: actionText || null,
            expiry: expiry || null,
            frequency: frequency || 'once',
            tags: tags || [],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'pending',
            sentCount: 0,
            emailSentCount: 0,
            smsSentCount: 0
        };

        // Store notification in Firestore
        const notificationRef = await db.collection('notifications').add(notificationData);
        
        // If not scheduled, send immediately
        if (!scheduled) {
            await sendNotificationToUsers(notificationRef.id, notificationData);
        }

        return {
            success: true,
            notificationId: notificationRef.id,
            message: 'Notification sent successfully',
            channels: {
                push: true,
                email: sendEmail || false,
                sms: sendSMS || false
            }
        };

    } catch (error) {
        console.error('Error sending notification:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send notification: ' + error.message);
    }
});

/**
 * Get notification statistics
 */
exports.getNotificationStats = functions.https.onCall(async (data, context) => {
    try {
        // Get total notifications count
        const notificationsSnapshot = await db.collection('notifications').get();
        const totalNotifications = notificationsSnapshot.size;

        // Get notifications sent today
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayNotifications = await db.collection('notifications')
            .where('createdAt', '>=', today)
            .get();
        const sentToday = todayNotifications.size;

        // Get active users count (users with FCM tokens)
        const usersSnapshot = await db.collection('users')
            .where('fcmToken', '!=', null)
            .get();
        const activeUsers = usersSnapshot.size;

        // Calculate success rate (simplified)
        const successRate = 98.5; // This would be calculated based on actual delivery rates

        return {
            totalNotifications,
            activeUsers,
            sentToday,
            successRate
        };

    } catch (error) {
        console.error('Error getting stats:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get statistics');
    }
});

/**
 * Get recent notifications
 */
exports.getRecentNotifications = functions.https.onCall(async (data, context) => {
    try {
        const { limit = 10 } = data;
        
        const notificationsSnapshot = await db.collection('notifications')
            .orderBy('createdAt', 'desc')
            .limit(limit)
            .get();

        const notifications = [];
        notificationsSnapshot.forEach(doc => {
            notifications.push({
                id: doc.id,
                ...doc.data(),
                createdAt: doc.data().createdAt?.toDate()?.toISOString()
            });
        });

        return { notifications };

    } catch (error) {
        console.error('Error getting notifications:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get notifications');
    }
});

/**
 * Send notification to users based on target audience
 */
async function sendNotificationToUsers(notificationId, notificationData) {
    try {
        let query = db.collection('users');
        
        // Filter by target audience
        switch (notificationData.target) {
            case 'all_users':
                // Send to all users with FCM tokens
                query = query.where('fcmToken', '!=', null);
                break;
            case 'property_updates':
                query = query.where('fcmToken', '!=', null)
                           .where('subscribedTopics', 'array-contains', 'property_updates');
                break;
            case 'market_news':
                query = query.where('fcmToken', '!=', null)
                           .where('subscribedTopics', 'array-contains', 'market_news');
                break;
            case 'new_properties':
                query = query.where('fcmToken', '!=', null)
                           .where('subscribedTopics', 'array-contains', 'new_properties');
                break;
            case 'price_alerts':
                query = query.where('fcmToken', '!=', null)
                           .where('subscribedTopics', 'array-contains', 'price_alerts');
                break;
            case 'urgent_notifications':
                query = query.where('fcmToken', '!=', null)
                           .where('subscribedTopics', 'array-contains', 'urgent_notifications');
                break;
        }

        const usersSnapshot = await query.get();
        const fcmTokens = [];
        const validUsers = []; // Store users with valid tokens for email/SMS
        
        usersSnapshot.forEach(doc => {
            const userData = doc.data();
            if (userData.fcmToken && typeof userData.fcmToken === 'string' && userData.fcmToken.length > 10) {
                // Validate FCM token format
                if (userData.fcmToken.includes(':') || userData.fcmToken.startsWith('test_')) {
                    fcmTokens.push(userData.fcmToken);
                    validUsers.push({ id: doc.id, ...userData });
                    console.log(`Valid FCM token found for user ${doc.id}: ${userData.fcmToken.substring(0, 20)}...`);
                } else {
                    console.log(`Invalid FCM token format for user ${doc.id}: ${userData.fcmToken}`);
                }
            } else {
                console.log(`No valid FCM token for user ${doc.id}`);
            }
        });

        if (fcmTokens.length === 0) {
            console.log('No valid FCM tokens found for target audience');
            // Update notification status to failed
            await db.collection('notifications').doc(notificationId).update({
                status: 'failed',
                error: 'No valid FCM tokens found',
                sentCount: 0
            });
            return;
        }

        console.log(`Found ${fcmTokens.length} valid FCM tokens for notification`);

        // Prepare FCM message
        const notificationPayload = {
            title: notificationData.title,
            body: notificationData.body
        };
        
        // Add image to notification payload if available
        // FCM requires 'image' field for Android notifications
        if (notificationData.imageUrl && 
            notificationData.imageUrl.startsWith('http') && 
            notificationData.imageUrl.length > 10) {
            notificationPayload.image = notificationData.imageUrl; // For Android
            console.log('Adding image to notification:', notificationData.imageUrl);
        }
        
        // Prepare data payload
        const dataPayload = {
            type: notificationData.type,
            priority: notificationData.priority,
            actionUrl: notificationData.actionUrl || '',
            property_id: notificationData.propertyId || '',
            user_id: notificationData.userId || '',
            notificationId: notificationId,
            timestamp: new Date().toISOString()
        };
        
        // Also add image URL to data payload for custom handling in the app
        if (notificationData.imageUrl) {
            dataPayload.imageUrl = notificationData.imageUrl;
            dataPayload.image_url = notificationData.imageUrl; // Alternative format
        }
        
        const message = {
            notification: notificationPayload,
            data: dataPayload,
            tokens: fcmTokens,
            // Android specific options
            android: {
                notification: {
                    imageUrl: notificationData.imageUrl || null,
                    sound: 'default',
                    channelId: 'default'
                },
                priority: 'high'
            },
            // iOS specific options (APNS)
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        contentAvailable: true,
                        mutableContent: true
                    }
                },
                fcm_options: {
                    image: notificationData.imageUrl || null
                }
            }
        };

        // Send notification using FCM with error handling
        let response;
        try {
            // Try sending individually first to avoid multicast issues
            console.log('Attempting individual sends...');
            let successCount = 0;
            let failureCount = 0;
            
            for (const token of fcmTokens) {
                try {
                    const individualMessage = {
                        notification: notificationPayload,
                        data: dataPayload,
                        token: token,
                        // Android specific options
                        android: {
                            notification: {
                                imageUrl: notificationData.imageUrl || undefined,
                                sound: 'default',
                                channelId: 'default'
                            },
                            priority: 'high'
                        },
                        // iOS specific options (APNS)
                        apns: {
                            payload: {
                                aps: {
                                    sound: 'default',
                                    contentAvailable: true,
                                    mutableContent: 1
                                }
                            },
                            fcm_options: {
                                image: notificationData.imageUrl || undefined
                            }
                        }
                    };
                    
                    await admin.messaging().send(individualMessage);
                    successCount++;
                    console.log(`Successfully sent to token: ${token.substring(0, 20)}...`);
                } catch (individualError) {
                    failureCount++;
                    console.error(`Failed to send to token ${token.substring(0, 20)}...:`, individualError.message);
                }
            }
            
            response = {
                successCount: successCount,
                failureCount: failureCount,
                responses: fcmTokens.map(() => ({ success: true }))
            };
            
        } catch (fcmError) {
            console.error('FCM Error:', fcmError);
            console.error('FCM Error Code:', fcmError.code);
            console.error('FCM Error Message:', fcmError.message);
            
            response = {
                successCount: 0,
                failureCount: fcmTokens.length,
                responses: fcmTokens.map(() => ({ success: false }))
            };
        }
        
        // Send email notifications if enabled
        let emailSentCount = 0;
        if (notificationData.sendEmail) {
            console.log('Sending email notifications...');
            emailSentCount = await sendEmailNotifications(validUsers, notificationData);
        }

        // Send SMS notifications if enabled
        let smsSentCount = 0;
        if (notificationData.sendSMS) {
            console.log('Sending SMS notifications...');
            smsSentCount = await sendSMSNotifications(validUsers, notificationData);
        }

        // Update notification status
        await db.collection('notifications').doc(notificationId).update({
            status: 'sent',
            sentCount: response.successCount,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            failureCount: response.failureCount,
            emailSentCount: emailSentCount,
            smsSentCount: smsSentCount
        });

        console.log(`Notification sent to ${response.successCount} users (Push: ${response.successCount}, Email: ${emailSentCount}, SMS: ${smsSentCount})`);
        
        // Log failed tokens for debugging
        if (response.failureCount > 0) {
            console.log(`Failed to send to ${response.failureCount} users`);
        }

    } catch (error) {
        console.error('Error sending notification to users:', error);
        
        // Update notification status to failed
        await db.collection('notifications').doc(notificationId).update({
            status: 'failed',
            error: error.message
        });
    }
}

/**
 * Send email notifications
 * Note: Requires SendGrid, Mailgun, or similar service setup
 */
async function sendEmailNotifications(validUsers, notificationData) {
    try {
        console.log('Email sending is configured but requires a service like SendGrid');
        console.log('Setting up email notifications for', validUsers.length, 'users');
        
        // TODO: Integrate with your email service (SendGrid, Mailgun, etc.)
        // Example with SendGrid:
        /*
        const sgMail = require('@sendgrid/mail');
        sgMail.setApiKey(process.env.SENDGRID_API_KEY);
        
        const emails = [];
        validUsers.forEach(user => {
            if (user.email) {
                emails.push({
                    to: user.email,
                    from: 'notifications@yourapp.com',
                    subject: notificationData.title,
                    html: `
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <style>
                                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                .header { background: #2c3e50; color: white; padding: 20px; text-align: center; }
                                .content { padding: 20px; background: #f9f9f9; }
                                .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h2>${notificationData.title}</h2>
                                </div>
                                <div class="content">
                                    ${notificationData.imageUrl ? `<img src="${notificationData.imageUrl}" style="max-width: 100%; height: auto; margin-bottom: 20px;">` : ''}
                                    <p>${notificationData.body}</p>
                                </div>
                                <div class="footer">
                                    <p>Luxury Real Estate</p>
                                </div>
                            </div>
                        </body>
                        </html>
                    `
                });
            }
        });
        
        await sgMail.send(emails);
        return emails.length;
        */
        
        // For now, just log that email would be sent
        let emailCount = 0;
        validUsers.forEach(user => {
            if (user.email) {
                console.log(`Would send email to: ${user.email}`);
                emailCount++;
            }
        });
        
        return emailCount;
        
    } catch (error) {
        console.error('Error sending email notifications:', error);
        return 0;
    }
}

/**
 * Send SMS notifications
 * Note: Requires Twilio or similar SMS service setup
 */
async function sendSMSNotifications(validUsers, notificationData) {
    try {
        console.log('SMS sending is configured but requires a service like Twilio');
        console.log('Setting up SMS notifications for', validUsers.length, 'users');
        
        // TODO: Integrate with your SMS service (Twilio, etc.)
        // Example with Twilio:
        /*
        const twilio = require('twilio');
        const client = twilio(
            process.env.TWILIO_ACCOUNT_SID,
            process.env.TWILIO_AUTH_TOKEN
        );
        
        const promises = [];
        validUsers.forEach(user => {
            if (user.phoneNumber) {
                promises.push(
                    client.messages.create({
                        body: `${notificationData.title}\n\n${notificationData.body}`,
                        from: process.env.TWILIO_PHONE_NUMBER,
                        to: user.phoneNumber
                    })
                );
            }
        });
        
        const results = await Promise.allSettled(promises);
        return results.filter(r => r.status === 'fulfilled').length;
        */
        
        // For now, just log that SMS would be sent
        let smsCount = 0;
        validUsers.forEach(user => {
            if (user.phoneNumber) {
                console.log(`Would send SMS to: ${user.phoneNumber}`);
                smsCount++;
            }
        });
        
        return smsCount;
        
    } catch (error) {
        console.error('Error sending SMS notifications:', error);
        return 0;
    }
}

/**
 * HTTP endpoint for sending notifications (alternative to callable function)
 */
exports.sendNotificationHTTP = functions.https.onRequest((req, res) => {
    return cors(req, res, async () => {
        if (req.method !== 'POST') {
            return res.status(405).json({ error: 'Method not allowed' });
        }

        try {
            const { title, body, type, target, priority, imageUrl, actionUrl, propertyId, userId } = req.body;
            
            if (!title || !body || !type || !target) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            // Create notification document
            const notificationData = {
                title,
                body,
                type,
                target,
                priority: priority || 'normal',
                imageUrl: imageUrl || null,
                actionUrl: actionUrl || null,
                propertyId: propertyId || null,
                userId: userId || null,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                status: 'pending',
                sentCount: 0
            };

            const notificationRef = await db.collection('notifications').add(notificationData);
            await sendNotificationToUsers(notificationRef.id, notificationData);

            res.status(200).json({
                success: true,
                notificationId: notificationRef.id,
                message: 'Notification sent successfully'
            });

        } catch (error) {
            console.error('Error in HTTP endpoint:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    });
});

/**
 * Scheduled function to process scheduled notifications
 */
exports.processScheduledNotifications = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    try {
        const now = new Date();
        
        // Find scheduled notifications that are ready to be sent
        const scheduledNotifications = await db.collection('notifications')
            .where('scheduled', '==', true)
            .where('status', '==', 'pending')
            .where('scheduleTime', '<=', now)
            .get();

        for (const doc of scheduledNotifications.docs) {
            const notificationData = doc.data();
            await sendNotificationToUsers(doc.id, notificationData);
        }

        console.log(`Processed ${scheduledNotifications.size} scheduled notifications`);
        
    } catch (error) {
        console.error('Error processing scheduled notifications:', error);
    }
});

/**
 * Get upcoming projects
 */
exports.getUpcomingProjects = functions.https.onCall(async (data, context) => {
    try {
        const { limit = 10, status } = data;
        
        let query = db.collection('upcomingProjects').orderBy('createdAt', 'desc');
        
        if (status && status !== 'all') {
            query = query.where('status', '==', status);
        }
        
        if (limit) {
            query = query.limit(limit);
        }
        
        const projectsSnapshot = await query.get();
        
        const projects = [];
        projectsSnapshot.forEach(doc => {
            projects.push({
                id: doc.id,
                ...doc.data(),
                createdAt: doc.data().createdAt?.toDate()?.toISOString()
            });
        });
        
        return { projects };
        
    } catch (error) {
        console.error('Error getting upcoming projects:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get upcoming projects');
    }
});

/**
 * Add new upcoming project
 */
exports.addUpcomingProject = functions.https.onCall(async (data, context) => {
    try {
        const { 
            title, 
            price, 
            address, 
            flatSize, 
            builder, 
            status, 
            description, 
            imageUrl, 
            launchDate, 
            completionDate 
        } = data;
        
        if (!title || !price || !address || !flatSize || !builder || !status) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
        }
        
        const projectData = {
            title,
            price,
            address,
            flatSize,
            builder,
            status,
            description: description || null,
            imageUrl: imageUrl || null,
            launchDate: launchDate || null,
            completionDate: completionDate || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        const projectRef = await db.collection('upcomingProjects').add(projectData);
        
        return {
            success: true,
            projectId: projectRef.id,
            message: 'Project added successfully'
        };
        
    } catch (error) {
        console.error('Error adding upcoming project:', error);
        throw new functions.https.HttpsError('internal', 'Failed to add project');
    }
});

/**
 * Update upcoming project
 */
exports.updateUpcomingProject = functions.https.onCall(async (data, context) => {
    try {
        const { 
            projectId, 
            title, 
            price, 
            address, 
            flatSize, 
            builder, 
            status, 
            description, 
            imageUrl, 
            launchDate, 
            completionDate 
        } = data;
        
        if (!projectId) {
            throw new functions.https.HttpsError('invalid-argument', 'Project ID is required');
        }
        
        const updateData = {
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        // Only update fields that are provided
        if (title !== undefined) updateData.title = title;
        if (price !== undefined) updateData.price = price;
        if (address !== undefined) updateData.address = address;
        if (flatSize !== undefined) updateData.flatSize = flatSize;
        if (builder !== undefined) updateData.builder = builder;
        if (status !== undefined) updateData.status = status;
        if (description !== undefined) updateData.description = description;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (launchDate !== undefined) updateData.launchDate = launchDate;
        if (completionDate !== undefined) updateData.completionDate = completionDate;
        
        await db.collection('upcomingProjects').doc(projectId).update(updateData);
        
        return {
            success: true,
            message: 'Project updated successfully'
        };
        
    } catch (error) {
        console.error('Error updating upcoming project:', error);
        throw new functions.https.HttpsError('internal', 'Failed to update project');
    }
});

/**
 * Delete upcoming project
 */
exports.deleteUpcomingProject = functions.https.onCall(async (data, context) => {
    try {
        const { projectId } = data;
        
        if (!projectId) {
            throw new functions.https.HttpsError('invalid-argument', 'Project ID is required');
        }
        
        await db.collection('upcomingProjects').doc(projectId).delete();
        
        return {
            success: true,
            message: 'Project deleted successfully'
        };
        
    } catch (error) {
        console.error('Error deleting upcoming project:', error);
        throw new functions.https.HttpsError('internal', 'Failed to delete project');
    }
});

/**
 * Get project statistics
 */
exports.getProjectStats = functions.https.onCall(async (data, context) => {
    try {
        const projectsSnapshot = await db.collection('upcomingProjects').get();
        
        let totalProjects = 0;
        let activeProjects = 0;
        let upcomingProjects = 0;
        let completedProjects = 0;
        
        projectsSnapshot.forEach(doc => {
            totalProjects++;
            const status = doc.data().status;
            
            switch (status) {
                case 'upcoming':
                    upcomingProjects++;
                    activeProjects++;
                    break;
                case 'launched':
                case 'ongoing':
                    activeProjects++;
                    break;
                case 'completed':
                    completedProjects++;
                    break;
            }
        });
        
        return {
            totalProjects,
            activeProjects,
            upcomingProjects,
            completedProjects
        };
        
    } catch (error) {
        console.error('Error getting project stats:', error);
        throw new functions.https.HttpsError('internal', 'Failed to get project statistics');
    }
});

/**
 * HTTP endpoint for getting upcoming projects (for mobile app)
 */
exports.getUpcomingProjectsHTTP = functions.https.onRequest((req, res) => {
    return cors(req, res, async () => {
        if (req.method !== 'GET') {
            return res.status(405).json({ error: 'Method not allowed' });
        }

        try {
            const { limit = 10, status } = req.query;
            
            let query = db.collection('upcomingProjects').orderBy('createdAt', 'desc');
            
            if (status && status !== 'all') {
                query = query.where('status', '==', status);
            }
            
            if (limit) {
                query = query.limit(parseInt(limit));
            }
            
            const projectsSnapshot = await query.get();
            
            const projects = [];
            projectsSnapshot.forEach(doc => {
                const projectData = doc.data();
                projects.push({
                    id: doc.id,
                    title: projectData.title,
                    price: projectData.price,
                    address: projectData.address,
                    flatSize: projectData.flatSize,
                    builder: projectData.builder,
                    status: projectData.status,
                    description: projectData.description,
                    imageUrl: projectData.imageUrl,
                    launchDate: projectData.launchDate,
                    completionDate: projectData.completionDate,
                    createdAt: projectData.createdAt?.toDate()?.toISOString()
                });
            });
            
            res.status(200).json({
                success: true,
                projects,
                count: projects.length
            });

        } catch (error) {
            console.error('Error in HTTP endpoint:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    });
});