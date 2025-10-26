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
const auth = firebase.auth();
const db = firebase.firestore();
const functions = firebase.functions();
const storage = firebase.storage();

// Global variables
let projects = [];
let filteredProjects = [];
let currentEditingProject = null;

// Price formatting utility
function formatPrice(priceString) {
    if (!priceString || priceString.trim() === '') return '₹0';
    
    // Remove existing ₹ symbol and extra spaces
    let cleanPrice = priceString.replace(/₹/g, '').trim();
    
    // Handle range prices (e.g., "45 Lakh - 1 Cr")
    if (cleanPrice.includes(' - ')) {
        const parts = cleanPrice.split(' - ');
        const minPrice = formatSinglePrice(parts[0].trim());
        const maxPrice = formatSinglePrice(parts[1].trim());
        return `${minPrice} - ${maxPrice}`;
    }
    
    // Handle single price
    return formatSinglePrice(cleanPrice);
}

function formatSinglePrice(price) {
    if (!price || price.trim() === '') return '₹0';
    
    // Handle different formats
    if (price.toLowerCase().includes('lakh')) {
        return formatLakhPrice(price);
    } else if (price.toLowerCase().includes('cr') || price.toLowerCase().includes('crore')) {
        return formatCrorePrice(price);
    } else if (price.toLowerCase().includes('k') && !price.toLowerCase().includes('lakh')) {
        return formatThousandPrice(price);
    } else {
        // Assume it's a raw number
        return formatRawNumber(price);
    }
}

function formatLakhPrice(price) {
    // Extract number from "45 Lakh" format
    const match = price.match(/(\d+(?:\.\d+)?)/);
    
    if (match) {
        const lakhValue = parseFloat(match[1]);
        const rupees = Math.round(lakhValue * 100000);
        return formatRawNumber(rupees.toString());
    }
    
    return '₹0';
}

function formatCrorePrice(price) {
    // Extract number from "1 Cr" format
    const match = price.match(/(\d+(?:\.\d+)?)/);
    
    if (match) {
        const croreValue = parseFloat(match[1]);
        const rupees = Math.round(croreValue * 10000000);
        return formatRawNumber(rupees.toString());
    }
    
    return '₹0';
}

function formatThousandPrice(price) {
    // Extract number from "45K" format
    const match = price.match(/(\d+(?:\.\d+)?)/);
    
    if (match) {
        const thousandValue = parseFloat(match[1]);
        const rupees = Math.round(thousandValue * 1000);
        return formatRawNumber(rupees.toString());
    }
    
    return '₹0';
}

function formatRawNumber(numberString) {
    // Remove any non-digit characters except decimal point
    const cleanNumber = numberString.replace(/[^\d.]/g, '');
    
    if (!cleanNumber) return '₹0';
    
    // Parse the number
    const number = parseFloat(cleanNumber);
    const rupees = Math.round(number);
    
    // Format with Indian numbering system
    if (rupees >= 10000000) { // 1 Crore and above
        const crores = rupees / 10000000;
        if (crores === Math.round(crores)) {
            return `₹${Math.round(crores).toLocaleString('en-IN')} Cr`;
        } else {
            return `₹${crores.toFixed(1).replace(/\B(?=(\d{2})+(?!\d))/g, ',')} Cr`;
        }
    } else if (rupees >= 100000) { // 1 Lakh and above
        const lakhs = rupees / 100000;
        if (lakhs === Math.round(lakhs)) {
            return `₹${Math.round(lakhs).toLocaleString('en-IN')} Lakh`;
        } else {
            return `₹${lakhs.toFixed(1).replace(/\B(?=(\d{2})+(?!\d))/g, ',')} Lakh`;
        }
    } else {
        // Below 1 Lakh - use standard comma formatting
        return `₹${rupees.toLocaleString('en-IN')}`;
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded, initializing projects admin panel...');
    initializeAdminAuth();
    setupEventListeners();
    setupImageUpload();
});

