import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminBrandCard extends StatelessWidget {
  const AdminBrandCard({
    super.key,
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  final BrandModel brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? TColors.dark : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: Border.all(
          color: (dark ? TColors.borderSecondary : TColors.borderPrimary)
              .withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Brand Image with Featured overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: dark ? TColors.darkerGrey : TColors.light,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (dark
                              ? TColors.borderSecondary
                              : TColors.borderPrimary)
                          .withOpacity(0.4),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(brand.image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (brand.isFeatured == true)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: TColors.warning,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: TColors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Iconsax.star5,
                        size: 9,
                        color: TColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            /// Brand Name
            Text(
              brand.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            /// Products Count
            Text(
              '${brand.productsCount ?? 0} products',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: dark ? TColors.grey : TColors.darkGrey,
                    fontSize: 10,
                  ),
            ),

            // const SizedBox(height: 6),

            Divider(
              color:
                  (dark ? TColors.borderSecondary : TColors.borderPrimary)
                      .withOpacity(0.4),
              height: 1,
            ),
            const SizedBox(height: 6),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionBtn(
                  icon: Iconsax.edit,
                  label: 'Edit',
                  onTap: onEdit,
                  color: TColors.primary,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Iconsax.trash,
                  label: 'Delete',
                  onTap: onDelete,
                  color: TColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.2), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}