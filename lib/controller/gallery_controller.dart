import 'package:get/get.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class GalleryController extends GetxController {
  // Property photos from Firebase
  RxList<String> propertyPhotos = <String>[].obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // View mode (grid or list)
  RxBool isGridView = true.obs;
  
  // Fallback hardcoded images
  RxList<String> hallImageList = [
    Assets.images.hall1.path,
    Assets.images.hall2.path,
    Assets.images.hall3.path,
  ].obs;

  /// Initialize gallery with property photos
  void initializeGallery(List<String> photos) {
    propertyPhotos.value = photos;
    print('🖼️ Gallery initialized with ${photos.length} property photos');
  }

  /// Get all images to display (property photos + fallback images)
  List<String> getAllImages() {
    if (propertyPhotos.isNotEmpty) {
      return propertyPhotos;
    }
    // Fallback to hardcoded images if no property photos
    return hallImageList;
  }

  /// Toggle between grid and list view
  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