// Initialize admin authentication
async function initializeAdminAuth() {
    try {
        console.log('Initializing admin authentication...');
        
        // For now, we'll use anonymous authentication for admin panel
        // In production, you should implement proper admin authentication
        await firebase.auth().signInAnonymously();
        
        console.log('Admin authentication successful');
        console.log('Current user:', firebase.auth().currentUser);
        
        // Load data after authentication
        await loadProjects();
        await loadProjectStats();
        
    } catch (error) {
        console.error('Admin authentication failed:', error);
        showAlert('Authentication failed. Some features may not work properly.', 'warning');
        
        // Still try to load data (read-only mode)
        await loadProjects();
        await loadProjectStats();
    }
}

// Setup event listeners
function setupEventListeners() {
    // Search functionality
    document.getElementById('searchInput').addEventListener('input', filterProjects);
    document.getElementById('statusFilter').addEventListener('change', filterProjects);
    document.getElementById('sortBy').addEventListener('change', sortProjects);

    // Sidebar toggle for mobile
    const sidebarToggle = document.getElementById('sidebarToggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('show');
        });
    }

    // Form submission
    const projectForm = document.getElementById('projectForm');
    if (projectForm) {
        projectForm.addEventListener('submit', function(e) {
            e.preventDefault();
            saveProject();
        });
    }
}

// Setup image upload
function setupImageUpload() {
    console.log('Setting up image upload...');
    
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('projectImage');
    const previewDiv = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    
    console.log('Elements found:', {
        uploadArea: !!uploadArea,
        fileInput: !!fileInput,
        previewDiv: !!previewDiv,
        previewImg: !!previewImg
    });
    
    if (!uploadArea || !fileInput || !previewDiv || !previewImg) {
        console.error('Image upload elements not found:', {
            uploadArea: !!uploadArea,
            fileInput: !!fileInput,
            previewDiv: !!previewDiv,
            previewImg: !!previewImg
        });
        
        // Try again after a longer delay
        setTimeout(() => {
            console.log('Retrying image upload setup...');
            setupImageUpload();
        }, 1000);
        return;
    }
    
    console.log('Image upload elements found, setting up event listeners...');
    
    // Click handler for upload area - simplified like property page
    uploadArea.addEventListener('click', () => {
        console.log('Upload area clicked, opening file dialog...');
        fileInput.click();
    });
    
    // File selection handler
    fileInput.addEventListener('change', (e) => {
        console.log('File input changed');
        const file = e.target.files[0];
        if (file) {
            console.log('File selected:', file.name, file.type, file.size);
            handleFileSelection(file);
        }
    });
    
    // Drag and drop handlers - simplified like property page
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
            const file = files[0];
            console.log('File dropped:', file.name, file.type, file.size);
            
            // Create a new FileList with the dropped file
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            fileInput.files = dataTransfer.files;
            
            handleFileSelection(file);
        }
    });
    
    console.log('Image upload setup completed');
}

// Handle file selection
function handleFileSelection(file) {
    console.log('Processing file selection:', file.name);
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showAlert('Please select an image file (PNG, JPG, GIF)', 'warning');
        return;
    }
    
    // Validate file size (20MB limit)
    if (file.size > 20 * 1024 * 1024) {
        showAlert('Image file is too large. Maximum size is 20MB', 'warning');
        return;
    }
    
    console.log('File validation passed, showing preview...');
    
    const reader = new FileReader();
    reader.onload = (e) => {
        const previewImg = document.getElementById('previewImg');
        const previewDiv = document.getElementById('imagePreview');
        if (previewImg && previewDiv) {
            previewImg.src = e.target.result;
            previewDiv.style.display = 'block';
            console.log('Image preview loaded');
        }
    };
    reader.readAsDataURL(file);
}

// Load projects
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
                updateProjectsDisplay();
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
        updateProjectsDisplay();
        
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
        
        updateProjectsDisplay();
        showAlert('Loaded sample projects for demonstration. Add your first project using the form above.', 'info');
    }
}

