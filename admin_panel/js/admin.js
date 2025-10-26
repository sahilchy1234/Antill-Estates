// Firebase Configuration
const firebaseConfig = {
    apiKey: "AIzaSyCBqNmTAt3P53K8Eda32mPOwc8iBcxIaM0", // Replace with your Firebase config
    authDomain: "antella-estates.firebaseapp.com",
    projectId: "antella-estates",
    storageBucket: "antella-estates.firebasestorage.app",
    messagingSenderId: "683844877826",
    appId: "1:683844877826:web:50562580498159173eb11b"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();
const functions = firebase.functions();
const storage = firebase.storage();

// Admin Panel State
let notifications = [];
let projects = [];
let stats = {
    totalNotifications: 0,
    activeUsers: 0,
    sentToday: 0,
    successRate: 0
};
let projectStats = {
    totalProjects: 0,
    activeProjects: 0,
    upcomingProjects: 0,
    completedProjects: 0
};

// Initialize the admin panel
document.addEventListener('DOMContentLoaded', function() {
    console.log('Admin panel initializing...');
    initializeAdminPanel();
    setupEventListeners();
    loadNotifications();
    loadStats();
    loadProjects();
    loadProjectStats();
    setupImageUpload();
    console.log('Admin panel initialization complete');
});

// Initialize admin panel
function initializeAdminPanel() {
    console.log('Admin Panel Initialized');
    
    // Check if user is authenticated (you can implement proper auth later)
    const isAuthenticated = localStorage.getItem('admin_authenticated') === 'true';
    
    if (!isAuthenticated) {
        // For demo purposes, auto-authenticate
        localStorage.setItem('admin_authenticated', 'true');
    }
}

// Setup event listeners
function setupEventListeners() {
    // Notification form submission
    document.getElementById('notificationForm').addEventListener('submit', handleSendNotification);
    
    // Project form submission
    document.getElementById('projectForm').addEventListener('submit', handleAddProject);
    
    // Schedule notification checkbox
    document.getElementById('scheduleNotification').addEventListener('change', function() {
        const scheduleSection = document.getElementById('scheduleSection');
        scheduleSection.style.display = this.checked ? 'block' : 'none';
    });
    
    // Tab change events using Bootstrap's proper event handling
    document.getElementById('projects-tab').addEventListener('shown.bs.tab', function() {
        console.log('Projects tab shown, loading data...');
        loadProjects();
        loadProjectStats();
    });
    
    document.getElementById('analytics-tab').addEventListener('shown.bs.tab', function() {
        console.log('Analytics tab shown, loading data...');
        loadAnalytics();
    });
    
    // Also load projects data on initial load
    document.addEventListener('DOMContentLoaded', function() {
        // Load projects data immediately
        loadProjects();
        loadProjectStats();
    });
}

// Handle send notification
async function handleSendNotification(e) {
    e.preventDefault();
    
    const formData = {
        title: document.getElementById('title').value,
        body: document.getElementById('body').value,
        type: document.getElementById('type').value,
        target: document.getElementById('target').value,
        priority: document.getElementById('priority').value,
        imageUrl: document.getElementById('imageUrl').value,
        actionUrl: document.getElementById('actionUrl').value,
        propertyId: document.getElementById('propertyId').value,
        userId: document.getElementById('userId').value,
        scheduled: document.getElementById('scheduleNotification').checked,
        scheduleTime: document.getElementById('scheduleTime').value
    };
    
    // Validate form
    if (!formData.title || !formData.body || !formData.type || !formData.target) {
        showAlert('Please fill in all required fields', 'danger');
        return;
    }
    
    // Show loading modal
    const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
    loadingModal.show();
    
    try {
        // Simulate sending notification (replace with actual Firebase Function call)
        await sendNotificationToFirebase(formData);
        
        // Add to local notifications list
        const notification = {
            id: Date.now(),
            ...formData,
            timestamp: new Date().toISOString(),
            status: 'sent',
            sentCount: Math.floor(Math.random() * 1000) + 100 // Simulated
        };
        
        notifications.unshift(notification);
        updateNotificationsList();
        updateStats();
        
        // Reset form
        document.getElementById('notificationForm').reset();
        document.getElementById('scheduleSection').style.display = 'none';
        
        loadingModal.hide();
        showAlert('Notification sent successfully!', 'success');
        
    } catch (error) {
        console.error('Error sending notification:', error);
        loadingModal.hide();
        showAlert('Failed to send notification. Please try again.', 'danger');
    }
}

// Send notification to Firebase (real implementation)
async function sendNotificationToFirebase(data) {
    try {
        // Use HTTP endpoint instead of callable function
        const response = await fetch('https://us-central1-antella-estates.cloudfunctions.net/sendNotificationHTTP', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            console.log('Notification sent to Firebase:', result);
            return result;
        } else {
            throw new Error(result.error || 'HTTP request failed');
        }
    } catch (error) {
        console.error('Error sending notification:', error);
        throw error;
    }
}

// Load notifications from Firebase
async function loadNotifications() {
    try {
        // Load real notifications from Firebase
        const getRecentNotifications = functions.httpsCallable('getRecentNotifications');
        const result = await getRecentNotifications({ limit: 20 });
        
        notifications = result.data.notifications || [];
        updateNotificationsList();
        
    } catch (error) {
        console.error('Error loading notifications:', error);
        showAlert('Failed to load notifications', 'danger');
    }
}

// Update notifications list
function updateNotificationsList() {
    const container = document.getElementById('notificationsList');
    
    if (notifications.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-bell-slash fa-3x mb-3"></i>
                <p>No notifications sent yet</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = notifications.map(notification => `
        <div class="notification-item">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <h6 class="mb-1 fw-bold">${notification.title}</h6>
                    <p class="mb-2 text-muted">${notification.body}</p>
                    <div class="d-flex flex-wrap gap-2">
                        <span class="badge bg-primary">${notification.type}</span>
                        <span class="badge bg-secondary">${notification.target}</span>
                        <span class="badge bg-${getPriorityColor(notification.priority)}">${notification.priority}</span>
                        <span class="badge bg-success">${notification.sentCount} sent</span>
                        ${notification.propertyId ? `<span class="badge bg-info">Property: ${notification.propertyId}</span>` : ''}
                        ${notification.userId ? `<span class="badge bg-warning">User: ${notification.userId}</span>` : ''}
                    </div>
                </div>
                <div class="text-end">
                    <small class="text-muted">${formatTimestamp(notification.timestamp)}</small>
                </div>
            </div>
        </div>
    `).join('');
}

// Load stats
async function loadStats() {
    try {
        // Load real stats from Firebase
        const getNotificationStats = functions.httpsCallable('getNotificationStats');
        const result = await getNotificationStats();
        
        stats = result.data;
        updateStats();
        
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Update stats display
function updateStats() {
    document.getElementById('totalNotifications').textContent = stats.totalNotifications;
    document.getElementById('activeUsers').textContent = stats.activeUsers.toLocaleString();
    document.getElementById('sentToday').textContent = stats.sentToday;
    document.getElementById('successRate').textContent = stats.successRate + '%';
}

// Get priority color
function getPriorityColor(priority) {
    switch (priority) {
        case 'urgent': return 'danger';
        case 'high': return 'warning';
        case 'normal': return 'info';
        default: return 'secondary';
    }
}

// Format timestamp
function formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    if (diff < 60000) { // Less than 1 minute
        return 'Just now';
    } else if (diff < 3600000) { // Less than 1 hour
        return Math.floor(diff / 60000) + ' minutes ago';
    } else if (diff < 86400000) { // Less than 1 day
        return Math.floor(diff / 3600000) + ' hours ago';
    } else {
        return date.toLocaleDateString();
    }
}

// Show alert
function showAlert(message, type) {
    const alertContainer = document.getElementById('alertContainer');
    const alertId = 'alert-' + Date.now();
    
    const alertHTML = `
        <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show" role="alert">
            <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-triangle'} me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    alertContainer.insertAdjacentHTML('beforeend', alertHTML);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        const alert = document.getElementById(alertId);
        if (alert) {
            alert.remove();
        }
    }, 5000);
}

// ==================== PROJECT MANAGEMENT FUNCTIONS ====================

// Setup image upload functionality
function setupImageUpload() {
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('projectImage');
    const previewDiv = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    
    // Click to upload
    uploadArea.addEventListener('click', () => {
        fileInput.click();
    });
    
    // File selection
    fileInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                previewImg.src = e.target.result;
                previewDiv.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    });
    
    // Drag and drop
    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', () => {
        uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            fileInput.files = files;
            const reader = new FileReader();
            reader.onload = (e) => {
                previewImg.src = e.target.result;
                previewDiv.style.display = 'block';
            };
            reader.readAsDataURL(files[0]);
        }
    });
}

// Handle add project
async function handleAddProject(e) {
    e.preventDefault();
    
    const formData = {
        title: document.getElementById('projectTitle').value,
        price: document.getElementById('projectPrice').value,
        address: document.getElementById('projectAddress').value,
        flatSize: document.getElementById('projectFlatSize').value,
        builder: document.getElementById('projectBuilder').value,
        status: document.getElementById('projectStatus').value,
        description: document.getElementById('projectDescription').value,
        launchDate: document.getElementById('projectLaunchDate').value,
        completionDate: document.getElementById('projectCompletionDate').value
    };
    
    const imageFile = document.getElementById('projectImage').files[0];
    
    if (!imageFile) {
        showAlert('Please select an image for the project', 'danger');
        return;
    }
    
    const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
    loadingModal.show();
    
    try {
        // Upload image to Firebase Storage
        const imageUrl = await uploadProjectImage(imageFile);
        
        // Add image URL to form data
        formData.imageUrl = imageUrl;
        formData.createdAt = new Date().toISOString();
        
        // Save or update project using Firebase Functions
        if (window.editingProjectId) {
            // Update existing project
            const updateUpcomingProject = functions.httpsCallable('updateUpcomingProject');
            await updateUpcomingProject({
                projectId: window.editingProjectId,
                ...formData
            });
            delete window.editingProjectId; // Clear editing state
        } else {
            // Add new project
            const addUpcomingProject = functions.httpsCallable('addUpcomingProject');
            await addUpcomingProject(formData);
        }
        
        // Refresh projects list
        await loadProjects();
        await loadProjectStats();
        
        // Reset form
        resetProjectForm();
        
        loadingModal.hide();
        showAlert('Project added successfully!', 'success');
        
    } catch (error) {
        console.error('Error adding project:', error);
        loadingModal.hide();
        showAlert('Failed to add project. Please try again.', 'danger');
    }
}

// Upload project image to Firebase Storage
async function uploadProjectImage(file) {
    // Compress image before upload
    console.log('Compressing project image before upload...');
    const compressedFile = await window.imageCompressor.compressProjectImage(file);
    
    const fileName = `projects/${Date.now()}_${compressedFile.name}`;
    const storageRef = storage.ref().child(fileName);
    
    const snapshot = await storageRef.put(compressedFile, {
        contentType: compressedFile.type,
        cacheControl: 'public, max-age=31536000'
    });
    const downloadUrl = await snapshot.ref.getDownloadURL();
    
    console.log('Compressed image uploaded successfully:', downloadUrl);
    return downloadUrl;
}

// Load projects from Firebase
async function loadProjects() {
    try {
        console.log('Loading projects...');
        
        // Try to load from Firebase Functions first
        try {
            const getUpcomingProjects = functions.httpsCallable('getUpcomingProjects');
            const result = await getUpcomingProjects({ limit: 50, status: 'all' });
            
            if (result.data && result.data.projects) {
                projects = result.data.projects;
                console.log(`Loaded ${projects.length} projects from Firebase Functions`);
                updateProjectsList();
                return;
            }
        } catch (functionsError) {
            console.log('Functions call failed, trying direct Firestore:', functionsError);
        }
        
        // Fallback: Direct Firestore query
        const projectsSnapshot = await db.collection('upcomingProjects')
            .orderBy('createdAt', 'desc')
            .get();
        
        projects = [];
        projectsSnapshot.forEach(doc => {
            projects.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        console.log(`Loaded ${projects.length} projects from Firestore`);
        updateProjectsList();
        
    } catch (error) {
        console.error('Error loading projects:', error);
        projects = [];
        
        // Show sample data for demonstration
        projects = [
            {
                id: 'sample1',
                title: 'Luxury Villa Project',
                price: '₹45 Lakh - ₹1.2 Cr',
                address: 'Near IT Park, Sector 45, Gurgaon',
                flatSize: '2BHK, 3BHK, 4BHK',
                builder: 'Luxury Developers',
                status: 'upcoming',
                description: 'Premium residential project with modern amenities and excellent connectivity.',
                imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500',
                createdAt: new Date().toISOString(),
                launchDate: '2024-03-01',
                completionDate: '2026-12-31'
            },
            {
                id: 'sample2',
                title: 'Green Valley Residency',
                price: '₹35 Lakh - ₹85 Lakh',
                address: 'Whitefield, Bangalore',
                flatSize: '1BHK, 2BHK, 3BHK',
                builder: 'Green Valley Builders',
                status: 'launched',
                description: 'Eco-friendly residential project with sustainable living features.',
                imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=500',
                createdAt: new Date(Date.now() - 86400000).toISOString(),
                launchDate: '2024-01-15',
                completionDate: '2025-08-31'
            }
        ];
        
        updateProjectsList();
        showAlert('Loaded sample projects for demonstration. Add your first project using the form above.', 'info');
    }
}

// Update projects list display
function updateProjectsList() {
    const container = document.getElementById('projectsList');
    
    if (projects.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-building fa-3x mb-3"></i>
                <p>No projects added yet</p>
                <p class="small">Add your first upcoming project using the form above</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = projects.map(project => `
        <div class="project-card card">
            <div class="row g-0">
                <div class="col-md-4">
                    <img src="${project.imageUrl}" class="project-image img-fluid rounded-start" alt="${project.title}">
                </div>
                <div class="col-md-8">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title">${project.title}</h5>
                            <span class="badge bg-${getStatusColor(project.status)}">${project.status.toUpperCase()}</span>
                        </div>
                        <p class="card-text text-muted mb-2">${project.description || 'No description available'}</p>
                        <div class="row mb-3">
                            <div class="col-6">
                                <small class="text-muted">Price:</small><br>
                                <strong class="text-primary">${project.price}</strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted">Flat Size:</small><br>
                                <strong>${project.flatSize}</strong>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-12">
                                <small class="text-muted">Address:</small><br>
                                <span>${project.address}</span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-6">
                                <small class="text-muted">Builder:</small><br>
                                <span>${project.builder}</span>
                            </div>
                            <div class="col-6">
                                <small class="text-muted">Created:</small><br>
                                <span>${formatDate(project.createdAt)}</span>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end">
                            <button class="btn btn-outline-primary action-btn" onclick="editProject('${project.id}')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-outline-danger action-btn" onclick="deleteProject('${project.id}')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

// Load project statistics
async function loadProjectStats() {
    try {
        console.log('Loading project stats...');
        
        // Try to load from Firebase Functions first
        try {
            const getProjectStats = functions.httpsCallable('getProjectStats');
            const result = await getProjectStats();
            
            if (result.data) {
                projectStats = result.data;
                console.log('Loaded project stats from Firebase Functions:', projectStats);
                updateProjectStats();
                return;
            }
        } catch (functionsError) {
            console.log('Functions call failed, trying direct Firestore:', functionsError);
        }
        
        // Fallback: Direct Firestore query
        const projectsSnapshot = await db.collection('upcomingProjects').get();
        
        projectStats.totalProjects = projectsSnapshot.size;
        projectStats.activeProjects = 0;
        projectStats.upcomingProjects = 0;
        projectStats.completedProjects = 0;
        
        projectsSnapshot.forEach(doc => {
            const status = doc.data().status;
            switch (status) {
                case 'upcoming':
                    projectStats.upcomingProjects++;
                    projectStats.activeProjects++;
                    break;
                case 'launched':
                case 'ongoing':
                    projectStats.activeProjects++;
                    break;
                case 'completed':
                    projectStats.completedProjects++;
                    break;
            }
        });
        
        console.log('Loaded project stats from Firestore:', projectStats);
        updateProjectStats();
        
    } catch (error) {
        console.error('Error loading project stats:', error);
        // Set default stats
        projectStats = {
            totalProjects: 0,
            activeProjects: 0,
            upcomingProjects: 0,
            completedProjects: 0
        };
        updateProjectStats();
    }
}

// Update project stats display
function updateProjectStats() {
    document.getElementById('totalProjects').textContent = projectStats.totalProjects;
    document.getElementById('activeProjects').textContent = projectStats.activeProjects;
    document.getElementById('upcomingProjects').textContent = projectStats.upcomingProjects;
    document.getElementById('completedProjects').textContent = projectStats.completedProjects;
}

// Get status color for badge
function getStatusColor(status) {
    switch (status) {
        case 'upcoming': return 'warning';
        case 'launched': return 'info';
        case 'ongoing': return 'primary';
        case 'completed': return 'success';
        default: return 'secondary';
    }
}

// Format date for display
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

// Edit project function
function editProject(projectId) {
    const project = projects.find(p => p.id === projectId);
    if (!project) return;
    
    // Store the project ID for updating
    window.editingProjectId = projectId;
    
    // Populate form with project data
    document.getElementById('projectTitle').value = project.title;
    document.getElementById('projectPrice').value = project.price;
    document.getElementById('projectAddress').value = project.address;
    document.getElementById('projectFlatSize').value = project.flatSize;
    document.getElementById('projectBuilder').value = project.builder;
    document.getElementById('projectStatus').value = project.status;
    document.getElementById('projectDescription').value = project.description || '';
    document.getElementById('projectLaunchDate').value = project.launchDate || '';
    document.getElementById('projectCompletionDate').value = project.completionDate || '';
    
    // Show preview if image exists
    if (project.imageUrl) {
        document.getElementById('previewImg').src = project.imageUrl;
        document.getElementById('imagePreview').style.display = 'block';
    }
    
    // Update form submit button text
    const submitBtn = document.querySelector('#projectForm button[type="submit"]');
    submitBtn.innerHTML = '<i class="fas fa-save me-2"></i>Update Project';
    
    // Scroll to form
    document.getElementById('projectForm').scrollIntoView({ behavior: 'smooth' });
    
    showAlert('Project data loaded for editing. Make changes and save.', 'info');
}

// Delete project function
async function deleteProject(projectId) {
    if (!confirm('Are you sure you want to delete this project?')) {
        return;
    }
    
    try {
        const deleteUpcomingProject = functions.httpsCallable('deleteUpcomingProject');
        await deleteUpcomingProject({ projectId });
        
        await loadProjects();
        await loadProjectStats();
        showAlert('Project deleted successfully!', 'success');
    } catch (error) {
        console.error('Error deleting project:', error);
        showAlert('Failed to delete project. Please try again.', 'danger');
    }
}

// Reset project form
function resetProjectForm() {
    document.getElementById('projectForm').reset();
    document.getElementById('imagePreview').style.display = 'none';
    document.getElementById('previewImg').src = '';
    
    // Reset editing state
    delete window.editingProjectId;
    
    // Reset submit button text
    const submitBtn = document.querySelector('#projectForm button[type="submit"]');
    submitBtn.innerHTML = '<i class="fas fa-save me-2"></i>Save Project';
}

// ==================== ANALYTICS FUNCTIONS ====================

// Load analytics data and charts
async function loadAnalytics() {
    try {
        console.log('Loading analytics data...');
        
        // Load user engagement data
        await loadUserEngagement();
        
        // Create charts
        createNotificationChart();
        createProjectChart();
        
        console.log('Analytics loaded successfully');
        
    } catch (error) {
        console.error('Error loading analytics:', error);
        // Show error message in analytics section
        const analyticsContainer = document.getElementById('analytics');
        if (analyticsContainer) {
            const errorDiv = document.createElement('div');
            errorDiv.className = 'alert alert-warning';
            errorDiv.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Failed to load analytics data. Check console for details.';
            analyticsContainer.insertBefore(errorDiv, analyticsContainer.firstChild);
        }
    }
}

// Load user engagement data
async function loadUserEngagement() {
    try {
        const usersSnapshot = await db.collection('users').get();
        const totalUsers = usersSnapshot.size;
        
        // Calculate active users today
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        let activeToday = 0;
        let newUsers = 0;
        
        usersSnapshot.forEach(doc => {
            const userData = doc.data();
            if (userData.lastActiveAt) {
                const lastActive = userData.lastActiveAt.toDate();
                if (lastActive >= today) {
                    activeToday++;
                }
                
                // New users this week
                const weekAgo = new Date();
                weekAgo.setDate(weekAgo.getDate() - 7);
                if (lastActive >= weekAgo) {
                    newUsers++;
                }
            }
        });
        
        const engagementRate = totalUsers > 0 ? Math.round((activeToday / totalUsers) * 100) : 0;
        
        // Update display
        document.getElementById('totalUsers').textContent = totalUsers.toLocaleString();
        document.getElementById('activeToday').textContent = activeToday.toLocaleString();
        document.getElementById('newUsers').textContent = newUsers.toLocaleString();
        document.getElementById('engagementRate').textContent = engagementRate + '%';
        
    } catch (error) {
        console.error('Error loading user engagement:', error);
    }
}

// Create notification chart
function createNotificationChart() {
    try {
        const chartElement = document.getElementById('notificationChart');
        if (!chartElement) {
            console.error('Notification chart element not found');
            return;
        }
        
        const ctx = chartElement.getContext('2d');
        
        // Sample data - in real implementation, this would come from Firebase
        const data = {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
                label: 'Notifications Sent',
                data: [12, 15, 18, 22, 25, 20, 28],
                borderColor: 'rgb(102, 126, 234)',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.1
            }]
        };
        
        new Chart(ctx, {
            type: 'line',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
        
        console.log('Notification chart created successfully');
    } catch (error) {
        console.error('Error creating notification chart:', error);
    }
}

// Create project chart
function createProjectChart() {
    try {
        const chartElement = document.getElementById('projectChart');
        if (!chartElement) {
            console.error('Project chart element not found');
            return;
        }
        
        const ctx = chartElement.getContext('2d');
        
        const data = {
            labels: ['Upcoming', 'Launched', 'Ongoing', 'Completed'],
            datasets: [{
                data: [
                    projectStats.upcomingProjects || 0,
                    Math.max(0, (projectStats.activeProjects || 0) - (projectStats.upcomingProjects || 0)),
                    projectStats.activeProjects || 0,
                    projectStats.completedProjects || 0
                ],
                backgroundColor: [
                    'rgba(255, 193, 7, 0.8)',
                    'rgba(13, 202, 240, 0.8)',
                    'rgba(13, 110, 253, 0.8)',
                    'rgba(25, 135, 84, 0.8)'
                ],
                borderColor: [
                    'rgba(255, 193, 7, 1)',
                    'rgba(13, 202, 240, 1)',
                    'rgba(13, 110, 253, 1)',
                    'rgba(25, 135, 84, 1)'
                ],
                borderWidth: 2
            }]
        };
        
        new Chart(ctx, {
            type: 'doughnut',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
        
        console.log('Project chart created successfully');
    } catch (error) {
        console.error('Error creating project chart:', error);
    }
}

// ==================== ENHANCED FEATURES ====================

// Real-time data updates
function startRealTimeUpdates() {
    // Set up real-time listeners for notifications
    db.collection('notifications')
        .orderBy('timestamp', 'desc')
        .limit(10)
        .onSnapshot((snapshot) => {
            const newNotifications = [];
            snapshot.forEach(doc => {
                newNotifications.push({
                    id: doc.id,
                    ...doc.data()
                });
            });
            notifications = newNotifications;
            updateNotificationsList();
            updateStats();
        });

    // Set up real-time listeners for projects
    db.collection('upcomingProjects')
        .orderBy('createdAt', 'desc')
        .onSnapshot((snapshot) => {
            const newProjects = [];
            snapshot.forEach(doc => {
                newProjects.push({
                    id: doc.id,
                    ...doc.data()
                });
            });
            projects = newProjects;
            updateProjectsList();
            loadProjectStats();
        });
}

// Advanced search functionality
function setupAdvancedSearch() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                performSearch(this.value);
            }, 300);
        });
    }
}

