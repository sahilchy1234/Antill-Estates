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
const storage = firebase.storage();

// Configure storage with proper settings
storage.app.options.storageBucket = firebaseConfig.storageBucket;

// Property Management State
let properties = [];
let filteredProperties = [];
let propertyStats = {
    totalProperties: 0,
    activeProperties: 0,
    pendingProperties: 0,
    propertiesThisMonth: 0
};
let currentPage = 1;
let itemsPerPage = 10;
let editingPropertyId = null;

// Available amenities
const availableAmenities = [
    'Swimming Pool', 'Gym', 'Parking', 'Garden', 'Security', 'Lift', 'Power Backup',
    'Water Supply', 'Gated Community', 'Club House', 'Playground', 'CCTV',
    'Intercom', 'Maintenance Staff', 'Rain Water Harvesting', 'Solar Panel',
    'Internet/WiFi', 'Air Conditioning', 'Furnished', 'Semi Furnished',
    'Pet Friendly', 'Wheelchair Accessible'
];

// Initialize the property management system
document.addEventListener('DOMContentLoaded', function() {
    console.log('Property management system initializing...');
    initializePropertyManagement();
    setupEventListeners();
    loadProperties();
    loadPropertyStats();
    populateAmenities();
    setupImageUpload();
    console.log('Property management system initialization complete');
});

// Initialize property management
function initializePropertyManagement() {
    console.log('Property Management System Initialized');
}

// Setup event listeners
function setupEventListeners() {
    // Search input
    document.getElementById('searchInput').addEventListener('input', function() {
        filterProperties();
    });

    // Filter dropdowns
    ['statusFilter', 'typeFilter', 'categoryFilter'].forEach(id => {
        document.getElementById(id).addEventListener('change', filterProperties);
    });

    // Image upload
    setupImageUploadHandlers();
    
    // Avatar upload
    setupAvatarUploadHandlers();
}

// Setup image upload handlers
function setupImageUploadHandlers() {
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('propertyImages');
    const previewDiv = document.getElementById('imagePreview');
    
    // Click to upload
    uploadArea.addEventListener('click', () => {
        fileInput.click();
    });
    
    // File selection
    fileInput.addEventListener('change', (e) => {
        handleImageSelection(e.target.files);
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
        handleImageSelection(e.dataTransfer.files);
    });
}

// Handle image selection
function handleImageSelection(files) {
    const previewDiv = document.getElementById('imagePreview');
    previewDiv.innerHTML = '';
    previewDiv.style.display = files.length > 0 ? 'flex' : 'none';
    
    Array.from(files).forEach((file, index) => {
        if (file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const img = document.createElement('img');
                img.src = e.target.result;
                img.className = 'gallery-thumb';
                img.alt = `Property image ${index + 1}`;
                previewDiv.appendChild(img);
            };
            reader.readAsDataURL(file);
        }
    });
}

// Setup avatar upload handlers
function setupAvatarUploadHandlers() {
    const avatarUploadArea = document.getElementById('avatarUploadArea');
    const avatarFileInput = document.getElementById('contactAvatar');
    const avatarPreview = document.getElementById('avatarPreview');
    
    if (!avatarUploadArea || !avatarFileInput || !avatarPreview) {
        console.log('Avatar upload elements not found');
        return;
    }
    
    // Click to upload
    avatarUploadArea.addEventListener('click', () => {
        avatarFileInput.click();
    });
    
    // File selection
    avatarFileInput.addEventListener('change', (e) => {
        handleAvatarSelection(e.target.files[0]);
    });
    
    // Drag and drop
    avatarUploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        avatarUploadArea.classList.add('dragover');
    });
    
    avatarUploadArea.addEventListener('dragleave', () => {
        avatarUploadArea.classList.remove('dragover');
    });
    
    avatarUploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        avatarUploadArea.classList.remove('dragover');
        handleAvatarSelection(e.dataTransfer.files[0]);
    });
}

// Handle avatar selection
function handleAvatarSelection(file) {
    if (!file) return;
    
    if (!file.type.startsWith('image/')) {
        showAlert('Please select an image file for avatar', 'warning');
        return;
    }
    
    if (file.size > 5 * 1024 * 1024) { // 5MB limit for avatar
        showAlert('Avatar image is too large. Maximum size is 5MB', 'warning');
        return;
    }
    
    const reader = new FileReader();
    reader.onload = (e) => {
        const avatarPreview = document.getElementById('avatarPreview');
        avatarPreview.innerHTML = `<img src="${e.target.result}" alt="Avatar">`;
    };
    reader.readAsDataURL(file);
}

