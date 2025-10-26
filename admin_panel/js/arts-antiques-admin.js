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

// State management
let items = [];
let filteredItems = [];
let currentPage = 1;
const itemsPerPage = 12;
let editingItemId = null;
let uploadedImages = [];

// Stats
let stats = {
    totalItems: 0,
    featuredItems: 0,
    totalViews: 0,
    totalArtists: 0
};

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('Arts & Antiques Admin Panel initializing...');
    setupEventListeners();
    setupImageUpload();
    loadItems();
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
    ['categoryFilter', 'statusFilter', 'featuredFilter'].forEach(filterId => {
        const element = document.getElementById(filterId);
        if (element) {
            element.addEventListener('change', applyFilters);
        }
    });

    // Form submit
    const itemForm = document.getElementById('itemForm');
    if (itemForm) {
        itemForm.addEventListener('submit', function(e) {
            e.preventDefault();
            saveItem();
        });
    }
}

// Setup image upload
function setupImageUpload() {
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('itemImages');
    const previewDiv = document.getElementById('imagePreview');
    
    if (!uploadArea || !fileInput) return;

    // Click to upload
    uploadArea.addEventListener('click', () => {
        fileInput.click();
    });
    
    // File selection
    fileInput.addEventListener('change', async (e) => {
        const files = Array.from(e.target.files);
        if (files.length > 0) {
            await handleImageFiles(files);
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
    
    uploadArea.addEventListener('drop', async (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        const files = Array.from(e.dataTransfer.files).filter(file => file.type.startsWith('image/'));
        if (files.length > 0) {
            await handleImageFiles(files);
        }
    });
}

// Handle image files
async function handleImageFiles(files) {
    const previewDiv = document.getElementById('imagePreview');
    previewDiv.style.display = 'flex';
    
    for (const file of files) {
        const reader = new FileReader();
        reader.onload = (e) => {
            const container = document.createElement('div');
            container.className = 'gallery-thumb-container';
            
            const img = document.createElement('img');
            img.src = e.target.result;
            img.className = 'gallery-thumb';
            
            const removeBtn = document.createElement('button');
            removeBtn.className = 'remove-image-btn';
            removeBtn.innerHTML = '<i class="fas fa-times"></i>';
            removeBtn.onclick = function() {
                container.remove();
                uploadedImages = uploadedImages.filter(img => img.preview !== e.target.result);
                if (previewDiv.children.length === 0) {
                    previewDiv.style.display = 'none';
                }
            };
            
            container.appendChild(img);
            container.appendChild(removeBtn);
            previewDiv.appendChild(container);
        };
        reader.readAsDataURL(file);
        
        // Store file for later upload
        uploadedImages.push({
            file: file,
            preview: URL.createObjectURL(file)
        });
    }
}

// Load items from Firestore
async function loadItems() {
    try {
        console.log('Loading arts & antiques items...');
        showLoading(true);
        
        const querySnapshot = await db.collection('arts_antiques')
            .orderBy('createdAt', 'desc')
            .get();
        
        items = [];
        querySnapshot.forEach(doc => {
            items.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        console.log(`Loaded ${items.length} items`);
        filteredItems = [...items];
        displayItems();
        updatePagination();
        
    } catch (error) {
        console.error('Error loading items:', error);
        showAlert('Failed to load items. Please refresh the page.', 'danger');
        
        // Show sample data for demonstration
        items = getSampleItems();
        filteredItems = [...items];
        displayItems();
        updatePagination();
    } finally {
        showLoading(false);
    }
}

// Load statistics
async function loadStats() {
    try {
        console.log('Loading statistics...');
        
        const querySnapshot = await db.collection('arts_antiques').get();
        
        stats.totalItems = querySnapshot.size;
        stats.featuredItems = 0;
        stats.totalViews = 0;
        const artists = new Set();
        
        querySnapshot.forEach(doc => {
            const data = doc.data();
            if (data.featured) {
                stats.featuredItems++;
            }
            stats.totalViews += data.views || 0;
            if (data.artist) {
                artists.add(data.artist);
            }
        });
        
        stats.totalArtists = artists.size;
        updateStatsDisplay();
        
    } catch (error) {
        console.error('Error loading statistics:', error);
        // Use sample stats
        stats = {
            totalItems: items.length,
            featuredItems: items.filter(i => i.featured).length,
            totalViews: 1234,
            totalArtists: 15
        };
        updateStatsDisplay();
    }
}

// Update stats display
function updateStatsDisplay() {
    document.getElementById('totalItems').textContent = stats.totalItems;
    document.getElementById('featuredItems').textContent = stats.featuredItems;
    document.getElementById('totalViews').textContent = stats.totalViews.toLocaleString();
    document.getElementById('totalArtists').textContent = stats.totalArtists;
}

// Display items
function displayItems() {
    const container = document.getElementById('itemsList');
    
    if (filteredItems.length === 0) {
        container.innerHTML = `
            <div class="col-12 text-center text-muted py-5">
                <i class="fas fa-palette fa-3x mb-3"></i>
                <p>No items found</p>
                <p class="small">Try adjusting your filters or add a new item</p>
            </div>
        `;
        return;
    }
    
    // Pagination
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const paginatedItems = filteredItems.slice(startIndex, endIndex);
    
    container.innerHTML = paginatedItems.map(item => `
        <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
            <div class="item-card">
                <div style="position: relative;">
                    <img src="${item.images && item.images[0] ? item.images[0] : 'https://via.placeholder.com/300x200?text=No+Image'}" 
                         class="item-image" 
                         alt="${item.title}"
                         onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                    ${item.featured ? '<span class="featured-badge"><i class="fas fa-star"></i> Featured</span>' : ''}
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="badge bg-${getCategoryColor(item.category)}">${item.category}</span>
                        <span class="status-badge status-${item.status}">${item.status}</span>
                    </div>
                    <h6 class="item-title">${item.title}</h6>
                    <p class="item-artist"><i class="fas fa-user-tie me-1"></i>${item.artist}</p>
                    <p class="item-price">₹${formatPrice(item.price)}</p>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <small class="text-muted">
                            <i class="fas fa-eye me-1"></i>${item.views || 0} views
                        </small>
                        <small class="text-muted">
                            <i class="fas fa-star me-1"></i>${(item.rating || 0).toFixed(1)}
                        </small>
                    </div>
                    ${item.year ? `<small class="text-muted d-block mb-2"><i class="fas fa-calendar me-1"></i>Year: ${item.year}</small>` : ''}
                    ${item.dimensions ? `<small class="text-muted d-block mb-2"><i class="fas fa-ruler me-1"></i>${item.dimensions}</small>` : ''}
                    <div class="item-actions mt-3">
                        <button class="btn btn-sm btn-outline-primary" onclick="editItem('${item.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-info" onclick="viewItem('${item.id}')">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="deleteItem('${item.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

// Apply filters
function applyFilters() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const categoryFilter = document.getElementById('categoryFilter').value;
    const statusFilter = document.getElementById('statusFilter').value;
    const featuredFilter = document.getElementById('featuredFilter').value;
    
    filteredItems = items.filter(item => {
        // Search filter
        const matchesSearch = !searchTerm || 
            item.title.toLowerCase().includes(searchTerm) ||
            item.artist.toLowerCase().includes(searchTerm) ||
            item.category.toLowerCase().includes(searchTerm) ||
            (item.description && item.description.toLowerCase().includes(searchTerm));
        
        // Category filter
        const matchesCategory = !categoryFilter || item.category === categoryFilter;
        
        // Status filter
        const matchesStatus = !statusFilter || item.status === statusFilter;
        
        // Featured filter
        const matchesFeatured = !featuredFilter || 
            (featuredFilter === 'true' && item.featured) ||
            (featuredFilter === 'false' && !item.featured);
        
        return matchesSearch && matchesCategory && matchesStatus && matchesFeatured;
    });
    
    currentPage = 1;
    displayItems();
    updatePagination();
}

// Clear filters
function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('categoryFilter').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('featuredFilter').value = '';
    applyFilters();
}

// Update pagination
function updatePagination() {
    const pagination = document.getElementById('pagination');
    const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
    
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
    const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
    if (page < 1 || page > totalPages) return;
    
    currentPage = page;
    displayItems();
    updatePagination();
    
    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Save item
async function saveItem() {
    try {
        // Validate form
        const form = document.getElementById('itemForm');
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        
        // Get form data
        const itemData = {
            title: document.getElementById('itemTitle').value,
            category: document.getElementById('itemCategory').value,
            artist: document.getElementById('itemArtist').value,
            price: parseFloat(document.getElementById('itemPrice').value),
            year: parseInt(document.getElementById('itemYear').value) || null,
            dimensions: document.getElementById('itemDimensions').value || '',
            materials: document.getElementById('itemMaterials').value || '',
            location: document.getElementById('itemLocation').value || '',
            status: document.getElementById('itemStatus').value,
            featured: document.getElementById('itemFeatured').checked,
            description: document.getElementById('itemDescription').value,
            views: 0,
            rating: 0,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        };
        
        // Validate images
        if (!editingItemId && uploadedImages.length === 0) {
            showAlert('Please upload at least one image', 'warning');
            return;
        }
        
        // Show loading
        const modal = bootstrap.Modal.getInstance(document.getElementById('itemModal'));
        const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
        modal.hide();
        loadingModal.show();
        
        // Upload images if new ones are added
        if (uploadedImages.length > 0) {
            const imageUrls = await uploadImages();
            itemData.images = imageUrls;
        } else if (editingItemId) {
            // Keep existing images if editing and no new images
            const existingItem = items.find(i => i.id === editingItemId);
            itemData.images = existingItem.images || [];
        }
        
        // Save to Firestore
        if (editingItemId) {
            // Update existing item
            await db.collection('arts_antiques').doc(editingItemId).update(itemData);
            showAlert('Item updated successfully!', 'success');
        } else {
            // Add new item
            itemData.createdAt = firebase.firestore.FieldValue.serverTimestamp();
            await db.collection('arts_antiques').add(itemData);
            showAlert('Item added successfully!', 'success');
        }
        
        // Reset and reload
        loadingModal.hide();
        resetForm();
        await loadItems();
        await loadStats();
        
    } catch (error) {
        console.error('Error saving item:', error);
        showAlert('Failed to save item. Please try again.', 'danger');
        const loadingModal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (loadingModal) loadingModal.hide();
    }
}

// Upload images to Firebase Storage
async function uploadImages() {
    const imageUrls = [];
    
    for (const imageData of uploadedImages) {
        try {
            // Compress image
            const compressedFile = await window.imageCompressor.compressArtsAntiquesImage(imageData.file);
            
            // Upload to Firebase Storage
            const fileName = `artsAntiques/${Date.now()}_${compressedFile.name}`;
            const storageRef = storage.ref().child(fileName);
            
            const snapshot = await storageRef.put(compressedFile, {
                contentType: compressedFile.type,
                cacheControl: 'public, max-age=31536000'
            });
            
            const downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.push(downloadUrl);
            
        } catch (error) {
            console.error('Error uploading image:', error);
            throw error;
        }
    }
    
    return imageUrls;
}

// Edit item
function editItem(itemId) {
    const item = items.find(i => i.id === itemId);
    if (!item) return;
    
    editingItemId = itemId;
    
    // Populate form
    document.getElementById('itemTitle').value = item.title;
    document.getElementById('itemCategory').value = item.category;
    document.getElementById('itemArtist').value = item.artist;
    document.getElementById('itemPrice').value = item.price;
    document.getElementById('itemYear').value = item.year || '';
    document.getElementById('itemDimensions').value = item.dimensions || '';
    document.getElementById('itemMaterials').value = item.materials || '';
    document.getElementById('itemLocation').value = item.location || '';
    document.getElementById('itemStatus').value = item.status;
    document.getElementById('itemFeatured').checked = item.featured || false;
    document.getElementById('itemDescription').value = item.description;
    
    // Show existing images
    const previewDiv = document.getElementById('imagePreview');
    previewDiv.innerHTML = '';
    if (item.images && item.images.length > 0) {
        previewDiv.style.display = 'flex';
        item.images.forEach(url => {
            const container = document.createElement('div');
            container.className = 'gallery-thumb-container';
            
            const img = document.createElement('img');
            img.src = url;
            img.className = 'gallery-thumb';
            
            container.appendChild(img);
            previewDiv.appendChild(container);
        });
    }
    
    // Update modal title
    document.getElementById('itemModalLabel').textContent = 'Edit Item';
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('itemModal'));
    modal.show();
}

// View item details
function viewItem(itemId) {
    const item = items.find(i => i.id === itemId);
    if (!item) return;
    
    const detailsHTML = `
        <div class="row">
            <div class="col-md-6">
                ${item.images && item.images[0] ? 
                    `<img src="${item.images[0]}" class="img-fluid rounded mb-3" alt="${item.title}">` : 
                    '<p class="text-muted">No image available</p>'}
                ${item.images && item.images.length > 1 ? `
                    <div class="image-gallery">
                        ${item.images.slice(1).map(url => `
                            <img src="${url}" class="gallery-thumb" alt="${item.title}">
                        `).join('')}
                    </div>
                ` : ''}
            </div>
            <div class="col-md-6">
                <h4>${item.title}</h4>
                <p class="text-muted">${item.artist}</p>
                <h5 class="text-success mb-3">₹${formatPrice(item.price)}</h5>
                <p>${item.description}</p>
                <hr>
                <dl class="row">
                    <dt class="col-sm-4">Category:</dt>
                    <dd class="col-sm-8"><span class="badge bg-${getCategoryColor(item.category)}">${item.category}</span></dd>
                    
                    <dt class="col-sm-4">Status:</dt>
                    <dd class="col-sm-8"><span class="status-badge status-${item.status}">${item.status}</span></dd>
                    
                    ${item.year ? `
                    <dt class="col-sm-4">Year:</dt>
                    <dd class="col-sm-8">${item.year}</dd>
                    ` : ''}
                    
                    ${item.dimensions ? `
                    <dt class="col-sm-4">Dimensions:</dt>
                    <dd class="col-sm-8">${item.dimensions}</dd>
                    ` : ''}
                    
                    ${item.materials ? `
                    <dt class="col-sm-4">Materials:</dt>
                    <dd class="col-sm-8">${item.materials}</dd>
                    ` : ''}
                    
                    ${item.location ? `
                    <dt class="col-sm-4">Location:</dt>
                    <dd class="col-sm-8">${item.location}</dd>
                    ` : ''}
                    
                    <dt class="col-sm-4">Views:</dt>
                    <dd class="col-sm-8">${item.views || 0}</dd>
                    
                    <dt class="col-sm-4">Rating:</dt>
                    <dd class="col-sm-8">${(item.rating || 0).toFixed(1)} / 5.0</dd>
                    
                    <dt class="col-sm-4">Featured:</dt>
                    <dd class="col-sm-8">${item.featured ? '<i class="fas fa-check text-success"></i> Yes' : '<i class="fas fa-times text-danger"></i> No'}</dd>
                </dl>
            </div>
        </div>
    `;
    
    // Create or update modal
    let detailsModal = document.getElementById('itemDetailsModal');
    if (!detailsModal) {
        detailsModal = document.createElement('div');
        detailsModal.id = 'itemDetailsModal';
        detailsModal.className = 'modal fade';
        detailsModal.innerHTML = `
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Item Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="itemDetailsContent"></div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="editItem('${itemId}'); bootstrap.Modal.getInstance(document.getElementById('itemDetailsModal')).hide();">
                            <i class="fas fa-edit me-2"></i>Edit
                        </button>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(detailsModal);
    }
    
    document.getElementById('itemDetailsContent').innerHTML = detailsHTML;
    const modal = new bootstrap.Modal(detailsModal);
    modal.show();
}

// Delete item
async function deleteItem(itemId) {
    if (!confirm('Are you sure you want to delete this item? This action cannot be undone.')) {
        return;
    }
    
    try {
        const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
        loadingModal.show();
        
        // Delete from Firestore
        await db.collection('arts_antiques').doc(itemId).delete();
        
        // Delete images from Storage (optional - be careful with this)
        // You might want to keep images for backup purposes
        
        loadingModal.hide();
        showAlert('Item deleted successfully!', 'success');
        
        await loadItems();
        await loadStats();
        
    } catch (error) {
        console.error('Error deleting item:', error);
        showAlert('Failed to delete item. Please try again.', 'danger');
        const loadingModal = bootstrap.Modal.getInstance(document.getElementById('loadingModal'));
        if (loadingModal) loadingModal.hide();
    }
}

// Reset form
function resetForm() {
    document.getElementById('itemForm').reset();
    document.getElementById('imagePreview').innerHTML = '';
    document.getElementById('imagePreview').style.display = 'none';
    document.getElementById('itemModalLabel').textContent = 'Add New Item';
    editingItemId = null;
    uploadedImages = [];
}

// Show loading
function showLoading(show) {
    // Could add a loading overlay here if needed
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
function getCategoryColor(category) {
    const colors = {
        'Paintings': 'primary',
        'Sculptures': 'info',
        'Antiques': 'warning',
        'Jewelry': 'success',
        'Collectibles': 'secondary',
        'Textiles': 'danger'
    };
    return colors[category] || 'secondary';
}

function formatPrice(price) {
    if (price >= 10000000) {
        return (price / 10000000).toFixed(2) + ' Cr';
    } else if (price >= 100000) {
        return (price / 100000).toFixed(2) + ' Lakh';
    } else {
        return price.toLocaleString('en-IN');
    }
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

// Sample data for demonstration
function getSampleItems() {
    return [
        {
            id: 'sample1',
            title: 'Abstract Masterpiece',
            category: 'Paintings',
            artist: 'John Artist',
            price: 5000000,
            year: 2020,
            dimensions: '36x48 inches',
            materials: 'Oil on canvas',
            location: 'Mumbai, India',
            status: 'active',
            featured: true,
            description: 'A stunning abstract painting that captures the essence of modern art.',
            images: ['https://images.unsplash.com/photo-1561214115-f2f134cc4912?w=500'],
            views: 245,
            rating: 4.5,
            createdAt: new Date().toISOString()
        },
        {
            id: 'sample2',
            title: 'Classical Sculpture',
            category: 'Sculptures',
            artist: 'Jane Sculptor',
            price: 8500000,
            year: 2019,
            dimensions: '24x18x12 inches',
            materials: 'Bronze',
            location: 'Delhi, India',
            status: 'active',
            featured: true,
            description: 'An exquisite bronze sculpture inspired by classical art.',
            images: ['https://images.unsplash.com/photo-1580696769210-346c2e9e9c50?w=500'],
            views: 189,
            rating: 4.8,
            createdAt: new Date().toISOString()
        },
        {
            id: 'sample3',
            title: 'Vintage Jewelry Set',
            category: 'Jewelry',
            artist: 'Heritage Jewelers',
            price: 3500000,
            year: 1950,
            dimensions: 'Necklace & Earrings',
            materials: 'Gold, Diamonds',
            location: 'Jaipur, India',
            status: 'active',
            featured: false,
            description: 'A rare vintage jewelry set from the mid-20th century.',
            images: ['https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500'],
            views: 312,
            rating: 4.9,
            createdAt: new Date().toISOString()
        }
    ];
}

// Modal event listeners
document.getElementById('itemModal')?.addEventListener('hidden.bs.modal', function () {
    resetForm();
});

// Export functions for global access
window.artsAntiquesAdmin = {
    loadItems,
    loadStats,
    saveItem,
    editItem,
    viewItem,
    deleteItem,
    applyFilters,
    clearFilters,
    changePage
};

