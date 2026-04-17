import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/brands/brand_show_case.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/layouts/grid_layout.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/section_heading.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/controller/brand_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/cloud_helper_functions.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key, required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
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
                  
                  return TBrandShowcase(
                    brand: brand,
                    images: images,
                  );
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              /// All Products Section
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
                            'No products found for ${brand.name}',
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
                        title: 'All ${brand.name} Products',
                        showActionButton: false,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      TGridLayout(
                        itemCount: products.length,
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
      ),
    );
  }
}