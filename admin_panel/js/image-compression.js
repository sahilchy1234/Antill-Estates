/**
 * Image Compression Utility for Admin Panel
 * Compresses images before uploading to Firebase Storage
 * This improves upload speed and reduces storage costs
 */

/**
 * Compress an image file
 * @param {File} file - The image file to compress
 * @param {Object} options - Compression options
 * @returns {Promise<File>} - Compressed image file
 */
async function compressImage(file, options = {}) {
    // Default compression options
    const defaultOptions = {
        maxSizeMB: 1, // Maximum file size in MB
        maxWidthOrHeight: 1920, // Maximum width or height
        useWebWorker: true,
        fileType: file.type,
        initialQuality: 0.8 // Quality from 0 to 1
    };
    
    const compressionOptions = { ...defaultOptions, ...options };
    
    try {
        console.log(`Original file size: ${(file.size / 1024 / 1024).toFixed(2)} MB`);
        
        // Compress the image
        const compressedFile = await imageCompression(file, compressionOptions);
        
        console.log(`Compressed file size: ${(compressedFile.size / 1024 / 1024).toFixed(2)} MB`);
        console.log(`Compression ratio: ${((1 - compressedFile.size / file.size) * 100).toFixed(2)}%`);
        
        return compressedFile;
    } catch (error) {
        console.error('Error compressing image:', error);
        // Return original file if compression fails
        console.warn('Returning original file due to compression error');
        return file;
    }
}

/**
 * Compress multiple images
 * @param {FileList|Array} files - Array of image files to compress
 * @param {Object} options - Compression options
 * @returns {Promise<Array<File>>} - Array of compressed image files
 */
async function compressMultipleImages(files, options = {}) {
    const compressedFiles = [];
    const fileArray = Array.from(files);
    
    console.log(`Compressing ${fileArray.length} images...`);
    
    for (let i = 0; i < fileArray.length; i++) {
        const file = fileArray[i];
        
        if (!file.type.startsWith('image/')) {
            console.warn(`File ${file.name} is not an image, skipping compression`);
            compressedFiles.push(file);
            continue;
        }
        
        console.log(`Compressing image ${i + 1}/${fileArray.length}: ${file.name}`);
        const compressedFile = await compressImage(file, options);
        compressedFiles.push(compressedFile);
    }
    
    console.log('All images compressed successfully');
    return compressedFiles;
}

/**
 * Compress property images (multiple large images)
 * @param {FileList|Array} files - Property image files
 * @returns {Promise<Array<File>>} - Compressed files
 */
async function compressPropertyImages(files) {
    return await compressMultipleImages(files, {
        maxSizeMB: 1.5, // Larger size for property images
        maxWidthOrHeight: 1920,
        initialQuality: 0.85
    });
}

/**
 * Compress avatar image (single small image)
 * @param {File} file - Avatar image file
 * @returns {Promise<File>} - Compressed file
 */
async function compressAvatarImage(file) {
    return await compressImage(file, {
        maxSizeMB: 0.3, // Smaller size for avatars
        maxWidthOrHeight: 500,
        initialQuality: 0.8
    });
}

/**
 * Compress project image (single large image)
 * @param {File} file - Project image file
 * @returns {Promise<File>} - Compressed file
 */
async function compressProjectImage(file) {
    return await compressImage(file, {
        maxSizeMB: 1.2,
        maxWidthOrHeight: 1920,
        initialQuality: 0.85
    });
}

/**
 * Compress arts & antiques image (high quality for artwork)
 * @param {File} file - Arts & antiques image file
 * @returns {Promise<File>} - Compressed file
 */
async function compressArtsAntiquesImage(file) {
    return await compressImage(file, {
        maxSizeMB: 2, // Higher quality for artwork
        maxWidthOrHeight: 2048, // Larger dimensions for detail
        initialQuality: 0.9 // Higher quality for art
    });
}

/**
 * Show compression progress (optional UI feedback)
 * @param {number} progress - Progress percentage (0-100)
 */
function showCompressionProgress(progress) {
    // Create or update progress indicator
    let progressIndicator = document.getElementById('compressionProgress');
    
    if (!progressIndicator) {
        progressIndicator = document.createElement('div');
        progressIndicator.id = 'compressionProgress';
        progressIndicator.className = 'compression-progress';
        progressIndicator.innerHTML = `
            <div class="compression-progress-bar">
                <div class="compression-progress-fill" style="width: 0%"></div>
            </div>
            <div class="compression-progress-text">Compressing images...</div>
        `;
        document.body.appendChild(progressIndicator);
        
        // Add styles if not already present
        if (!document.getElementById('compressionProgressStyles')) {
            const style = document.createElement('style');
            style.id = 'compressionProgressStyles';
            style.textContent = `
                .compression-progress {
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    background: white;
                    padding: 15px;
                    border-radius: 8px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                    z-index: 9999;
                    min-width: 250px;
                }
                .compression-progress-bar {
                    width: 100%;
                    height: 8px;
                    background: #e0e0e0;
                    border-radius: 4px;
                    overflow: hidden;
                    margin-bottom: 8px;
                }
                .compression-progress-fill {
                    height: 100%;
                    background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
                    transition: width 0.3s ease;
                }
                .compression-progress-text {
                    font-size: 14px;
                    color: #333;
                    text-align: center;
                }
            `;
            document.head.appendChild(style);
        }
    }
    
    const fillElement = progressIndicator.querySelector('.compression-progress-fill');
    const textElement = progressIndicator.querySelector('.compression-progress-text');
    
    if (fillElement) {
        fillElement.style.width = `${progress}%`;
    }
    
    if (textElement) {
        textElement.textContent = `Compressing images... ${progress}%`;
    }
    
    // Remove progress indicator when complete
    if (progress >= 100) {
        setTimeout(() => {
            progressIndicator.remove();
        }, 1000);
    }
}

/**
 * Validate image file
 * @param {File} file - File to validate
 * @param {Object} options - Validation options
 * @returns {Object} - Validation result {valid: boolean, error: string}
 */
function validateImageFile(file, options = {}) {
    const defaultOptions = {
        maxSizeMB: 20, // Maximum original file size
        allowedTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']
    };
    
    const validationOptions = { ...defaultOptions, ...options };
    
    // Check if file exists
    if (!file) {
        return { valid: false, error: 'No file provided' };
    }
    
    // Check file type
    if (!validationOptions.allowedTypes.includes(file.type)) {
        return { 
            valid: false, 
            error: `Invalid file type. Allowed types: ${validationOptions.allowedTypes.join(', ')}` 
        };
    }
    
    // Check file size
    const fileSizeMB = file.size / 1024 / 1024;
    if (fileSizeMB > validationOptions.maxSizeMB) {
        return { 
            valid: false, 
            error: `File too large. Maximum size: ${validationOptions.maxSizeMB}MB` 
        };
    }
    
    return { valid: true, error: null };
}

// Export functions for use in other scripts
window.imageCompressor = {
    compressImage,
    compressMultipleImages,
    compressPropertyImages,
    compressAvatarImage,
    compressProjectImage,
    compressArtsAntiquesImage,
    showCompressionProgress,
    validateImageFile
};