// Perform search across all data
function performSearch(query) {
    if (!query.trim()) {
        updateProjectsList();
        return;
    }

    const searchResults = projects.filter(project => {
        const searchFields = [
            project.title,
            project.address,
            project.builder,
            project.description,
            project.flatSize,
            project.price
        ];
        
        return searchFields.some(field => 
            field && field.toLowerCase().includes(query.toLowerCase())
        );
    });

    // Update display with search results
    const container = document.getElementById('projectsList');
    if (container) {
        if (searchResults.length === 0) {
            container.innerHTML = `
                <div class="text-center text-muted py-4">
                    <i class="fas fa-search fa-3x mb-3"></i>
                    <p>No projects found matching "${query}"</p>
                </div>
            `;
        } else {
            // Render search results
            container.innerHTML = searchResults.map(project => `
                <div class="project-card card">
                    <div class="row g-0">
                        <div class="col-md-4">
                            <img src="${project.imageUrl}" class="project-image img-fluid rounded-start" alt="${project.title}">
                        </div>
                        <div class="col-md-8">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title">${project.title}</h5>
                                    <span class="badge bg-${getStatusColor(project.status)}">${project.status.toUpperCase()}</span>
                                </div>
                                <p class="card-text text-muted mb-2">${project.description || 'No description available'}</p>
                                <div class="row mb-3">
                                    <div class="col-6">
                                        <small class="text-muted">Price:</small><br>
                                        <strong class="text-primary">${project.price}</strong>
                                    </div>
                                    <div class="col-6">
                                        <small class="text-muted">Flat Size:</small><br>
                                        <strong>${project.flatSize}</strong>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary action-btn" onclick="editProject('${project.id}')">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <button class="btn btn-outline-danger action-btn" onclick="deleteProject('${project.id}')">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `).join('');
        }
    }
}