// Update projects display
function updateProjectsDisplay() {
    filteredProjects = [...projects];
    renderProjects();
}

// Render projects
function renderProjects() {
    const container = document.getElementById('projectsGrid');
    const emptyState = document.getElementById('emptyState');
    
    if (filteredProjects.length === 0) {
        if (container) container.innerHTML = '';
        if (emptyState) emptyState.style.display = 'block';
        return;
    }
    
    if (emptyState) emptyState.style.display = 'none';
    
    if (container) {
        container.innerHTML = filteredProjects.map(project => `
            <div class="project-card">
                <img src="${project.imageUrl}" class="project-image" alt="${project.title}">
                <div class="project-content">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <h5 class="project-title">${project.title}</h5>
                        <span class="status-badge status-${project.status}">${project.status}</span>
                    </div>
                    <div class="project-price">${formatPrice(project.price)}</div>
                    <div class="project-details">
                        <div class="mb-2">
                            <i class="fas fa-map-marker-alt me-2"></i>
                            ${project.address}
                        </div>
                        <div class="mb-2">
                            <i class="fas fa-home me-2"></i>
                            ${project.flatSize}
                        </div>
                        <div class="mb-2">
                            <i class="fas fa-building me-2"></i>
                            ${project.builder}
                        </div>
                        ${project.description ? `<div class="mb-2"><i class="fas fa-info-circle me-2"></i>${project.description}</div>` : ''}
                    </div>
                    <div class="project-actions">
                        <button class="btn btn-outline-primary btn-sm" onclick="viewProject('${project.id}')">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-outline-warning btn-sm" onclick="editProject('${project.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-outline-danger btn-sm" onclick="deleteProject('${project.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `).join('');
    }
}

// Filter projects
function filterProjects() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    
    if (!searchInput || !statusFilter) return;
    
    const searchTerm = searchInput.value.toLowerCase();
    const statusValue = statusFilter.value;
    
    filteredProjects = projects.filter(project => {
        const matchesSearch = project.title.toLowerCase().includes(searchTerm) ||
                            project.address.toLowerCase().includes(searchTerm) ||
                            project.builder.toLowerCase().includes(searchTerm);
        const matchesStatus = !statusValue || project.status === statusValue;
        
        return matchesSearch && matchesStatus;
    });
    
    sortProjects();
}

// Sort projects
function sortProjects() {
    const sortBy = document.getElementById('sortBy');
    if (!sortBy) return;
    
    const sortValue = sortBy.value;
    
    filteredProjects.sort((a, b) => {
        switch (sortValue) {
            case 'title':
                return a.title.localeCompare(b.title);
            case 'price':
                // Extract numeric value from price for sorting
                const priceA = parseFloat(a.price.replace(/[^\d]/g, ''));
                const priceB = parseFloat(b.price.replace(/[^\d]/g, ''));
                return priceB - priceA;
            case 'status':
                return a.status.localeCompare(b.status);
            case 'createdAt':
            default:
                return new Date(b.createdAt) - new Date(a.createdAt);
        }
    });
    
    renderProjects();
}

// Reset filters
function resetFilters() {
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const sortBy = document.getElementById('sortBy');
    
    if (searchInput) searchInput.value = '';
    if (statusFilter) statusFilter.value = '';
    if (sortBy) sortBy.value = 'createdAt';
    
    filterProjects();
}

