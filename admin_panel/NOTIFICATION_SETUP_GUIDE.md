# Notification System Setup Guide

## ✅ Current Status

Your notification system is **fully functional** with the following features working:

### Working Features:
- ✅ **Push Notifications** - Fully working via Firebase Cloud Messaging
- ✅ **Image Attachments** - Images upload and display in notifications
- ✅ **Confirmation Dialog** - Shows before sending notifications
- ✅ **Scheduled Notifications** - Can schedule for future delivery
- ✅ **Multiple Delivery Channels** - Email and SMS ready (need service setup)
- ✅ **Preview Function** - Preview notifications before sending
- ✅ **Templates** - Pre-configured notification templates
- ✅ **Analytics** - Track sent/read/failed notifications
- ✅ **Custom Actions** - Add buttons to notifications
- ✅ **Priority Levels** - Urgent, Important, Normal
- ✅ **Frequency Control** - Send once, daily, or weekly

---

## 📱 Push Notification with Images - WORKING!

Your push notifications **now support images** on both Android and iOS devices.

### What Was Fixed:

1. **Image Upload** - ✅ Working
   - Images upload to Firebase Storage
   - Progress bar shows upload status
   - Preview shows before sending

2. **FCM Payload** - ✅ Updated
   - Android: Uses `notification.image` field
   - iOS: Uses `apns.fcm_options.image` field
   - Data payload includes `imageUrl` for custom handling

3. **Platform Support:**
   - **Android:** Images show in expanded notification
   - **iOS:** Images show with mutable content enabled

### How It Works Now:

```javascript
// Admin uploads image → Firebase Storage
// ↓
// Image URL added to FCM message:
{
  notification: {
    title: "...",
    body: "...",
    image: "https://storage.googleapis.com/..."  // Android
  },
  android: {
    notification: {
      imageUrl: "..."  // Android fallback
    }
  },
  apns: {
    fcm_options: {
      image: "..."  // iOS
    }
  }
}
```

---

## 📧 Email Notifications Setup (Optional)

Email notifications are **configured but require a service integration**.

### Option 1: SendGrid (Recommended)

1. **Install SendGrid:**
```bash
cd admin_panel/functions
npm install @sendgrid/mail
```

2. **Get API Key:**
   - Sign up at https://sendgrid.com
   - Get API key from Settings > API Keys
   - Free tier: 100 emails/day

3. **Set Environment Variable:**
```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
```

4. **Uncomment Email Code:**
   - Open `admin_panel/functions/index.js`
   - Find `sendEmailNotifications` function
   - Uncomment the SendGrid integration code (lines ~405-448)

### Option 2: Mailgun

1. **Install Mailgun:**
```bash
cd admin_panel/functions
npm install mailgun-js
```

2. **Configure:**
```javascript
const mailgun = require('mailgun-js')({
    apiKey: process.env.MAILGUN_API_KEY,
    domain: process.env.MAILGUN_DOMAIN
});
```

### Option 3: NodeMailer (Gmail)

1. **Install:**
```bash
cd admin_panel/functions
npm install nodemailer
```

2. **Configure:**
```javascript
const nodemailer = require('nodemailer');
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'your-email@gmail.com',
        pass: 'your-app-password'
    }
});
```

---

## 📱 SMS Notifications Setup (Premium Feature)

SMS notifications are **configured but require Twilio or similar service**.

### Option 1: Twilio (Recommended)

1. **Install Twilio:**
```bash
cd admin_panel/functions
npm install twilio
```

2. **Get Credentials:**
   - Sign up at https://www.twilio.com
   - Get Account SID and Auth Token
   - Get a Twilio phone number
   - Free trial: $15 credit

3. **Set Environment Variables:**
```bash
firebase functions:config:set twilio.sid="YOUR_ACCOUNT_SID"
firebase functions:config:set twilio.token="YOUR_AUTH_TOKEN"
firebase functions:config:set twilio.phone="+1234567890"
```

4. **Uncomment SMS Code:**
   - Open `admin_panel/functions/index.js`
   - Find `sendSMSNotifications` function
   - Uncomment the Twilio integration code (lines ~479-500)

### Option 2: AWS SNS

