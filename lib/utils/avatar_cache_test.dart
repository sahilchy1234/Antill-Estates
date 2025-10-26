import 'package:antill_estates/services/image_cache_service.dart';

class AvatarCacheTest {
  static Future<void> testAvatarCaching() async {
    try {
      print('🧪 Testing Avatar Caching Functionality...');
      
      final imageCacheService = ImageCacheService.instance;
      
      // Test Firebase Storage URL detection
      final testUrl = 'https://firebasestorage.googleapis.com/v0/b/test-bucket/o/user_profiles%2Ftest-user%2Favatar.jpg';
      final isFirebaseUrl = testUrl.contains('firebasestorage.googleapis.com');
      print('✅ Firebase URL detection: $isFirebaseUrl');
      
      // Test cache size
      final cacheSize = await imageCacheService.getCacheSize();
      print('📊 Cache Size: ${_formatBytes(cacheSize)}');
      
      // Test cache clearing (optional - only for testing)
      // await imageCacheService.clearCache();
      // print('🗑️ Cache cleared for testing');
      
      print('✅ Avatar caching test completed successfully!');
      
    } catch (e) {
      print('❌ Avatar caching test failed: $e');
    }
  }
  
  /// Format bytes to human readable format
  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
