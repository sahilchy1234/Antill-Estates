import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_color.dart';
import 'package:antill_estates/configs/app_size.dart';
import 'package:antill_estates/configs/app_style.dart';
import 'package:antill_estates/common/cached_firebase_image.dart';
import 'package:antill_estates/utils/price_formatter.dart';
import 'package:antill_estates/services/arts_antiques_data_service.dart';

class ArtistDetailsView extends StatefulWidget {
  const ArtistDetailsView({super.key});

  @override
  State<ArtistDetailsView> createState() => _ArtistDetailsViewState();
}

class _ArtistDetailsViewState extends State<ArtistDetailsView> {
  late final String artistName;
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    artistName = (Get.arguments is String) ? Get.arguments as String : '';
    _loadArtistItems();
  }

  Future<void> _loadArtistItems() async {
    setState(() { isLoading = true; });
    final result = await ArtsAntiquesDataService.getItemsByArtist(artistName);
    setState(() {
      items = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        scrolledUnderElevation: 0,
        title: Text(
          artistName.isNotEmpty ? artistName : 'Artist',
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text(
                    'No items found',
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadArtistItems,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSize.appSize16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final images = item['images'] as List?;
                      final price = (item['price'] is num)
                          ? PriceFormatter.formatNumericPrice((item['price'] as num).toDouble())
                          : PriceFormatter.formatPrice('${item['price'] ?? ''}');
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.appSize12)),
                                child: (images?.isNotEmpty ?? false)
                                    ? CachedFirebaseImage(
                                        imageUrl: images!.first,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        cacheWidth: 400,
                                        cacheHeight: 400,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.appSize12)),
                                      )
                                    : Container(
                                        color: AppColor.borderColor,
                                        child: Icon(Icons.image_not_supported, color: AppColor.descriptionColor),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSize.appSize10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'Untitled',
                                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    price,
                                    style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