```javascript
const AWS = require('aws-sdk');
const sns = new AWS.SNS({
    region: 'us-east-1',
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_KEY
});
```

---

## 🚀 Deploying Firebase Functions

After making changes to `functions/index.js`:

### Windows:
```bash
cd admin_panel/functions
npm install
cd ..
deploy_admin_functions.bat
```

### Linux/Mac:
```bash
cd admin_panel/functions
npm install
cd ..
./deploy_admin_functions.sh
```

### Manual Deployment:
```bash
firebase deploy --only functions
```

---

## 🧪 Testing Notifications

### Test Push Notification with Image:

1. Open admin panel → Notifications
2. Click "Send Notification"
3. Fill in:
   - Title: "Test Notification"
   - Message: "Testing image support"
   - Type: Property
   - Priority: Normal
   - Recipients: all_users
4. Upload an image (PNG/JPG, < 5MB)
5. Check "Require user confirmation"
6. Click "Send Notification"
7. Review confirmation dialog
8. Click "Yes, Send Notification"
9. Check your mobile device

### Expected Result:
- ✅ Notification appears on device
- ✅ Image shows in expanded view (Android)
- ✅ Image shows in notification (iOS)

---

## 🔍 Troubleshooting

### Image Not Showing on Mobile?

**Check Console Logs:**
```
✅ Image uploaded successfully!
Download URL: https://firebasestorage...
✅ Image uploaded and attached to notification
Adding image to notification: https://...
Successfully sent to token: ...
```

**If image uploads but doesn't show:**

1. **Android:** Make sure app has notification channel configured
2. **iOS:** Ensure APNS certificate is set up correctly
3. **Both:** Check internet connection on device
4. **Firestore:** Verify imageUrl is saved in notification document

**Check Flutter App:**
The app might need to handle the image from the notification data:

```dart
// In your Flutter notification handler
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final imageUrl = message.notification?.android?.imageUrl ??
                   message.data['imageUrl'] ??
                   message.data['image_url'];
  
  // Display notification with image
  showNotificationWithImage(
    title: message.notification!.title!,
    body: message.notification!.body!,
    imageUrl: imageUrl,
  );
});
```

### Email Not Sending?

1. Email service not configured (expected)
2. Check console logs: "Would send email to: ..."
3. Follow setup steps above to integrate SendGrid

### SMS Not Sending?

1. SMS service not configured (expected)
2. Check console logs: "Would send SMS to: ..."
3. Follow setup steps above to integrate Twilio

---

## 📊 Monitoring

### View Logs:
```bash
firebase functions:log
```

### Real-time Logs:
```bash
firebase functions:log --only sendNotification
```

### Check Firestore:
1. Firebase Console → Firestore
2. Check `notifications` collection
3. Look for:
   - `sentCount` (push notifications)
   - `emailSentCount` (emails)
   - `smsSentCount` (SMS)

---

## 💡 Best Practices

1. **Always use confirmation** for mass notifications
2. **Test with small groups** before sending to all users
3. **Monitor costs** for SMS (premium feature)
4. **Use templates** for consistency
5. **Schedule important** notifications for optimal times
6. **Include images** to increase engagement (working!)
7. **Set expiry dates** for time-sensitive notifications

---

## 📝 Next Steps

### To Enable Email:
1. Choose email service (SendGrid recommended)
2. Sign up and get API key
3. Install npm package
4. Set Firebase config
5. Uncomment email code in `functions/index.js`
6. Deploy functions
7. Test!

### To Enable SMS:
1. Choose SMS service (Twilio recommended)
2. Sign up and get credentials
3. Install npm package
4. Set Firebase config
5. Uncomment SMS code in `functions/index.js`
6. Deploy functions
7. Test!

---

## ✅ Summary

**Currently Working:**
- ✅ Push notifications with images
- ✅ Image upload to Firebase Storage
- ✅ Confirmation dialogs
- ✅ Scheduled notifications
- ✅ Preview functionality
- ✅ All notification features

**Ready to Enable:**
- 📧 Email notifications (needs service setup)
- 📱 SMS notifications (needs service setup)

**Your notification system is production-ready for push notifications with images!** 🎉

Email and SMS are ready to be enabled when you choose a service provider.

