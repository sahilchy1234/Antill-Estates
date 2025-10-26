// Firebase Configuration
const firebaseConfig = {
    apiKey: "AIzaSyCBqNmTAt3P53K8Eda32mPOwc8iBcxIaM0",
    authDomain: "antella-estates.firebaseapp.com",
    projectId: "antella-estates",
    storageBucket: "antella-estates.firebasestorage.app",
    messagingSenderId: "683844877826",
    appId: "1:683844877826:web:50562580498159173eb11b"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();

// State management
let users = [];
let filteredUsers = [];
let currentPage = 1;
const usersPerPage = 20;
let selectedUserId = null;

// Stats
let stats = {
    totalUsers: 0,
    activeUsers: 0,
    inactiveUsers: 0,
    newUsersThisMonth: 0
};

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('Users Admin Panel initializing...');
    setupEventListeners();
    loadUsers();
    loadStats();
});

// Setup event listeners
function setupEventListeners() {
    // Search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                applyFilters();
            }, 300);
        });
    }

    // Filter functionality
    ['statusFilter', 'profileFilter', 'sortFilter'].forEach(filterId => {
        const element = document.getElementById(filterId);
        if (element) {
            element.addEventListener('change', applyFilters);
        }
    });
}

// Load users from Firestore
async function loadUsers() {
    try {
        console.log('Loading users...');
        showTableLoading(true);
        
        const querySnapshot = await db.collection('users')
            .orderBy('createdAt', 'desc')
            .get();
        
        users = [];
        querySnapshot.forEach(doc => {
            const data = doc.data();
            users.push({
                id: doc.id,
                fullName: data.fullName || 'Unknown',
                email: data.email || '',
                phoneNumber: data.phoneNumber || '',
                phoneNumber2: data.phoneNumber2 || '',
                isRealEstateAgent: data.isRealEstateAgent || false,
                isActive: data.isActive !== undefined ? data.isActive : true,
                profileImageUrl: data.profileImageUrl || '',
                profileCompleted: data.profileCompleted || false,
                aboutMe: data.aboutMe || '',
                whatAreYouHere: data.whatAreYouHere || '',
                createdAt: data.createdAt,
                updatedAt: data.updatedAt,
                lastActiveAt: data.lastActiveAt || data.lastActive,
                fcmToken: data.fcmToken || '',
                subscribedTopics: data.subscribedTopics || [],
                notificationPreferences: data.notificationPreferences || {}
            });
        });
        
        console.log(`Loaded ${users.length} users`);
        filteredUsers = [...users];
        applyFilters();
        
    } catch (error) {
        console.error('Error loading users:', error);
        showAlert('Failed to load users. Please refresh the page.', 'danger');
        showTableLoading(false);
        
        // Show sample data for demonstration
        users = getSampleUsers();
        filteredUsers = [...users];
        displayUsers();
        updatePagination();
    }
}

// Load statistics
async function loadStats() {
    try {
        console.log('Loading user statistics...');
        
        const querySnapshot = await db.collection('users').get();
        
        stats.totalUsers = querySnapshot.size;
        stats.activeUsers = 0;
        stats.inactiveUsers = 0;
        stats.newUsersThisMonth = 0;
        
        const now = new Date();
        const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        
        querySnapshot.forEach(doc => {
            const data = doc.data();
            
            // Count active/inactive users
            if (data.isActive !== false) {
                stats.activeUsers++;
            } else {
                stats.inactiveUsers++;
            }
            
            // Count new users this month
            if (data.createdAt) {
                const createdDate = data.createdAt.toDate();
                if (createdDate >= firstDayOfMonth) {
                    stats.newUsersThisMonth++;
                }
            }
        });
        
        updateStatsDisplay();
        
    } catch (error) {
        console.error('Error loading statistics:', error);
        // Use sample stats
        stats = {
            totalUsers: users.length,
            activeUsers: users.filter(u => u.isActive).length,
            inactiveUsers: users.filter(u => !u.isActive).length,
            newUsersThisMonth: 12
        };
        updateStatsDisplay();
    }
}

