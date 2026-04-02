import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/product_title_text.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminProductCard extends StatelessWidget {
  const AdminProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: dark ? TColors.dark : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: Border.all(
          color: dark ? TColors.borderSecondary : TColors.borderPrimary,
        ),
      ),
      child: Row(
        children: [
          /// Product Image
          TRoundedImage(
            imageurl: product.thumbnail,
            width: 80,
            height: 80,
            isNetworkImage: true,
            backgroundColor: dark ? TColors.darkerGrey : TColors.light,
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TProductTitleText(
                  title: product.title,
                  maxLines: 2,
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  'Brand: ${product.brand.name}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: TColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: TSizes.sm),
                    if (product.salePrice > 0)
                      Text(
                        '₹${product.salePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Icon(
                      Iconsax.box,
                      size: 12,
                      color: dark ? TColors.grey : TColors.darkGrey,
                    ),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      'Stock: ${product.stock}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Actions
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Iconsax.edit, size: 20),
                tooltip: 'Edit Product',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash, size: 20, color: TColors.error),
                tooltip: 'Delete Product',
              ),
            ],
          ),
        ],
      ),
    );
  }
}