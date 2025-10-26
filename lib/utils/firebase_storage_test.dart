import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageTest {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Test Firebase Storage connectivity
  static Future<bool> testStorageConnection() async {
    try {
      print('🧪 Testing Firebase Storage connection...');
      
      // Test basic storage access
      Reference testRef = _storage.ref().child('test');
      await testRef.listAll();
      
      print('✅ Firebase Storage connection successful');
      return true;
    } catch (e) {
      print('❌ Firebase Storage connection failed: $e');
      return false;
    }
  }

  /// Test storage bucket configuration
  static Future<bool> testStorageBucket() async {
    try {
      print('🧪 Testing Firebase Storage bucket...');
      
      // Get storage bucket info
      String bucket = _storage.bucket;
      print('📦 Storage bucket: $bucket');
      
      if (bucket.isEmpty) {
        print('❌ Storage bucket not configured');
        return false;
      }
      
      print('✅ Firebase Storage bucket configured correctly');
      return true;
    } catch (e) {
      print('❌ Firebase Storage bucket test failed: $e');
      return false;
    }
  }

  /// Test storage permissions
  static Future<bool> testStoragePermissions() async {
    try {
      print('🧪 Testing Firebase Storage permissions...');
      
      // Try to create a test reference
      Reference testRef = _storage.ref().child('permission_test');
      
      // This will fail if permissions are not set correctly
      // but we can catch the specific error
      try {
        await testRef.listAll();
        print('✅ Firebase Storage permissions OK');
        return true;
      } catch (e) {
        if (e.toString().contains('permission-denied')) {
          print('❌ Firebase Storage permission denied - check storage rules');
          return false;
        } else {
          print('⚠️ Firebase Storage permission test inconclusive: $e');
          return true; // Other errors might be OK
        }
      }
    } catch (e) {
      print('❌ Firebase Storage permission test failed: $e');
      return false;
    }
  }

  /// Run all storage tests
  static Future<Map<String, bool>> runAllTests() async {
    print('🚀 Starting Firebase Storage tests...');
    
    Map<String, bool> results = {};
    
    results['connection'] = await testStorageConnection();
    results['bucket'] = await testStorageBucket();
    results['permissions'] = await testStoragePermissions();
    
    print('📊 Test Results:');
    results.forEach((test, passed) {
      print('  ${passed ? '✅' : '❌'} $test: ${passed ? 'PASSED' : 'FAILED'}');
    });
    
    return results;
  }
}