// Update stats display
function updateStatsDisplay() {
    document.getElementById('totalUsers').textContent = stats.totalUsers;
    document.getElementById('activeUsers').textContent = stats.activeUsers;
    document.getElementById('inactiveUsers').textContent = stats.inactiveUsers;
    document.getElementById('newUsersThisMonth').textContent = stats.newUsersThisMonth;
}

// Display users
function displayUsers() {
    const tbody = document.getElementById('usersTableBody');
    const userCountElement = document.getElementById('userCount');
    
    showTableLoading(false);
    
    if (filteredUsers.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-5">
                    <i class="fas fa-users fa-3x mb-3 text-muted"></i>
                    <p class="text-muted">No users found</p>
                    <p class="small text-muted">Try adjusting your filters</p>
                </td>
            </tr>
        `;
        userCountElement.textContent = '0 users';
        return;
    }
    
    // Pagination
    const startIndex = (currentPage - 1) * usersPerPage;
    const endIndex = startIndex + usersPerPage;
    const paginatedUsers = filteredUsers.slice(startIndex, endIndex);
    
    tbody.innerHTML = paginatedUsers.map(user => `
        <tr>
            <td>
                <div class="user-info">
                    ${user.profileImageUrl ? 
                        `<img src="${user.profileImageUrl}" class="user-avatar" alt="${user.fullName}">` :
                        `<div class="user-avatar-placeholder">${getInitials(user.fullName)}</div>`
                    }
                    <div class="user-details">
                        <h6>${user.fullName}</h6>
                        <p>${user.email || 'No email provided'}</p>
                    </div>
                </div>
            </td>
            <td>
                <p class="mb-1"><i class="fas fa-phone me-2"></i>${user.phoneNumber || 'N/A'}</p>
                ${user.phoneNumber2 ? `<p class="mb-0"><i class="fas fa-phone me-2"></i>${user.phoneNumber2}</p>` : ''}
            </td>
            <td>
                ${user.whatAreYouHere ? 
                    `<span class="purpose-badge">${user.whatAreYouHere}</span>` :
                    '<span class="text-muted">Not specified</span>'
                }
            </td>
            <td>
                <span class="status-badge status-${user.isActive ? 'active' : 'inactive'}">
                    ${user.isActive ? 'Active' : 'Inactive'}
                </span>
            </td>
            <td>
                ${formatDate(user.createdAt)}
            </td>
            <td>
                ${formatDate(user.lastActiveAt) || 'Never'}
            </td>
            <td>
                <div class="btn-group">
                    <button class="btn btn-sm btn-outline-info" onclick="viewUser('${user.id}')" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-warning" onclick="toggleUserStatus('${user.id}')" title="Toggle Status">
                        <i class="fas fa-${user.isActive ? 'ban' : 'check'}"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="confirmDeleteUser('${user.id}')" title="Delete User">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
    
    userCountElement.textContent = `${filteredUsers.length} user${filteredUsers.length !== 1 ? 's' : ''}`;
    updatePagination();
}

// Apply filters
function applyFilters() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const profileFilter = document.getElementById('profileFilter').value;
    const sortFilter = document.getElementById('sortFilter').value;
    
    filteredUsers = users.filter(user => {
        // Search filter
        const matchesSearch = !searchTerm || 
            user.fullName.toLowerCase().includes(searchTerm) ||
            (user.email && user.email.toLowerCase().includes(searchTerm)) ||
            (user.phoneNumber && user.phoneNumber.includes(searchTerm));
        
        // Status filter
        const matchesStatus = !statusFilter || 
            (statusFilter === 'active' && user.isActive) ||
            (statusFilter === 'inactive' && !user.isActive);
        
        // Profile completion filter
        const matchesProfile = !profileFilter || 
            (profileFilter === 'completed' && user.profileCompleted) ||
            (profileFilter === 'incomplete' && !user.profileCompleted);
        
        return matchesSearch && matchesStatus && matchesProfile;
    });
    
    // Apply sorting
    switch (sortFilter) {
        case 'newest':
            filteredUsers.sort((a, b) => {
                const dateA = a.createdAt ? a.createdAt.toDate() : new Date(0);
                const dateB = b.createdAt ? b.createdAt.toDate() : new Date(0);
                return dateB - dateA;
            });
            break;
        case 'oldest':
            filteredUsers.sort((a, b) => {
                const dateA = a.createdAt ? a.createdAt.toDate() : new Date(0);
                const dateB = b.createdAt ? b.createdAt.toDate() : new Date(0);
                return dateA - dateB;
            });
            break;
        case 'name':
            filteredUsers.sort((a, b) => a.fullName.localeCompare(b.fullName));
            break;
        case 'lastActive':
            filteredUsers.sort((a, b) => {
                const dateA = a.lastActiveAt ? a.lastActiveAt.toDate() : new Date(0);
                const dateB = b.lastActiveAt ? b.lastActiveAt.toDate() : new Date(0);
                return dateB - dateA;
            });
            break;
    }
    
    currentPage = 1;
    displayUsers();
}

