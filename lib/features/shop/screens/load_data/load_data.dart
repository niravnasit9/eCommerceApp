import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/appbar/appbar.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:yt_ecommerce_admin_panel/data/abstract/banners.dart';
import 'package:yt_ecommerce_admin_panel/data/abstract/brands.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/banners/banner_repository.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/brnads/brand_repository.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/categories/category_repository.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/product/product_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/cart/cart.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/order/order.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class LoadData extends StatelessWidget {
  const LoadData({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryRepository());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Upload Data',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Record',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Column(
              children: [
                TSettingsMenuTile(
                  icon: Iconsax.category,
                  title: 'Upload Categories',
                  subTitle: 'Upload Categories only one time',
                  trailing: const Icon(Iconsax.document_upload),
                  onTap: () => controller.uploadDummyData,
                ),
                TSettingsMenuTile(
                  icon: Iconsax.shop,
                  title: 'Upload Brands',
                  subTitle: 'Upload Brands only one time',
                  trailing: const Icon(Iconsax.document_upload),
                  onTap: () async {
                    try {
                      await BrandRepository.instance
                          .uploadAllBrands(dummyBrands);
                      Get.snackbar(
                          'Success', 'All brands uploaded successfully!');
                    } catch (e) {
                      Get.snackbar('Error', e.toString());
                    }
                  },
                ),
                TSettingsMenuTile(
                  icon: Iconsax.shopping_cart,
                  title: 'Upload Products',
                  subTitle: 'Upload Products only one time',
                  trailing: const Icon(Iconsax.document_upload),
                  onTap: () async {
                    final productRepo = ProductRepository.instance;

                    try {
                      // Show uploading snackbar
                      Get.snackbar(
                        'Uploading',
                        'Please wait...',
                        showProgressIndicator: true,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 5),
                      );

                      // Check if products already exist
                      final exists =
                          await productRepo.productsAlreadyUploaded();

                      if (exists) {
                        // Replace existing products
                        await productRepo.replaceProductsFromAssets();
                        Get.snackbar(
                          'Success',
                          'Existing products replaced successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        // Upload products for the first time
                        await productRepo.uploadProductsFromAssets();
                        Get.snackbar(
                          'Success',
                          'All products uploaded successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
                TSettingsMenuTile(
                  icon: Iconsax.image,
                  title: 'Upload Banners',
                  subTitle: 'Upload Banners only one time',
                  trailing: const Icon(Iconsax.document_upload),
                  onTap: () async {
                    try {
                      final bannerRepo = Get.find<BannerRepository>();
                      final exists = await bannerRepo.bannersAlreadyUploaded();

                      if (exists) {
                        // Show confirmation dialog before replacing
                        Get.defaultDialog(
                          title: 'Banners Already Exist',
                          middleText:
                              'Do you want to replace existing banners?',
                          textCancel: 'Cancel',
                          textConfirm: 'Replace',
                          confirmTextColor: Colors.white,
                          onConfirm: () async {
                            Get.back(); // close dialog

                            Get.snackbar(
                              'Replacing',
                              'Please wait...',
                              showProgressIndicator: true,
                              snackPosition: SnackPosition.BOTTOM,
                            );

                            // Delete existing and upload new banners
                            await bannerRepo.replaceBanners();

                            Get.snackbar(
                              'Success',
                              'Banners replaced successfully!',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        );
                      } else {
                        // Upload fresh banners
                        Get.snackbar(
                          'Uploading',
                          'Please wait...',
                          showProgressIndicator: true,
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        await bannerRepo.uploadBanners();

                        Get.snackbar(
                          'Success',
                          'Banners uploaded successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
