import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/layouts/grid_layout.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/section_heading.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/controller/brand_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/all_products/all_products.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/store/widget/brand_showcase.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/cloud_helper_functions.dart';

class BrandTab extends StatelessWidget {
  const BrandTab({
    super.key,
    required this.brand,
  });

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Brand Showcase Section
              FutureBuilder(
                future: controller.getBrandProducts(brandName: brand.name, limit: 3),
                builder: (context, snapshot) {
                  final response = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                    loader: const TVerticalProductShimmer(),
                  );
                  
                  if (response != null) return response;
                  
                  final products = snapshot.data!;
                  final images = products.map((e) => e.thumbnail).toList();
                  
                  return BrandShowcase(
                    brand: brand,
                    images: images,
                  );
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Products Section
              FutureBuilder(
                future: controller.getBrandProducts(brandName: brand.name),
                builder: (context, snapshot) {
                  final response = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot,
                    loader: const TVerticalProductShimmer(),
                  );

                  if (response != null) return response;

                  final products = snapshot.data!;
                  
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.shop,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(
                            'Check back later for new products',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      TSectionHeading(
                        title: 'You Might Like',
                        onPressed: () => Get.to(AllProducts(
                          title: brand.name,
                          futureMethod: controller.getBrandProducts(
                            brandName: brand.name,
                            limit: -1,
                          ),
                        )),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      TGridLayout(
                        itemCount: products.length > 4 ? 4 : products.length,
                        itemBuilder: (_, index) => TProductCardVertical(
                          product: products[index],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}