// View project details
function viewProject(projectId) {
    const project = projects.find(p => p.id === projectId);
    if (!project) return;
    
    const modal = new bootstrap.Modal(document.getElementById('projectDetailsModal'));
    const content = document.getElementById('projectDetailsContent');
    
    if (content) {
        content.innerHTML = `
            <div class="row">
                <div class="col-md-6">
                    <img src="${project.imageUrl}" class="img-fluid rounded" alt="${project.title}">
                </div>
                <div class="col-md-6">
                    <h4>${project.title}</h4>
                    <p class="text-primary fs-5 fw-bold">${formatPrice(project.price)}</p>
                    <div class="mb-3">
                        <strong>Address:</strong><br>
                        ${project.address}
                    </div>
                    <div class="mb-3">
                        <strong>Flat Sizes:</strong><br>
                        ${project.flatSize}
                    </div>
                    <div class="mb-3">
                        <strong>Builder:</strong><br>
                        ${project.builder}
                    </div>
                    <div class="mb-3">
                        <strong>Status:</strong><br>
                        <span class="status-badge status-${project.status}">${project.status}</span>
                    </div>
                    ${project.description ? `
                    <div class="mb-3">
                        <strong>Description:</strong><br>
                        ${project.description}
                    </div>
                    ` : ''}
                    ${project.launchDate ? `
                    <div class="mb-3">
                        <strong>Launch Date:</strong><br>
                        ${new Date(project.launchDate).toLocaleDateString()}
                    </div>
                    ` : ''}
                    ${project.completionDate ? `
                    <div class="mb-3">
                        <strong>Completion Date:</strong><br>
                        ${new Date(project.completionDate).toLocaleDateString()}
                    </div>
                    ` : ''}
                </div>
            </div>
        `;
    }
    
    modal.show();
}

// Edit project
function editProject(projectId) {
    const project = projects.find(p => p.id === projectId);
    if (!project) return;
    
    currentEditingProject = project;
    
    // Populate form with project data
    const titleInput = document.getElementById('projectTitle');
    const priceInput = document.getElementById('projectPrice');
    const addressInput = document.getElementById('projectAddress');
    const flatSizeInput = document.getElementById('projectFlatSize');
    const builderInput = document.getElementById('projectBuilder');
    const statusInput = document.getElementById('projectStatus');
    const descriptionInput = document.getElementById('projectDescription');
    const launchDateInput = document.getElementById('projectLaunchDate');
    const completionDateInput = document.getElementById('projectCompletionDate');
    const phoneInput = document.getElementById('projectPhone');
    const emailInput = document.getElementById('projectEmail');
    
    if (titleInput) titleInput.value = project.title;
    if (priceInput) priceInput.value = project.price;
    if (addressInput) addressInput.value = project.address;
    if (flatSizeInput) flatSizeInput.value = project.flatSize;
    if (builderInput) builderInput.value = project.builder;
    if (statusInput) statusInput.value = project.status;
    if (descriptionInput) descriptionInput.value = project.description || '';
    if (launchDateInput) launchDateInput.value = project.launchDate || '';
    if (completionDateInput) completionDateInput.value = project.completionDate || '';
    
    // Populate contact information
    if (phoneInput) phoneInput.value = project.contactInfo?.phone || '';
    if (emailInput) emailInput.value = project.contactInfo?.email || '';
    
    // Show preview if image exists
    if (project.imageUrl) {
        const previewImg = document.getElementById('previewImg');
        const previewDiv = document.getElementById('imagePreview');
        if (previewImg && previewDiv) {
            previewImg.src = project.imageUrl;
            previewDiv.style.display = 'block';
        }
    }
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('addProjectModal'));
    modal.show();
}

