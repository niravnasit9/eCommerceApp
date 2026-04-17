import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/brands/brand_card.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/brands/brand_products.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class BrandShowcase extends StatelessWidget {
  const BrandShowcase({
    super.key,
    required this.brand,
    required this.images,
  });

  final BrandModel brand;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return GestureDetector(
      onTap: () => Get.to(() => BrandProducts(brand: brand)),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: dark ? TColors.darkerGrey : TColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          border: Border.all(
            color: dark ? TColors.darkerGrey : TColors.grey,
          ),
        ),
        child: Column(
          children: [
            /// Brand Card
            TBrandCard(
              brand: brand,
              showBorder: false,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            /// Product Images Row
            Row(
              children: images.map((image) {
                return Expanded(
                  child: TRoundedImage(
                    imageurl: image,
                    isNetworkImage: true,
                    height: 100,
                    padding: const EdgeInsets.all(TSizes.sm),
                    backgroundColor: dark ? TColors.dark : TColors.light,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}