// Populate amenities checkboxes
function populateAmenities() {
    const container = document.getElementById('amenitiesContainer');
    availableAmenities.forEach((amenity, index) => {
        const col = document.createElement('div');
        col.className = 'col-md-4 col-sm-6 mb-2';
        col.innerHTML = `
            <div class="form-check">
                <input class="form-check-input" type="checkbox" value="${amenity}" id="amenity_${index}">
                <label class="form-check-label" for="amenity_${index}">
                    ${amenity}
                </label>
            </div>
        `;
        container.appendChild(col);
    });
}

// Load properties from Firebase
async function loadProperties() {
    try {
        console.log('Loading properties...');
        
        const propertiesSnapshot = await db.collection('properties')
            .where('isActive', '==', true)
            .orderBy('createdAt', 'desc')
            .get();
        
        properties = [];
        propertiesSnapshot.forEach(doc => {
            const data = doc.data();
            properties.push({
                id: doc.id,
                ...data,
                createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(data.createdAt || Date.now()),
                updatedAt: data.updatedAt?.toDate ? data.updatedAt.toDate() : new Date(data.updatedAt || Date.now())
            });
        });
        
        filteredProperties = [...properties];
        updatePropertiesList();
        updatePagination();
        
        console.log(`Loaded ${properties.length} properties`);
        
    } catch (error) {
        console.error('Error loading properties:', error);
        showAlert('Failed to load properties', 'danger');
        
        // Show sample data for demonstration
        properties = [
            {
                id: 'sample1',
                propertyLooking: 'buy',
                category: 'residential',
                propertyType: 'flat',
                city: 'Mumbai',
                locality: 'Bandra West',
                subLocality: 'Hill Road',
                plotArea: '1200',
                plotAreaUnit: 'sq ft',
                noOfBedrooms: '3',
                noOfBathrooms: '2',
                noOfBalconies: '2',
                totalFloors: '15',
                expectedPrice: '₹2.5 Cr',
                availabilityStatus: 'Ready to Move',
                description: 'Beautiful 3BHK apartment with modern amenities and excellent connectivity.',
                contactName: 'John Doe',
                contactPhone: '+91 9876543210',
                contactEmail: 'john@example.com',
                ownership: 'Individual',
                coveredParking: 1,
                openParking: 1,
                propertyPhotos: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500'],
                amenities: ['Swimming Pool', 'Gym', 'Parking', 'Security'],
                createdAt: new Date(),
                updatedAt: new Date(),
                isActive: true
            },
            {
                id: 'sample2',
                propertyLooking: 'rent',
                category: 'residential',
                propertyType: 'independent_house',
                city: 'Delhi',
                locality: 'Greater Kailash',
                subLocality: 'GK-1',
                plotArea: '2000',
                plotAreaUnit: 'sq ft',
                noOfBedrooms: '4',
                noOfBathrooms: '3',
                noOfBalconies: '3',
                totalFloors: '3',
                expectedPrice: '₹1.2 Lakh/month',
                availabilityStatus: 'Ready to Move',
                description: 'Spacious independent house with garden and parking.',
                contactName: 'Jane Smith',
                contactPhone: '+91 9876543211',
                contactEmail: 'jane@example.com',
                ownership: 'Individual',
                coveredParking: 2,
                openParking: 1,
                propertyPhotos: ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=500'],
                amenities: ['Garden', 'Parking', 'Security', 'Power Backup'],
                createdAt: new Date(Date.now() - 86400000),
                updatedAt: new Date(Date.now() - 86400000),
                isActive: true
            }
        ];
        
        filteredProperties = [...properties];
        updatePropertiesList();
        updatePagination();
        showAlert('Loaded sample properties for demonstration. Connect to Firebase to see real data.', 'info');
    }
}

// Load property statistics
async function loadPropertyStats() {
    try {
        console.log('Loading property stats...');
        
        const totalProperties = properties.length;
        const activeProperties = properties.filter(p => p.isActive).length;
        const pendingProperties = properties.filter(p => p.availabilityStatus === 'Pending').length;
        
        // Count properties created this month
        const thisMonth = new Date();
        thisMonth.setDate(1);
        const propertiesThisMonth = properties.filter(p => p.createdAt >= thisMonth).length;
        
        propertyStats = {
            totalProperties,
            activeProperties,
            pendingProperties,
            propertiesThisMonth
        };
        
        updatePropertyStats();
        
    } catch (error) {
        console.error('Error loading property stats:', error);
    }
}

