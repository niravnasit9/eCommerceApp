import 'package:flutter/material.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/product_title_text.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/t_brand_title_text_with_verified_icon.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/cart_item_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class TCartItem extends StatelessWidget {
  const TCartItem({
    super.key,
    required this.cartItem,
  });

  final CartItemModel cartItem;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image with border radius
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TRoundedImage(
            imageurl: cartItem.image ?? '',
            width: 70,
            height: 70,
            isNetworkImage: true,
            padding: const EdgeInsets.all(TSizes.xs),
            backgroundColor: dark ? TColors.darkerGrey : TColors.light,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: TSizes.spaceBtwItems),

        /// Title, Brand, Price & Size
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Brand Name
              TBrandTitleWithVerifiedIcon(
                title: cartItem.brandName ?? '',
              ),
              
              const SizedBox(height: TSizes.xs),
              
              /// Product Title
              Flexible(
                child: TProductTitleText(
                  title: cartItem.title,
                  maxLines: 1,
                ),
              ),
              
              const SizedBox(height: TSizes.xs),
              
              /// Attributes (Color, Storage, etc.)
              if (cartItem.selectedVariation != null && 
                  cartItem.selectedVariation!.isNotEmpty) ...[
                Wrap(
                  spacing: TSizes.sm,
                  runSpacing: TSizes.xs,
                  children: cartItem.selectedVariation!.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.sm,
                        vertical: TSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkerGrey : TColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                        border: Border.all(
                          color: dark ? TColors.darkGrey : TColors.grey.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${e.key}: ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: TSizes.fontSizeSm,
                                    color: dark ? TColors.grey : TColors.darkGrey,
                                  ),
                            ),
                            TextSpan(
                              text: e.value,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: TSizes.fontSizeSm,
                                    fontWeight: FontWeight.w500,
                                    color: dark ? TColors.white : TColors.dark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              /// Price (Optional - if you want to show price in cart item)
              const SizedBox(height: TSizes.xs),
              Row(
                children: [
                  Text(
                    'Price: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? TColors.grey : TColors.darkGrey,
                        ),
                  ),
                  Text(
                    '₹${cartItem.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}