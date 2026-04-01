import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/icons/t_circular_icon.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class TProductQuantityWithAddRemove extends StatelessWidget {
  const TProductQuantityWithAddRemove({
    super.key,
    required this.quantity,
    this.add,
    this.remove,
  });

  final int quantity;
  final VoidCallback? add, remove;
  
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.xs,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.softGrey,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Minus Button
          TCircularIcon(
            icon: Iconsax.minus,
            width: 32,
            height: 32,
            size: TSizes.md,
            color: dark ? TColors.textWhite : TColors.textPrimary,
            backgroundColor: dark ? TColors.darkerGrey : TColors.light,
            onPressed: remove,
          ),
          
          const SizedBox(width: TSizes.spaceBtwItems),
          
          /// Quantity Text
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? TColors.textWhite : TColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: TSizes.spaceBtwItems),
          
          /// Add Button
          TCircularIcon(
            icon: Iconsax.add,
            width: 32,
            height: 32,
            size: TSizes.md,
            color: TColors.white,
            backgroundColor: TColors.primary,
            onPressed: add,
          ),
        ],
      ),
    );
  }
}