// Update property statistics display
function updatePropertyStats() {
    document.getElementById('totalProperties').textContent = propertyStats.totalProperties;
    document.getElementById('activeProperties').textContent = propertyStats.activeProperties;
    document.getElementById('pendingProperties').textContent = propertyStats.pendingProperties;
    document.getElementById('propertiesThisMonth').textContent = propertyStats.propertiesThisMonth;
}

// Filter properties based on search and filters
function filterProperties() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const typeFilter = document.getElementById('typeFilter').value;
    const categoryFilter = document.getElementById('categoryFilter').value;
    
    filteredProperties = properties.filter(property => {
        // Search filter
        const matchesSearch = !searchTerm || 
            property.city.toLowerCase().includes(searchTerm) ||
            property.locality.toLowerCase().includes(searchTerm) ||
            property.contactName.toLowerCase().includes(searchTerm) ||
            property.propertyType.toLowerCase().includes(searchTerm);
        
        // Status filter
        const matchesStatus = !statusFilter || 
            (statusFilter === 'active' && property.isActive) ||
            (statusFilter === 'inactive' && !property.isActive) ||
            (statusFilter === 'pending' && property.availabilityStatus === 'Pending');
        
        // Type filter
        const matchesType = !typeFilter || property.propertyLooking === typeFilter;
        
        // Category filter
        const matchesCategory = !categoryFilter || property.category === categoryFilter;
        
        return matchesSearch && matchesStatus && matchesType && matchesCategory;
    });
    
    currentPage = 1;
    updatePropertiesList();
    updatePagination();
}

// Clear all filters
function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('typeFilter').value = '';
    document.getElementById('categoryFilter').value = '';
    
    filteredProperties = [...properties];
    currentPage = 1;
    updatePropertiesList();
    updatePagination();
}