// Bulk operations
function setupBulkOperations() {
    // Add bulk select functionality
    const projectsContainer = document.getElementById('projectsList');
    if (projectsContainer) {
        // Add bulk action buttons
        const bulkActionsHTML = `
            <div class="bulk-actions mb-3" style="display: none;">
                <div class="d-flex align-items-center gap-2">
                    <span class="text-muted">Selected: <span id="selectedCount">0</span></span>
                    <button class="btn btn-sm btn-outline-primary" onclick="bulkEditProjects()">
                        <i class="fas fa-edit"></i> Edit
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="bulkDeleteProjects()">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                    <button class="btn btn-sm btn-outline-secondary" onclick="clearSelection()">
                        <i class="fas fa-times"></i> Clear
                    </button>
                </div>
            </div>
        `;
        projectsContainer.insertAdjacentHTML('beforebegin', bulkActionsHTML);
    }
}

// Bulk edit projects
function bulkEditProjects() {
    const selectedProjects = getSelectedProjects();
    if (selectedProjects.length === 0) {
        showAlert('Please select projects to edit', 'warning');
        return;
    }
    
    // Show bulk edit modal
    showAlert(`Bulk editing ${selectedProjects.length} projects`, 'info');
}

// Bulk delete projects
async function bulkDeleteProjects() {
    const selectedProjects = getSelectedProjects();
    if (selectedProjects.length === 0) {
        showAlert('Please select projects to delete', 'warning');
        return;
    }
    
    if (!confirm(`Are you sure you want to delete ${selectedProjects.length} projects?`)) {
        return;
    }
    
    try {
        for (const projectId of selectedProjects) {
            const deleteUpcomingProject = functions.httpsCallable('deleteUpcomingProject');
            await deleteUpcomingProject({ projectId });
        }
        
        await loadProjects();
        await loadProjectStats();
        clearSelection();
        showAlert(`${selectedProjects.length} projects deleted successfully!`, 'success');
    } catch (error) {
        console.error('Error bulk deleting projects:', error);
        showAlert('Failed to delete some projects. Please try again.', 'danger');
    }
}