// Save project
async function saveProject() {
    const titleInput = document.getElementById('projectTitle');
    const priceInput = document.getElementById('projectPrice');
    const addressInput = document.getElementById('projectAddress');
    const flatSizeInput = document.getElementById('projectFlatSize');
    const builderInput = document.getElementById('projectBuilder');
    const statusInput = document.getElementById('projectStatus');
    const descriptionInput = document.getElementById('projectDescription');
    const launchDateInput = document.getElementById('projectLaunchDate');
    const completionDateInput = document.getElementById('projectCompletionDate');
    const phoneInput = document.getElementById('projectPhone');
    const emailInput = document.getElementById('projectEmail');
    const imageInput = document.getElementById('projectImage');
    
    if (!titleInput || !priceInput || !addressInput || !flatSizeInput || !builderInput || !statusInput) {
        showAlert('Please fill in all required fields', 'danger');
        return;
    }
    
    const formData = {
        title: titleInput.value,
        price: priceInput.value,
        address: addressInput.value,
        flatSize: flatSizeInput.value,
        builder: builderInput.value,
        status: statusInput.value,
        description: descriptionInput ? descriptionInput.value : '',
        launchDate: launchDateInput ? launchDateInput.value : '',
        completionDate: completionDateInput ? completionDateInput.value : '',
        contactInfo: {
            phone: phoneInput ? phoneInput.value : '',
            email: emailInput ? emailInput.value : ''
        }
    };
    
    const imageFile = imageInput ? imageInput.files[0] : null;
    
    if (!imageFile && !currentEditingProject) {
        showAlert('Please select an image for the project', 'danger');
        return;
    }
    
    const loadingModal = new bootstrap.Modal(document.getElementById('loadingModal'));
    loadingModal.show();
    
    try {
        let imageUrl = currentEditingProject?.imageUrl;
        
        // Upload new image if provided
        if (imageFile) {
            imageUrl = await uploadProjectImage(imageFile);
        }
        
        formData.imageUrl = imageUrl;
        formData.createdAt = currentEditingProject?.createdAt || new Date().toISOString();
        
        if (currentEditingProject) {
            // Update existing project
            const updateUpcomingProject = functions.httpsCallable('updateUpcomingProject');
            await updateUpcomingProject({
                projectId: currentEditingProject.id,
                ...formData
            });
            showAlert('Project updated successfully!', 'success');
        } else {
            // Add new project
            const addUpcomingProject = functions.httpsCallable('addUpcomingProject');
            await addUpcomingProject(formData);
            showAlert('Project added successfully!', 'success');
        }
        
        // Refresh projects list
        await loadProjects();
        await loadProjectStats();
        
        // Reset form and close modal
        resetProjectForm();
        const modal = bootstrap.Modal.getInstance(document.getElementById('addProjectModal'));
        if (modal) modal.hide();
        
    } catch (error) {
        console.error('Error saving project:', error);
        showAlert('Failed to save project. Please try again.', 'danger');
    } finally {
        loadingModal.hide();
    }
}

// Upload project image
async function uploadProjectImage(file) {
    try {
        console.log('Uploading project image:', file.name);
        console.log('File details:', {
            name: file.name,
            type: file.type,
            size: file.size,
            lastModified: file.lastModified
        });
        
        // Check authentication
        const currentUser = firebase.auth().currentUser;
        if (!currentUser) {
            throw new Error('Not authenticated. Please refresh the page and try again.');
        }
        console.log('User authenticated:', currentUser.uid);
        
        // Validate file type
        if (!file.type.startsWith('image/')) {
            throw new Error('Please select an image file');
        }
        
        // Compress image before upload
        console.log('Compressing project image before upload...');
        const compressedFile = await window.imageCompressor.compressProjectImage(file);
        
        // Validate file size (20MB limit even after compression)
        if (compressedFile.size > 20 * 1024 * 1024) {
            throw new Error('Image file is too large even after compression. Maximum size is 20MB');
        }
        
        const fileName = `projects/${Date.now()}_${compressedFile.name.replace(/[^a-zA-Z0-9.]/g, '_')}`;
        const storageRef = storage.ref().child(fileName);
        
        console.log('Storage reference path:', storageRef.fullPath);
        console.log('Storage bucket:', storage.app.options.storageBucket);
        
        // Upload with metadata
        const uploadTask = storageRef.put(compressedFile, {
            contentType: compressedFile.type,
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
                console.error('Error code:', error.code);
                console.error('Error message:', error.message);
                throw error;
            }
        );
        
        // Wait for upload to complete
        const snapshot = await uploadTask;
        const downloadUrl = await snapshot.ref.getDownloadURL();
        
        console.log('Compressed image uploaded successfully:', downloadUrl);
        return downloadUrl;
        
    } catch (error) {
        console.error('Error uploading project image:', error);
        console.error('Error details:', {
            code: error.code,
            message: error.message,
            stack: error.stack
        });
        
        // Provide specific error messages
        let errorMessage = 'Failed to upload image';
        if (error.code === 'storage/unauthorized') {
            errorMessage = 'Storage access denied. Please check authentication and storage rules.';
        } else if (error.code === 'storage/retry-limit-exceeded') {
            errorMessage = 'Upload failed due to network issues. Please try again.';
        } else if (error.code === 'storage/invalid-format') {
            errorMessage = 'Invalid file format. Please use PNG, JPG, or GIF.';
        } else if (error.code === 'storage/object-not-found') {
            errorMessage = 'Storage bucket not found. Please check Firebase configuration.';
        } else if (error.message) {
            errorMessage = error.message;
        }
        
        throw new Error(errorMessage);
    }
}