// Update properties list display
function updatePropertiesList() {
    const container = document.getElementById('propertiesList');
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageProperties = filteredProperties.slice(startIndex, endIndex);
    
    if (pageProperties.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted py-5">
                <i class="fas fa-home fa-3x mb-3"></i>
                <p>No properties found</p>
                <p class="small">Try adjusting your search criteria or add a new property</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = pageProperties.map(property => `
        <div class="property-card">
            <div class="row g-0">
                <div class="col-md-4">
                    <img src="${property.propertyPhotos && property.propertyPhotos.length > 0 ? property.propertyPhotos[0] : 'https://via.placeholder.com/300x200?text=No+Image'}" 
                         class="property-image" alt="${property.propertyType}">
                </div>
                <div class="col-md-8">
                    <div class="property-content">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="property-title">${property.propertyType.charAt(0).toUpperCase() + property.propertyType.slice(1)} - ${property.city}</h5>
                            <span class="status-badge ${property.isActive ? 'status-active' : 'status-inactive'}">
                                ${property.isActive ? 'Active' : 'Inactive'}
                            </span>
                        </div>
                        
                        <div class="property-details mb-3">
                            <div class="row">
                                <div class="col-6">
                                    <strong>Price:</strong> ${property.expectedPrice}<br>
                                    <strong>Location:</strong> ${property.locality}, ${property.city}
                                </div>
                                <div class="col-6">
                                    <strong>Type:</strong> ${property.propertyLooking} - ${property.category}<br>
                                    <strong>Size:</strong> ${property.plotArea} ${property.plotAreaUnit}
                                </div>
                            </div>
                            <div class="row mt-2">
                                <div class="col-6">
                                    <strong>Bedrooms:</strong> ${property.noOfBedrooms} | 
                                    <strong>Bathrooms:</strong> ${property.noOfBathrooms}
                                </div>
                                <div class="col-6">
                                    <strong>Contact:</strong> ${property.contactName} (${property.contactPhone})
                                </div>
                            </div>
                        </div>
                        
                        <div class="property-actions">
                            <button class="btn btn-outline-info btn-sm" onclick="viewPropertyDetails('${property.id}')">
                                <i class="fas fa-eye"></i> View
                            </button>
                            <button class="btn btn-outline-primary btn-sm" onclick="editProperty('${property.id}')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-outline-warning btn-sm" onclick="togglePropertyStatus('${property.id}')">
                                <i class="fas fa-${property.isActive ? 'pause' : 'play'}"></i> ${property.isActive ? 'Deactivate' : 'Activate'}
                            </button>
                            <button class="btn btn-outline-danger btn-sm" onclick="deleteProperty('${property.id}')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

// Update pagination
function updatePagination() {
    const totalPages = Math.ceil(filteredProperties.length / itemsPerPage);
    const paginationContainer = document.getElementById('pagination');
    
    if (totalPages <= 1) {
        paginationContainer.innerHTML = '';
        return;
    }
    
    let paginationHTML = '';
    
    // Previous button
    paginationHTML += `
        <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage - 1})">Previous</a>
        </li>
    `;
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            paginationHTML += `
                <li class="page-item ${i === currentPage ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="changePage(${i})">${i}</a>
                </li>
            `;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            paginationHTML += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        }
    }
    
    // Next button
    paginationHTML += `
        <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage + 1})">Next</a>
        </li>
    `;
    
    paginationContainer.innerHTML = paginationHTML;
}

// Change page
function changePage(page) {
    const totalPages = Math.ceil(filteredProperties.length / itemsPerPage);
    if (page >= 1 && page <= totalPages) {
        currentPage = page;
        updatePropertiesList();
        updatePagination();
    }
}

// Save property
async function saveProperty() {
    try {
        const form = document.getElementById('propertyForm');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        
        const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
        loadingModal.show();
        
        // Get form data - ensuring all fields match Flutter app expectations
        const propertyData = {
            propertyLooking: document.getElementById('propertyLooking').value,
            category: document.getElementById('category').value,
            propertyType: document.getElementById('propertyType').value,
            city: document.getElementById('city').value,
            locality: document.getElementById('locality').value,
            subLocality: document.getElementById('subLocality').value,
            plotArea: document.getElementById('plotArea').value,
            plotAreaUnit: document.getElementById('plotAreaUnit').value,
            // Additional required fields for Flutter app compatibility
            builtUpArea: document.getElementById('builtUpArea') ? document.getElementById('builtUpArea').value : '',
            superBuiltUpArea: document.getElementById('superBuiltUpArea') ? document.getElementById('superBuiltUpArea').value : '',
            otherRooms: [], // Can be extended later
            totalFloors: document.getElementById('totalFloors').value,
            noOfBedrooms: document.getElementById('noOfBedrooms').value,
            noOfBathrooms: document.getElementById('noOfBathrooms').value,
            noOfBalconies: document.getElementById('noOfBalconies').value,
            coveredParking: parseInt(document.getElementById('coveredParking').value) || 0,
            openParking: parseInt(document.getElementById('openParking').value) || 0,
            availabilityStatus: document.getElementById('availabilityStatus').value,
            propertyPhotos: [], // Will be set after image upload
            ownership: document.getElementById('ownership').value,
            expectedPrice: document.getElementById('expectedPrice').value,
            priceDetails: [], // Can be extended later
            description: document.getElementById('description').value,
            amenities: getSelectedAmenities(),
            waterSource: [], // Can be extended later
            otherFeatures: [], // Can be extended later
            locationAdvantages: [], // Can be extended later
            // Contact information
            contactName: document.getElementById('contactName').value,
            contactPhone: document.getElementById('contactPhone').value,
            contactEmail: document.getElementById('contactEmail').value,
            contactAvatar: '', // Will be set after avatar upload
            // Admin panel specific
            userId: 'admin', // Mark as admin-created property
            isActive: true,
            createdAt: editingPropertyId ? undefined : new Date(),
            updatedAt: new Date()
        };
        
        // Upload images if any
        const imageFiles = document.getElementById('propertyImages').files;
        if (imageFiles.length > 0) {
            console.log(`Uploading ${imageFiles.length} property images...`);
            propertyData.propertyPhotos = await uploadPropertyImages(imageFiles);
            console.log('Property images uploaded successfully');
        }
        
        // Upload avatar if any
        const avatarFile = document.getElementById('contactAvatar').files[0];
        if (avatarFile) {
            console.log('Uploading contact avatar...');
            propertyData.contactAvatar = await uploadAvatar(avatarFile);
            console.log('Contact avatar uploaded successfully');
        }
        
        let propertyId = editingPropertyId;
        if (editingPropertyId) {
            // Update existing property
            await db.collection('properties').doc(editingPropertyId).update(propertyData);
            showAlert('Property updated successfully!', 'success');
            editingPropertyId = null;
        } else {
            // Add new property
            const docRef = await db.collection('properties').add(propertyData);
            propertyId = docRef.id;
            showAlert('Property added successfully!', 'success');
            
            // Create in-app notification for new property
            await createInAppNotification({
                title: `New Property: ${propertyData.propertyType} ${propertyData.propertyLooking}`,
                subtitle: `${propertyData.noOfBedrooms} BHK in ${propertyData.locality}, ${propertyData.city}. ${propertyData.description.substring(0, 100)}...`,
                itemType: 'property',
                itemId: propertyId,
                imageUrl: propertyData.propertyPhotos[0] || '',
                images: propertyData.propertyPhotos || [],
                price: propertyData.expectedPrice,
                location: `${propertyData.locality}, ${propertyData.city}`,
                actionText: 'View Property',
            });
        }
        
        // Reset form and close modal
        resetPropertyForm();
        const modal = bootstrap.Modal.getInstance(document.getElementById('propertyModal'));
        modal.hide();
        
        // Reload data
        await loadProperties();
        await loadPropertyStats();
        
        loadingModal.hide();
        
    } catch (error) {
        console.error('Error saving property:', error);
        showAlert('Failed to save property: ' + error.message, 'danger');
        const loadingModal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (loadingModal) loadingModal.hide();
    }
}

// Upload property images
async function uploadPropertyImages(files) {
    const imageUrls = [];
    
    // Compress all images first
    console.log('Compressing property images before upload...');
    const compressedFiles = await window.imageCompressor.compressPropertyImages(files);
    
    for (let i = 0; i < compressedFiles.length; i++) {
        const file = compressedFiles[i];
        
        // Validate file type
        if (!file.type.startsWith('image/')) {
            throw new Error(`File ${file.name} is not an image`);
        }
        
        // Validate file size (10MB limit for compressed file)
        if (file.size > 10 * 1024 * 1024) {
            throw new Error(`File ${file.name} is too large even after compression. Maximum size is 10MB`);
        }
        
        const fileName = `properties/${Date.now()}_${i}_${file.name.replace(/[^a-zA-Z0-9.]/g, '_')}`;
        const storageRef = storage.ref().child(fileName);
        
        try {
            console.log(`Uploading compressed image ${i + 1}/${compressedFiles.length}: ${file.name}`);
            console.log('Storage reference path:', storageRef.fullPath);
            
            // Upload with proper configuration
            const uploadTask = storageRef.put(file, {
                contentType: file.type,
                cacheControl: 'public, max-age=31536000'
            });
            
            // Monitor upload progress
            uploadTask.on('state_changed', 
                (snapshot) => {
                    const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                    console.log(`Upload progress: ${progress.toFixed(2)}%`);
                },
                (error) => {
                    console.error('Upload error:', error);
                },
                async () => {
                    console.log('Upload completed');
                }
            );
            
            // Wait for upload to complete
            const snapshot = await uploadTask;
            const downloadUrl = await snapshot.ref.getDownloadURL();
            
            imageUrls.push(downloadUrl);
            console.log(`Successfully uploaded: ${downloadUrl}`);
            
        } catch (error) {
            console.error('Error uploading image:', error);
            console.error('Error details:', {
                code: error.code,
                message: error.message,
                serverResponse: error.serverResponse
            });
            
            // Provide more specific error messages
            let errorMessage = `Failed to upload ${file.name}`;
            if (error.code === 'storage/unauthorized') {
                errorMessage = 'Storage access denied. Check Firebase Storage rules.';
            } else if (error.code === 'storage/retry-limit-exceeded') {
                errorMessage = 'Upload failed due to network issues. Please try again.';
            } else if (error.code === 'storage/invalid-format') {
                errorMessage = 'Invalid file format. Please use PNG, JPG, or GIF.';
            } else {
                errorMessage += `: ${error.message}`;
            }
            
            throw new Error(errorMessage);
        }
    }
    
    return imageUrls;
}

// Upload avatar image
async function uploadAvatar(file) {
    if (!file) return '';
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        throw new Error('Avatar must be an image file');
    }
    
    // Compress avatar image first
    console.log('Compressing avatar image before upload...');
    const compressedFile = await window.imageCompressor.compressAvatarImage(file);
    
    // Validate file size (5MB limit for avatar even after compression)
    if (compressedFile.size > 5 * 1024 * 1024) {
        throw new Error('Avatar image is too large even after compression. Maximum size is 5MB');
    }
    
    const fileName = `avatars/${Date.now()}_${compressedFile.name.replace(/[^a-zA-Z0-9.]/g, '_')}`;
    const storageRef = storage.ref().child(fileName);
    
    try {
        console.log(`Uploading compressed avatar: ${compressedFile.name}`);
        console.log('Avatar storage reference path:', storageRef.fullPath);
        
        // Upload with proper configuration
        const uploadTask = storageRef.put(compressedFile, {
            contentType: compressedFile.type,
            cacheControl: 'public, max-age=31536000'
        });
        
        // Monitor upload progress
        uploadTask.on('state_changed', 
            (snapshot) => {
                const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                console.log(`Avatar upload progress: ${progress.toFixed(2)}%`);
            },
            (error) => {
                console.error('Avatar upload error:', error);
            },
            async () => {
                console.log('Avatar upload completed');
            }
        );
        
        // Wait for upload to complete
        const snapshot = await uploadTask;
        const downloadUrl = await snapshot.ref.getDownloadURL();
        
        console.log(`Avatar uploaded successfully: ${downloadUrl}`);
        return downloadUrl;
        
    } catch (error) {
        console.error('Error uploading avatar:', error);
        console.error('Avatar error details:', {
            code: error.code,
            message: error.message,
            serverResponse: error.serverResponse
        });
        
        // Provide more specific error messages
        let errorMessage = 'Failed to upload avatar';
        if (error.code === 'storage/unauthorized') {
            errorMessage = 'Storage access denied. Check Firebase Storage rules.';
        } else if (error.code === 'storage/retry-limit-exceeded') {
            errorMessage = 'Upload failed due to network issues. Please try again.';
        } else if (error.code === 'storage/invalid-format') {
            errorMessage = 'Invalid file format. Please use PNG, JPG, or GIF.';
        } else {
            errorMessage += `: ${error.message}`;
        }
        
        throw new Error(errorMessage);
    }
}

// Get selected amenities
function getSelectedAmenities() {
    const checkboxes = document.querySelectorAll('#amenitiesContainer input[type="checkbox"]:checked');
    return Array.from(checkboxes).map(cb => cb.value);
}

// Reset property form
function resetPropertyForm() {
    document.getElementById('propertyForm').reset();
    document.getElementById('imagePreview').style.display = 'none';
    document.getElementById('imagePreview').innerHTML = '';
    
    // Reset avatar
    const avatarPreview = document.getElementById('avatarPreview');
    if (avatarPreview) {
        avatarPreview.innerHTML = `
            <i class="fas fa-user fa-2x text-muted"></i>
            <span class="avatar-text">Upload Avatar</span>
        `;
    }
    
    editingPropertyId = null;
    
    // Update modal title
    document.getElementById('propertyModalLabel').textContent = 'Add New Property';
}

// View property details
function viewPropertyDetails(propertyId) {
    const property = properties.find(p => p.id === propertyId);
    if (!property) return;
    
    const modal = new bootstrap.Modal(document.getElementById('propertyDetailsModal'));
    const content = document.getElementById('propertyDetailsContent');
    
    content.innerHTML = `
        <div class="row">
            <div class="col-md-6">
                <h6 class="text-primary mb-3">Property Information</h6>
                <div class="property-detail-item">
                    <span class="property-detail-label">Type:</span>
                    <span class="property-detail-value">${property.propertyLooking} - ${property.category}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Property Type:</span>
                    <span class="property-detail-value">${property.propertyType}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Price:</span>
                    <span class="property-detail-value">${property.expectedPrice}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Size:</span>
                    <span class="property-detail-value">${property.plotArea} ${property.plotAreaUnit}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Bedrooms:</span>
                    <span class="property-detail-value">${property.noOfBedrooms}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Bathrooms:</span>
                    <span class="property-detail-value">${property.noOfBathrooms}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Balconies:</span>
                    <span class="property-detail-value">${property.noOfBalconies}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Total Floors:</span>
                    <span class="property-detail-value">${property.totalFloors}</span>
                </div>
            </div>
            <div class="col-md-6">
                <h6 class="text-primary mb-3">Location & Contact</h6>
                <div class="property-detail-item">
                    <span class="property-detail-label">City:</span>
                    <span class="property-detail-value">${property.city}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Locality:</span>
                    <span class="property-detail-value">${property.locality}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Sub Locality:</span>
                    <span class="property-detail-value">${property.subLocality || 'N/A'}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Contact Name:</span>
                    <span class="property-detail-value">${property.contactName}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Contact Phone:</span>
                    <span class="property-detail-value">${property.contactPhone}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Contact Email:</span>
                    <span class="property-detail-value">${property.contactEmail || 'N/A'}</span>
                </div>
                ${property.contactAvatar ? `
                <div class="property-detail-item">
                    <span class="property-detail-label">Contact Avatar:</span>
                    <span class="property-detail-value">
                        <img src="${property.contactAvatar}" alt="Contact Avatar" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                    </span>
                </div>
                ` : ''}
                <div class="property-detail-item">
                    <span class="property-detail-label">Ownership:</span>
                    <span class="property-detail-value">${property.ownership}</span>
                </div>
                <div class="property-detail-item">
                    <span class="property-detail-label">Status:</span>
                    <span class="property-detail-value">${property.isActive ? 'Active' : 'Inactive'}</span>
                </div>
            </div>
        </div>
        
        ${property.description ? `
            <div class="mt-4">
                <h6 class="text-primary mb-3">Description</h6>
                <p>${property.description}</p>
            </div>
        ` : ''}
        
        ${property.amenities && property.amenities.length > 0 ? `
            <div class="mt-4">
                <h6 class="text-primary mb-3">Amenities</h6>
                <div class="d-flex flex-wrap gap-2">
                    ${property.amenities.map(amenity => `<span class="badge bg-secondary">${amenity}</span>`).join('')}
                </div>
            </div>
        ` : ''}
        
        ${property.propertyPhotos && property.propertyPhotos.length > 0 ? `
            <div class="mt-4">
                <h6 class="text-primary mb-3">Property Images</h6>
                <div class="image-gallery">
                    ${property.propertyPhotos.map(photo => `<img src="${photo}" class="gallery-thumb" alt="Property image">`).join('')}
                </div>
            </div>
        ` : ''}
    `;
    
    modal.show();
}

// Edit property
function editProperty(propertyId) {
    const property = properties.find(p => p.id === propertyId);
    if (!property) return;
    
    editingPropertyId = propertyId;
    
    // Populate form with property data
    document.getElementById('propertyLooking').value = property.propertyLooking;
    document.getElementById('category').value = property.category;
    document.getElementById('propertyType').value = property.propertyType;
    document.getElementById('city').value = property.city;
    document.getElementById('locality').value = property.locality;
    document.getElementById('subLocality').value = property.subLocality || '';
    document.getElementById('plotArea').value = property.plotArea;
    document.getElementById('plotAreaUnit').value = property.plotAreaUnit;
    // New fields for Flutter compatibility
    document.getElementById('builtUpArea').value = property.builtUpArea || '';
    document.getElementById('superBuiltUpArea').value = property.superBuiltUpArea || '';
    document.getElementById('noOfBedrooms').value = property.noOfBedrooms;
    document.getElementById('noOfBathrooms').value = property.noOfBathrooms;
    document.getElementById('noOfBalconies').value = property.noOfBalconies;
    document.getElementById('totalFloors').value = property.totalFloors;
    document.getElementById('expectedPrice').value = property.expectedPrice;
    document.getElementById('availabilityStatus').value = property.availabilityStatus;
    document.getElementById('description').value = property.description || '';
    document.getElementById('contactName').value = property.contactName;
    document.getElementById('contactPhone').value = property.contactPhone;
    document.getElementById('contactEmail').value = property.contactEmail || '';
    document.getElementById('ownership').value = property.ownership;
    document.getElementById('coveredParking').value = property.coveredParking || 0;
    document.getElementById('openParking').value = property.openParking || 0;
    
    // Set amenities
    document.querySelectorAll('#amenitiesContainer input[type="checkbox"]').forEach(cb => {
        cb.checked = property.amenities && property.amenities.includes(cb.value);
    });
    
    // Show existing images if any
    if (property.propertyPhotos && property.propertyPhotos.length > 0) {
        const previewDiv = document.getElementById('imagePreview');
        previewDiv.innerHTML = property.propertyPhotos.map(photo => 
            `<img src="${photo}" class="gallery-thumb" alt="Property image">`
        ).join('');
        previewDiv.style.display = 'flex';
    }
    
    // Show existing avatar if any
    if (property.contactAvatar) {
        const avatarPreview = document.getElementById('avatarPreview');
        avatarPreview.innerHTML = `<img src="${property.contactAvatar}" alt="Contact Avatar">`;
    }
    
    // Update modal title
    document.getElementById('propertyModalLabel').textContent = 'Edit Property';
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('propertyModal'));
    modal.show();
}

// Edit property from details modal
function editPropertyFromDetails() {
    // Get property ID from the current details modal (you might need to store this)
    const modal = bootstrap.Modal.getInstance(document.getElementById('propertyDetailsModal'));
    modal.hide();
    
    // Find the property ID from the current context
    // This is a simplified approach - in a real app, you'd store the current property ID
    const propertyId = window.currentPropertyId;
    if (propertyId) {
        editProperty(propertyId);
    }
}

// Toggle property status
async function togglePropertyStatus(propertyId) {
    try {
        const property = properties.find(p => p.id === propertyId);
        if (!property) return;
        
        const newStatus = !property.isActive;
        
        await db.collection('properties').doc(propertyId).update({
            isActive: newStatus,
            updatedAt: new Date()
        });
        
        showAlert(`Property ${newStatus ? 'activated' : 'deactivated'} successfully!`, 'success');
        await loadProperties();
        await loadPropertyStats();
        
    } catch (error) {
        console.error('Error toggling property status:', error);
        showAlert('Failed to update property status', 'danger');
    }
}

// Delete property
async function deleteProperty(propertyId) {
    if (!confirm('Are you sure you want to delete this property? This action cannot be undone.')) {
        return;
    }
    
    try {
        await db.collection('properties').doc(propertyId).update({
            isActive: false,
            updatedAt: new Date()
        });
        
        showAlert('Property deleted successfully!', 'success');
        await loadProperties();
        await loadPropertyStats();
        
    } catch (error) {
        console.error('Error deleting property:', error);
        showAlert('Failed to delete property', 'danger');
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

// Setup image upload (legacy function for compatibility)
function setupImageUpload() {
    // This function is called for compatibility but the actual setup is done in setupImageUploadHandlers
    console.log('Image upload setup completed');
    
    // Test Firebase connection
    testFirebaseConnection();
}

// Test Firebase connection
async function testFirebaseConnection() {
    try {
        console.log('Testing Firebase connection...');
        
        // Test Firestore connection
        const testDoc = await db.collection('test').doc('connection').get();
        console.log('✅ Firestore connection successful');
        
        // Test Storage connection
        const storageRef = storage.ref();
        console.log('✅ Storage connection successful');
        
        // Test Storage write permission
        try {
            const testUploadRef = storageRef.child('test/connection-test.txt');
            await testUploadRef.putString('test', 'raw');
            await testUploadRef.delete();
            console.log('✅ Storage write permission confirmed');
        } catch (storageError) {
            console.warn('⚠️ Storage write permission issue:', storageError);
            showAlert('Storage write permission issue detected. Please check Firebase Storage rules.', 'warning');
        }
        
        console.log('✅ Firebase connection test completed');
        
    } catch (error) {
        console.error('❌ Firebase connection test failed:', error);
        showAlert('Firebase connection issue detected. Some features may not work properly.', 'warning');
    }
}

// Create in-app notification
async function createInAppNotification({
    title,
    subtitle,
    itemType,
    itemId,
    imageUrl,
    images = [],
    price,
    location,
    actionText = 'View Details'
}) {
    try {
        console.log('Creating in-app notification:', title);
        
        const notificationData = {
            title: title,
            subtitle: subtitle,
            itemType: itemType,
            itemId: itemId,
            imageUrl: imageUrl,
            images: images,
            price: price,
            location: location,
            actionText: actionText,
            active: true,
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            data: {
                itemType: itemType,
                itemId: itemId
            }
        };
        
        await db.collection('in_app_notifications').add(notificationData);
        console.log('✅ In-app notification created successfully');
        
    } catch (error) {
        console.error('❌ Error creating in-app notification:', error);
        // Don't throw - notification creation should not block main operation
    }
}

// Export functions for global access
window.propertyAdmin = {
    loadProperties,
    loadPropertyStats,
    filterProperties,
    clearFilters,
    saveProperty,
    editProperty,
    viewPropertyDetails,
    togglePropertyStatus,
    deleteProperty,
    showAlert,
    createInAppNotification
};