// Clear filters
function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('profileFilter').value = '';
    document.getElementById('sortFilter').value = 'newest';
    applyFilters();
}

// Update pagination
function updatePagination() {
    const pagination = document.getElementById('pagination');
    const totalPages = Math.ceil(filteredUsers.length / usersPerPage);
    
    if (totalPages <= 1) {
        pagination.innerHTML = '';
        return;
    }
    
    let paginationHTML = '';
    
    // Previous button
    paginationHTML += `
        <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">Previous</a>
        </li>
    `;
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            paginationHTML += `
                <li class="page-item ${i === currentPage ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="changePage(${i}); return false;">${i}</a>
                </li>
            `;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            paginationHTML += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        }
    }
    
    // Next button
    paginationHTML += `
        <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">Next</a>
        </li>
    `;
    
    pagination.innerHTML = paginationHTML;
}

// Change page
function changePage(page) {
    const totalPages = Math.ceil(filteredUsers.length / usersPerPage);
    if (page < 1 || page > totalPages) return;
    
    currentPage = page;
    displayUsers();
    
    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// View user details
function viewUser(userId) {
    const user = users.find(u => u.id === userId);
    if (!user) return;
    
    selectedUserId = userId;
    
    const detailsHTML = `
        <div class="row">
            <div class="col-md-4 text-center">
                ${user.profileImageUrl ? 
                    `<img src="${user.profileImageUrl}" class="img-fluid rounded mb-3" style="max-width: 200px;" alt="${user.fullName}">` :
                    `<div class="user-avatar-placeholder mx-auto" style="width: 150px; height: 150px; font-size: 3rem;">${getInitials(user.fullName)}</div>`
                }
                <h5 class="mt-3">${user.fullName}</h5>
                ${user.whatAreYouHere ? `<span class="purpose-badge">${user.whatAreYouHere}</span>` : '<span class="text-muted">Purpose not specified</span>'}
                <p class="mt-2">
                    <span class="status-badge status-${user.isActive ? 'active' : 'inactive'}">
                        ${user.isActive ? 'Active' : 'Inactive'}
                    </span>
                </p>
            </div>
            <div class="col-md-8">
                <h6 class="text-primary mb-3"><i class="fas fa-user me-2"></i>Personal Information</h6>
                <dl class="row">
                    <dt class="col-sm-4">Full Name:</dt>
                    <dd class="col-sm-8">${user.fullName}</dd>
                    
                    <dt class="col-sm-4">Email:</dt>
                    <dd class="col-sm-8">${user.email || 'Not provided'}</dd>
                    
                    <dt class="col-sm-4">Phone:</dt>
                    <dd class="col-sm-8">${user.phoneNumber || 'Not provided'}</dd>
                    
                    ${user.phoneNumber2 ? `
                    <dt class="col-sm-4">Phone 2:</dt>
                    <dd class="col-sm-8">${user.phoneNumber2}</dd>
                    ` : ''}
                    
                    ${user.aboutMe ? `
                    <dt class="col-sm-4">About:</dt>
                    <dd class="col-sm-8">${user.aboutMe}</dd>
                    ` : ''}
                    
                    ${user.whatAreYouHere ? `
                    <dt class="col-sm-4">Purpose:</dt>
                    <dd class="col-sm-8">${user.whatAreYouHere}</dd>
                    ` : ''}
                </dl>
                
                <h6 class="text-primary mb-3 mt-4"><i class="fas fa-info-circle me-2"></i>Account Information</h6>
                <dl class="row">
                    <dt class="col-sm-4">User ID:</dt>
                    <dd class="col-sm-8"><code>${user.id}</code></dd>
                    
                    <dt class="col-sm-4">Joined:</dt>
                    <dd class="col-sm-8">${formatDate(user.createdAt) || 'Unknown'}</dd>
                    
                    <dt class="col-sm-4">Last Active:</dt>
                    <dd class="col-sm-8">${formatDate(user.lastActiveAt) || 'Never'}</dd>
                    
                    <dt class="col-sm-4">Profile Completed:</dt>
                    <dd class="col-sm-8">${user.profileCompleted ? '<i class="fas fa-check text-success"></i> Yes' : '<i class="fas fa-times text-danger"></i> No'}</dd>
                    
                    <dt class="col-sm-4">FCM Token:</dt>
                    <dd class="col-sm-8">${user.fcmToken ? '<i class="fas fa-check text-success"></i> Registered' : '<i class="fas fa-times text-danger"></i> Not Registered'}</dd>
                </dl>
                
                ${user.subscribedTopics && user.subscribedTopics.length > 0 ? `
                <h6 class="text-primary mb-3 mt-4"><i class="fas fa-bell me-2"></i>Notification Topics</h6>
                <div class="mb-3">
                    ${user.subscribedTopics.map(topic => `<span class="badge bg-info me-2 mb-2">${topic}</span>`).join('')}
                </div>
                ` : ''}
            </div>
        </div>
    `;
    
    document.getElementById('userDetailsContent').innerHTML = detailsHTML;
    const modal = new bootstrap.Modal(document.getElementById('userDetailsModal'));
    modal.show();
}

// Toggle user status
async function toggleUserStatus(userId) {
    const user = userId ? users.find(u => u.id === userId) : users.find(u => u.id === selectedUserId);
    if (!user) return;
    
    const newStatus = !user.isActive;
    const action = newStatus ? 'activate' : 'deactivate';
    
    if (!confirm(`Are you sure you want to ${action} this user?`)) {
        return;
    }
    
    try {
        const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
        loadingModal.show();
        
        await db.collection('users').doc(user.id).update({
            isActive: newStatus,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        
        loadingModal.hide();
        showAlert(`User ${newStatus ? 'activated' : 'deactivated'} successfully!`, 'success');
        
        // Close details modal if open
        const detailsModal = bootstrap.Modal.getInstance(document.getElementById('userDetailsModal'));
        if (detailsModal) detailsModal.hide();
        
        await loadUsers();
        await loadStats();
        
    } catch (error) {
        console.error('Error toggling user status:', error);
        showAlert('Failed to update user status. Please try again.', 'danger');
        const loadingModal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (loadingModal) loadingModal.hide();
    }
}

// Confirm delete user
function confirmDeleteUser(userId) {
    selectedUserId = userId;
    deleteUser();
}

// Delete user
async function deleteUser() {
    const user = users.find(u => u.id === selectedUserId);
    if (!user) return;
    
    if (!confirm(`Are you sure you want to delete ${user.fullName}? This action cannot be undone and will remove all user data.`)) {
        return;
    }
    
    // Extra confirmation for safety
    const confirmation = prompt('Type "DELETE" to confirm deletion:');
    if (confirmation !== 'DELETE') {
        showAlert('Deletion cancelled.', 'info');
        return;
    }
    
    try {
        const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
        loadingModal.show();
        
        await db.collection('users').doc(selectedUserId).delete();
        
        loadingModal.hide();
        showAlert('User deleted successfully!', 'success');
        
        // Close details modal if open
        const detailsModal = bootstrap.Modal.getInstance(document.getElementById('userDetailsModal'));
        if (detailsModal) detailsModal.hide();
        
        selectedUserId = null;
        await loadUsers();
        await loadStats();
        
    } catch (error) {
        console.error('Error deleting user:', error);
        showAlert('Failed to delete user. Please try again.', 'danger');
        const loadingModal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (loadingModal) loadingModal.hide();
    }
}

// Export users to CSV
function exportUsers() {
    if (filteredUsers.length === 0) {
        showAlert('No users to export', 'warning');
        return;
    }
    
    const csvData = [
        ['Full Name', 'Email', 'Phone', 'Purpose', 'Status', 'Joined', 'Last Active']
    ];
    
    filteredUsers.forEach(user => {
        csvData.push([
            user.fullName,
            user.email || '',
            user.phoneNumber || '',
            user.whatAreYouHere || 'Not specified',
            user.isActive ? 'Active' : 'Inactive',
            formatDate(user.createdAt) || '',
            formatDate(user.lastActiveAt) || 'Never'
        ]);
    });
    
    const csvContent = csvData.map(row => row.map(cell => `"${cell}"`).join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `users_export_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
    
    showAlert('Users exported successfully!', 'success');
}

// Show table loading
function showTableLoading(show) {
    const tbody = document.getElementById('usersTableBody');
    if (show) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2 text-muted">Loading users...</p>
                </td>
            </tr>
        `;
    }
}

// Show alert
function showAlert(message, type) {
    const alertContainer = document.getElementById('alertContainer');
    const alertId = 'alert-' + Date.now();
    
    const alertHTML = `
        <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show" role="alert">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'danger' ? 'exclamation-circle' : 'info-circle'} me-2"></i>
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

// Utility functions
function getInitials(name) {
    if (!name) return '?';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}

function formatDate(timestamp) {
    if (!timestamp) return null;
    
    try {
        const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    } catch (e) {
        return null;
    }
}

// Sample data for demonstration
function getSampleUsers() {
    return [
        {
            id: 'sample1',
            fullName: 'John Doe',
            email: 'john.doe@example.com',
            phoneNumber: '+91 9876543210',
            phoneNumber2: '',
            isRealEstateAgent: false,
            isActive: true,
            profileImageUrl: '',
            profileCompleted: true,
            aboutMe: 'Looking to invest in properties',
            whatAreYouHere: 'To buy a property',
            createdAt: { toDate: () => new Date(2024, 0, 15) },
            lastActiveAt: { toDate: () => new Date() },
            fcmToken: 'sample_token_1',
            subscribedTopics: ['all_users', 'property_updates'],
            notificationPreferences: {}
        },
        {
            id: 'sample2',
            fullName: 'Jane Smith',
            email: 'jane.smith@example.com',
            phoneNumber: '+91 9876543211',
            phoneNumber2: '',
            isRealEstateAgent: false,
            isActive: true,
            profileImageUrl: '',
            profileCompleted: true,
            aboutMe: 'Looking for my dream home',
            whatAreYouHere: 'To rent a property',
            createdAt: { toDate: () => new Date(2024, 1, 20) },
            lastActiveAt: { toDate: () => new Date(Date.now() - 86400000) },
            fcmToken: 'sample_token_2',
            subscribedTopics: ['all_users', 'new_properties'],
            notificationPreferences: {}
        },
        {
            id: 'sample3',
            fullName: 'Mike Johnson',
            email: 'mike.johnson@example.com',
            phoneNumber: '+91 9876543212',
            phoneNumber2: '',
            isRealEstateAgent: false,
            isActive: false,
            profileImageUrl: '',
            profileCompleted: false,
            aboutMe: '',
            whatAreYouHere: '',
            createdAt: { toDate: () => new Date(2024, 2, 10) },
            lastActiveAt: { toDate: () => new Date(Date.now() - 2592000000) },
            fcmToken: '',
            subscribedTopics: [],
            notificationPreferences: {}
        }
    ];
}

// Export functions for global access
window.usersAdmin = {
    loadUsers,
    loadStats,
    viewUser,
    toggleUserStatus,
    deleteUser,
    exportUsers,
    applyFilters,
    clearFilters,
    changePage
};