// Delete project
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
    const form = document.getElementById('projectForm');
    const previewDiv = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    
    if (form) form.reset();
    if (previewDiv) previewDiv.style.display = 'none';
    if (previewImg) previewImg.src = '';
    
    currentEditingProject = null;
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
                updateProjectStats(result.data);
                return;
            }
        } catch (functionsError) {
            console.log('Functions call failed, calculating stats locally:', functionsError);
        }
        
        // Calculate stats from loaded projects
        const stats = {
            totalProjects: projects.length,
            activeProjects: 0,
            upcomingProjects: 0,
            completedProjects: 0
        };
        
        projects.forEach(project => {
            switch (project.status) {
                case 'upcoming':
                    stats.upcomingProjects++;
                    stats.activeProjects++;
                    break;
                case 'launched':
                case 'ongoing':
                    stats.activeProjects++;
                    break;
                case 'completed':
                    stats.completedProjects++;
                    break;
            }
        });
        
        updateProjectStats(stats);
        
    } catch (error) {
        console.error('Error loading project stats:', error);
    }
}

// Update project stats display
function updateProjectStats(stats) {
    const totalProjects = document.getElementById('totalProjects');
    const activeProjects = document.getElementById('activeProjects');
    const upcomingProjects = document.getElementById('upcomingProjects');
    const completedProjects = document.getElementById('completedProjects');
    
    if (totalProjects) totalProjects.textContent = stats.totalProjects;
    if (activeProjects) activeProjects.textContent = stats.activeProjects;
    if (upcomingProjects) upcomingProjects.textContent = stats.upcomingProjects;
    if (completedProjects) completedProjects.textContent = stats.completedProjects;
}

// Show alert
function showAlert(message, type) {
    const alertContainer = document.getElementById('alertContainer');
    if (!alertContainer) return;
    
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

// Test function for debugging file input
window.testFileInput = function() {
    console.log('=== TESTING FILE INPUT ===');
    const fileInput = document.getElementById('projectImage');
    console.log('File input element:', fileInput);
    console.log('File input type:', fileInput ? fileInput.type : 'null');
    console.log('File input accept:', fileInput ? fileInput.accept : 'null');
    console.log('File input style:', fileInput ? fileInput.style.cssText : 'null');
    console.log('File input display:', fileInput ? window.getComputedStyle(fileInput).display : 'null');
    
    if (fileInput) {
        console.log('Attempting to trigger file input click...');
        try {
            fileInput.click();
            console.log('File input click triggered successfully');
            return true;
        } catch (error) {
            console.error('Error triggering file input:', error);
            return false;
        }
    } else {
        console.error('File input not found!');
        return false;
    }
};

// Export functions for global access
window.projectsAdmin = {
    loadProjects,
    loadProjectStats,
    filterProjects,
    resetFilters,
    saveProject,
    editProject,
    viewProject,
    deleteProject,
    showAlert,
    setupImageUpload,
    testFileInput
};