// Get selected projects
function getSelectedProjects() {
    const checkboxes = document.querySelectorAll('.project-checkbox:checked');
    return Array.from(checkboxes).map(cb => cb.value);
}

// Clear selection
function clearSelection() {
    document.querySelectorAll('.project-checkbox').forEach(cb => cb.checked = false);
    document.querySelector('.bulk-actions').style.display = 'none';
    document.getElementById('selectedCount').textContent = '0';
}

// Data export functionality
function exportData(format, data) {
    switch (format) {
        case 'csv':
            exportToCSV(data);
            break;
        case 'json':
            exportToJSON(data);
            break;
        case 'pdf':
            exportToPDF(data);
            break;
        default:
            showAlert('Unsupported export format', 'error');
    }
}

// Export to CSV
function exportToCSV(data) {
    if (!data || data.length === 0) {
        showAlert('No data to export', 'warning');
        return;
    }
    
    const headers = Object.keys(data[0]);
    const csvContent = [
        headers.join(','),
        ...data.map(row => headers.map(header => `"${row[header] || ''}"`).join(','))
    ].join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `export_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
}

// Export to JSON
function exportToJSON(data) {
    const jsonContent = JSON.stringify(data, null, 2);
    const blob = new Blob([jsonContent], { type: 'application/json' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `export_${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    window.URL.revokeObjectURL(url);
}

// Export to PDF (simplified)
function exportToPDF(data) {
    showAlert('PDF export feature coming soon!', 'info');
}

// Advanced filtering
function setupAdvancedFilters() {
    const filterContainer = document.createElement('div');
    filterContainer.className = 'advanced-filters mb-3';
    filterContainer.innerHTML = `
        <div class="row">
            <div class="col-md-3">
                <label class="form-label">Price Range</label>
                <select class="form-select" id="priceFilter">
                    <option value="">All Prices</option>
                    <option value="0-50">Under ₹50 Lakh</option>
                    <option value="50-100">₹50 Lakh - ₹1 Cr</option>
                    <option value="100-200">₹1 Cr - ₹2 Cr</option>
                    <option value="200+">Above ₹2 Cr</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label">Builder</label>
                <select class="form-select" id="builderFilter">
                    <option value="">All Builders</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label">Location</label>
                <input type="text" class="form-control" id="locationFilter" placeholder="Enter location">
            </div>
            <div class="col-md-3">
                <label class="form-label">Date Range</label>
                <select class="form-select" id="dateFilter">
                    <option value="">All Time</option>
                    <option value="7">Last 7 days</option>
                    <option value="30">Last 30 days</option>
                    <option value="90">Last 90 days</option>
                </select>
            </div>
        </div>
    `;
    
    // Insert filters before projects list
    const projectsList = document.getElementById('projectsList');
    if (projectsList) {
        projectsList.parentNode.insertBefore(filterContainer, projectsList);
    }
}

// Apply advanced filters
function applyAdvancedFilters() {
    const priceFilter = document.getElementById('priceFilter')?.value;
    const builderFilter = document.getElementById('builderFilter')?.value;
    const locationFilter = document.getElementById('locationFilter')?.value;
    const dateFilter = document.getElementById('dateFilter')?.value;
    
    let filteredProjects = [...projects];
    
    // Apply price filter
    if (priceFilter) {
        filteredProjects = filteredProjects.filter(project => {
            const price = project.price;
            const numericPrice = parseFloat(price.replace(/[^\d]/g, ''));
            
            switch (priceFilter) {
                case '0-50':
                    return numericPrice < 50;
                case '50-100':
                    return numericPrice >= 50 && numericPrice < 100;
                case '100-200':
                    return numericPrice >= 100 && numericPrice < 200;
                case '200+':
                    return numericPrice >= 200;
                default:
                    return true;
            }
        });
    }
    
    // Apply builder filter
    if (builderFilter) {
        filteredProjects = filteredProjects.filter(project => 
            project.builder === builderFilter
        );
    }
    
    // Apply location filter
    if (locationFilter) {
        filteredProjects = filteredProjects.filter(project => 
            project.address.toLowerCase().includes(locationFilter.toLowerCase())
        );
    }
    
    // Apply date filter
    if (dateFilter) {
        const daysAgo = parseInt(dateFilter);
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - daysAgo);
        
        filteredProjects = filteredProjects.filter(project => {
            const projectDate = new Date(project.createdAt);
            return projectDate >= cutoffDate;
        });
    }
    
    // Update display
    updateProjectsDisplay(filteredProjects);
}

