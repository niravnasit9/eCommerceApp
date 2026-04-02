import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminStatsCard extends StatelessWidget {
  const AdminStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.dark : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(
          color: dark ? TColors.borderSecondary : TColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.xs,
                    vertical: TSizes.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: change!.startsWith('+')
                        ? TColors.success.withOpacity(0.1)
                        : TColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        change!.startsWith('+') ? Iconsax.arrow_up : Iconsax.arrow_down,
                        size: 12,
                        color: change!.startsWith('+') ? TColors.success : TColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: change!.startsWith('+') ? TColors.success : TColors.error,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}