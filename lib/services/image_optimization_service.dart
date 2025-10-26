import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';

/// Service for optimizing images before upload and managing responsive images
class ImageOptimizationService extends GetxService {
  
  // Image quality settings
  static const int _defaultQuality = 85;
  static const int _thumbnailQuality = 85; // Improved thumbnail quality
  static const int _highQuality = 95;
  
  // Image size limits
  static const int _maxWidth = 1920;
  static const int _maxHeight = 1080;
  static const int _thumbnailSize = 400; // Increased thumbnail size for better quality
  
  // File size limits (in bytes)
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  
  /// Compress image for upload with optimal settings
  Future<Uint8List> compressImageForUpload({
    required File imageFile,
    int quality = _defaultQuality,
    int maxWidth = _maxWidth,
    int maxHeight = _maxHeight,
    int minWidth = 0,
    int minHeight = 0,
  }) async {
    try {
      print('🗜️ Compressing image: ${imageFile.path}');
      
      // Get original image info
      final originalBytes = await imageFile.readAsBytes();
      final originalSize = originalBytes.length;
      print('📏 Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // Use flutter_image_compress for better compression
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: minWidth > 0 ? minWidth : maxWidth,
        minHeight: minHeight > 0 ? minHeight : maxHeight,
        format: CompressFormat.jpeg, // Use JPEG for better compression
        keepExif: false, // Remove EXIF data to reduce size
      );
      
      if (compressedBytes == null) {
        throw Exception('Failed to compress image');
      }
      
      final compressedSize = compressedBytes.length;
      final compressionRatio = (1 - compressedSize / originalSize) * 100;
      
      print('✅ Compressed size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('📊 Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');
      
      // If still too large, apply additional compression
      if (compressedSize > _maxFileSize) {
        print('⚠️ File still too large, applying additional compression...');
        return await _applyAdditionalCompression(compressedBytes, quality);
      }
      
      return compressedBytes;
      
    } catch (e) {
      print('❌ Error compressing image: $e');
      // Fallback to original file
      return await imageFile.readAsBytes();
    }
  }
  
  /// Apply additional compression if file is still too large
  Future<Uint8List> _applyAdditionalCompression(Uint8List imageBytes, int originalQuality) async {
    try {
      // Decode image
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception('Could not decode image for additional compression');
      }
      
      // Calculate new dimensions (reduce by 20%)
      final newWidth = (decodedImage.width * 0.8).round();
      final newHeight = (decodedImage.height * 0.8).round();
      
      // Resize image
      final resizedImage = img.copyResize(
        decodedImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.average,
      );
      
      // Reduce quality further
      final newQuality = (originalQuality * 0.8).round().clamp(50, 95);
      
      // Encode with reduced quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: newQuality);
      
      print('🔧 Additional compression applied: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      return compressedBytes;
      
    } catch (e) {
      print('❌ Error in additional compression: $e');
      return imageBytes; // Return original if compression fails
    }
  }
  
  /// Create thumbnail version of image
  Future<Uint8List> createThumbnail({
    required File imageFile,
    int size = _thumbnailSize,
    int quality = _thumbnailQuality,
  }) async {
    try {
      print('🖼️ Creating thumbnail for: ${imageFile.path}');
      
      final thumbnailBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: size,
        minHeight: size,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      
      if (thumbnailBytes == null) {
        throw Exception('Failed to create thumbnail');
      }
      
      print('✅ Thumbnail created: ${(thumbnailBytes.length / 1024).toStringAsFixed(1)} KB');
      return thumbnailBytes;
      
    } catch (e) {
      print('❌ Error creating thumbnail: $e');
      // Fallback to compressed version
      return await compressImageForUpload(
        imageFile: imageFile,
        quality: quality,
        maxWidth: size,
        maxHeight: size,
      );
    }
  }
  
  /// Generate multiple image sizes for responsive loading
  Future<Map<String, Uint8List>> generateResponsiveImages({
    required File imageFile,
    List<int> sizes = const [150, 300, 600, 1200],
  }) async {
    try {
      print('📱 Generating responsive images for: ${imageFile.path}');
      
      final Map<String, Uint8List> responsiveImages = {};
      
      for (final size in sizes) {
        final quality = _getQualityForSize(size);
        final imageBytes = await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          quality: quality,
          minWidth: size,
          minHeight: size,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
        
        if (imageBytes != null) {
          responsiveImages['${size}w'] = imageBytes;
          print('✅ Generated ${size}px image: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');
        }
      }
      
      return responsiveImages;
      
    } catch (e) {
      print('❌ Error generating responsive images: $e');
      return {};
    }
  }
  
  /// Get optimal quality setting based on image size
  int _getQualityForSize(int size) {
    if (size <= 150) return 80; // Improved quality for small images
    if (size <= 300) return 85; // Improved quality for medium images
    if (size <= 600) return 88; // Improved quality for large images
    if (size <= 1200) return 92; // Improved quality for very large images
    return 95;
  }
  
  /// Optimize image for specific use case
  Future<Uint8List> optimizeForUseCase({
    required File imageFile,
    required ImageUseCase useCase,
  }) async {
    switch (useCase) {
      case ImageUseCase.profile:
        return await compressImageForUpload(
          imageFile: imageFile,
          quality: _defaultQuality,
          maxWidth: 800,
          maxHeight: 800,
        );
        
      case ImageUseCase.propertyMain:
        return await compressImageForUpload(
          imageFile: imageFile,
          quality: _highQuality,
          maxWidth: _maxWidth,
          maxHeight: _maxHeight,
        );
        
      case ImageUseCase.propertyGallery:
        return await compressImageForUpload(
          imageFile: imageFile,
          quality: _defaultQuality,
          maxWidth: 1200,
          maxHeight: 1200,
        );
        
      case ImageUseCase.thumbnail:
        return await createThumbnail(
          imageFile: imageFile,
          size: _thumbnailSize,
          quality: _thumbnailQuality,
        );
        
      case ImageUseCase.avatar:
        return await compressImageForUpload(
          imageFile: imageFile,
          quality: _thumbnailQuality,
          maxWidth: 300, // Increased size for better quality
          maxHeight: 300,
        );
    }
  }
  
  /// Get optimal image dimensions for display
  Map<String, int> getOptimalDimensions({
    required double displayWidth,
    required double displayHeight,
    double devicePixelRatio = 2.0,
  }) {
    // Calculate optimal dimensions based on display size and device pixel ratio
    final optimalWidth = (displayWidth * devicePixelRatio).round();
    final optimalHeight = (displayHeight * devicePixelRatio).round();
    
    // Ensure minimum quality
    final width = optimalWidth.clamp(300, _maxWidth);
    final height = optimalHeight.clamp(300, _maxHeight);
    
    return {
      'width': width,
      'height': height,
      'quality': _getQualityForSize(width),
    };
  }
  
  /// Validate image file
  Future<ImageValidationResult> validateImage(File imageFile) async {
    try {
      // Check file exists
      if (!await imageFile.exists()) {
        return ImageValidationResult.error('File does not exist');
      }
      
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > _maxFileSize * 2) { // Allow 2x max size for original
        return ImageValidationResult.error('File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB');
      }
      
      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        return ImageValidationResult.error('Unsupported file format: $extension');
      }
      
      // Try to decode image
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        return ImageValidationResult.error('Invalid image file');
      }
      
      // Check image dimensions
      if (decodedImage.width < 100 || decodedImage.height < 100) {
        return ImageValidationResult.error('Image too small: ${decodedImage.width}x${decodedImage.height}');
      }
      
      return ImageValidationResult.success(
        width: decodedImage.width,
        height: decodedImage.height,
        size: fileSize,
        format: extension,
      );
      
    } catch (e) {
      return ImageValidationResult.error('Validation error: $e');
    }
  }
}

/// Image use cases for optimization
enum ImageUseCase {
  profile,
  propertyMain,
  propertyGallery,
  thumbnail,
  avatar,
}

/// Image validation result
class ImageValidationResult {
  final bool isValid;
  final String? error;
  final int? width;
  final int? height;
  final int? size;
  final String? format;
  
  ImageValidationResult.success({
    required this.width,
    required this.height,
    required this.size,
    required this.format,
  }) : isValid = true, error = null;
  
  ImageValidationResult.error(this.error) : isValid = false, width = null, height = null, size = null, format = null;
}
