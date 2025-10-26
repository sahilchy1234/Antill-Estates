import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:antill_estates/services/image_optimization_service.dart';

class FirebaseStorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late final ImageOptimizationService _imageOptimizationService;
  
  // Observable variables for upload progress
  RxBool isUploading = false.obs;
  RxString uploadProgress = ''.obs;
  RxDouble uploadPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Configure storage settings
    _storage.setMaxUploadRetryTime(Duration(seconds: 30));
    _storage.setMaxDownloadRetryTime(Duration(seconds: 30));
    
    // Initialize image optimization service
    _imageOptimizationService = Get.find<ImageOptimizationService>();
  }

  /// Upload optimized image to Firebase Storage with progress tracking
  Future<String?> uploadOptimizedImage({
    required File imageFile,
    required String userId,
    String folder = 'user_profiles',
    ImageUseCase useCase = ImageUseCase.propertyMain,
    bool createThumbnail = true,
  }) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 'Validating image...';
      uploadPercentage.value = 0.0;

      // Validate image
      final validation = await _imageOptimizationService.validateImage(imageFile);
      if (!validation.isValid) {
        throw Exception('Image validation failed: ${validation.error}');
      }

      uploadProgress.value = 'Optimizing image...';
      uploadPercentage.value = 0.1;

      // Optimize image for the specific use case
      final optimizedBytes = await _imageOptimizationService.optimizeForUseCase(
        imageFile: imageFile,
        useCase: useCase,
      );

      uploadProgress.value = 'Creating thumbnail...';
      uploadPercentage.value = 0.3;

      // Create thumbnail if requested
      Uint8List? thumbnailBytes;
      if (createThumbnail) {
        thumbnailBytes = await _imageOptimizationService.createThumbnail(imageFile: imageFile);
      }

      uploadProgress.value = 'Uploading image...';
      uploadPercentage.value = 0.4;

      // Upload main image
      final mainImageUrl = await _uploadImageBytes(
        imageBytes: optimizedBytes,
        userId: userId,
        folder: folder,
        isThumbnail: false,
      );

      uploadProgress.value = 'Uploading thumbnail...';
      uploadPercentage.value = 0.8;

      // Upload thumbnail if created
      String? thumbnailUrl;
      if (thumbnailBytes != null) {
        thumbnailUrl = await _uploadImageBytes(
          imageBytes: thumbnailBytes,
          userId: userId,
          folder: '${folder}_thumbnails',
          isThumbnail: true,
        );
      }

      uploadProgress.value = 'Upload completed!';
      uploadPercentage.value = 1.0;

      print('✅ Optimized image uploaded successfully: $mainImageUrl');
      if (thumbnailUrl != null) {
        print('✅ Thumbnail uploaded successfully: $thumbnailUrl');
      }

      return mainImageUrl;

    } catch (e) {
      print('❌ Error uploading optimized image: $e');
      uploadProgress.value = 'Upload failed';
      uploadPercentage.value = 0.0;
      throw e;
    } finally {
      isUploading.value = false;
    }
  }

  /// Upload image bytes to Firebase Storage
  Future<String?> _uploadImageBytes({
    required Uint8List imageBytes,
    required String userId,
    required String folder,
    bool isThumbnail = false,
  }) async {
    try {
      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final suffix = isThumbnail ? '_thumb' : '';
      final fileName = '${folder}_${userId}_${timestamp}$suffix.jpg';

      // Create storage reference
      Reference storageRef = _storage
          .ref()
          .child(folder)
          .child(userId)
          .child(fileName);

      // Create metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadTime': DateTime.now().toIso8601String(),
          'isThumbnail': isThumbnail.toString(),
          'originalSize': imageBytes.length.toString(),
        },
      );

      // Start upload task
      UploadTask uploadTask = storageRef.putData(imageBytes, metadata);

      // Wait for completion
      TaskSnapshot taskSnapshot = await uploadTask.timeout(
        Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Upload timeout', Duration(minutes: 5));
        },
      );

      // Verify upload success
      if (taskSnapshot.state != TaskState.success) {
        throw Exception('Upload failed: ${taskSnapshot.state}');
      }

      // Get download URL
      return await taskSnapshot.ref.getDownloadURL();

    } catch (e) {
      print('❌ Error uploading image bytes: $e');
      throw e;
    }
  }

  /// Upload image to Firebase Storage with progress tracking (legacy method)
  Future<String?> uploadImage({
    required File imageFile,
    required String userId,
    String folder = 'user_profiles',
    int maxSizeMB = 10,
  }) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 'Preparing upload...';
      uploadPercentage.value = 0.0;

      // Validate file size
      int fileSizeBytes = await imageFile.length();
      if (fileSizeBytes > maxSizeMB * 1024 * 1024) {
        throw Exception('File size too large. Maximum size is ${maxSizeMB}MB.');
      }

      // Get file extension
      String fileExtension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        fileExtension = 'jpg';
      }

      // Create unique filename
      String fileName = '${folder}_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Create storage reference
      Reference storageRef = _storage
          .ref()
          .child(folder)
          .child(userId)
          .child(fileName);

      // Convert file to bytes
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Create metadata
      String contentType = 'image/$fileExtension';
      if (fileExtension == 'jpg') contentType = 'image/jpeg';

      SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedBy': userId,
          'uploadTime': DateTime.now().toIso8601String(),
          'originalFileName': imageFile.path.split('/').last,
        },
      );

      // Start upload task
      UploadTask uploadTask = storageRef.putData(imageBytes, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        uploadPercentage.value = progress;
        uploadProgress.value = 'Uploading... ${(progress * 100).toInt()}%';
      });

      // Wait for completion with timeout
      TaskSnapshot taskSnapshot = await uploadTask.timeout(
        Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Upload timeout', Duration(minutes: 5));
        },
      );

      // Verify upload success
      if (taskSnapshot.state != TaskState.success) {
        throw Exception('Upload failed: ${taskSnapshot.state}');
      }

      // Get download URL
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      uploadProgress.value = 'Upload completed!';
      uploadPercentage.value = 1.0;

      print('Image uploaded successfully: $downloadURL');
      return downloadURL;

    } catch (e) {
      print('Error uploading image: $e');
      uploadProgress.value = 'Upload failed';
      uploadPercentage.value = 0.0;
      throw e;
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      String path = _extractPathFromUrl(imageUrl);
      if (path.isEmpty) {
        throw Exception('Invalid image URL');
      }

      Reference storageRef = _storage.ref().child(path);
      await storageRef.delete();
      
      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get download URL for a file
  Future<String?> getDownloadURL(String path) async {
    try {
      Reference storageRef = _storage.ref().child(path);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  /// Extract path from Firebase Storage URL
  String _extractPathFromUrl(String url) {
    try {
      // Firebase Storage URLs have a specific format
      // Example: https://firebasestorage.googleapis.com/v0/b/bucket/o/path%2Fto%2Ffile.jpg
      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last;
      return Uri.decodeComponent(path);
    } catch (e) {
      print('Error extracting path from URL: $e');
      return '';
    }
  }

  /// Check if Firebase Storage is available
  Future<bool> isStorageAvailable() async {
    try {
      // Try to access storage bucket
      await _storage.ref().listAll();
      return true;
    } catch (e) {
      print('Firebase Storage not available: $e');
      return false;
    }
  }

  /// Get storage usage info (if available)
  Future<Map<String, dynamic>?> getStorageInfo() async {
    try {
      // This is a placeholder - Firebase Storage doesn't provide direct usage info
      // You would need to track this in Firestore or use Firebase Functions
      return {
        'status': 'available',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return null;
    }
  }
}