// Initialize enhanced features
function initializeEnhancedFeatures() {
    startRealTimeUpdates();
    setupAdvancedSearch();
    setupBulkOperations();
    setupAdvancedFilters();
    
    // Set up filter event listeners
    const filterInputs = ['priceFilter', 'builderFilter', 'locationFilter', 'dateFilter'];
    filterInputs.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('change', applyAdvancedFilters);
        }
    });
    
    // Populate builder filter
    populateBuilderFilter();
}

// Populate builder filter options
function populateBuilderFilter() {
    const builderFilter = document.getElementById('builderFilter');
    if (!builderFilter) return;
    
    const builders = [...new Set(projects.map(project => project.builder))];
    builders.forEach(builder => {
        const option = document.createElement('option');
        option.value = builder;
        option.textContent = builder;
        builderFilter.appendChild(option);
    });
}

// Enhanced project display
function updateProjectsDisplay(filteredProjects = projects) {
    const container = document.getElementById('projectsList');
    
    if (filteredProjects.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-building fa-3x mb-3"></i>
                <p>No projects found</p>
                <p class="small">Try adjusting your filters or add a new project</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = filteredProjects.map(project => `
        <div class="project-card card mb-3">
            <div class="row g-0">
                <div class="col-md-4">
                    <img src="${project.imageUrl}" class="project-image img-fluid rounded-start" alt="${project.title}">
                </div>
                <div class="col-md-8">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title">${project.title}</h5>
                            <span class="badge bg-${getStatusColor(project.status)}">${project.status.toUpperCase()}</span>
                        </div>
                        <p class="card-text text-muted mb-2">${project.description || 'No description available'}</p>
                        <div class="row mb-3">
                            <div class="col-6">
                                <small class="text-muted">Price:</small><br>
                                <strong class="text-primary">${project.price}</strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted">Flat Size:</small><br>
                                <strong>${project.flatSize}</strong>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-12">
                                <small class="text-muted">Address:</small><br>
                                <span>${project.address}</span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-6">
                                <small class="text-muted">Builder:</small><br>
                                <span>${project.builder}</span>
                            </div>
                            <div class="col-6">
                                <small class="text-muted">Created:</small><br>
                                <span>${formatDate(project.createdAt)}</span>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end">
                            <button class="btn btn-outline-primary action-btn" onclick="editProject('${project.id}')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-outline-danger action-btn" onclick="deleteProject('${project.id}')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

// Initialize enhanced features when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize enhanced features after a short delay to ensure all elements are loaded
    setTimeout(initializeEnhancedFeatures, 1000);
});

// Export functions for testing
window.adminPanel = {
    loadNotifications,
    loadStats,
    loadProjects,
    loadProjectStats,
    sendNotificationToFirebase,
    uploadProjectImage,
    showAlert,
    resetProjectForm,
    editProject,
    deleteProject,
    // Enhanced functions
    startRealTimeUpdates,
    performSearch,
    exportData,
    applyAdvancedFilters,
    bulkEditProjects,
    bulkDeleteProjects,
    clearSelection
};
