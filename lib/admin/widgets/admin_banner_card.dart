import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminBannerCard extends StatelessWidget {
  const AdminBannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

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
          /// Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            child: Image.network(
              banner.imageUrl,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 80,
                color: dark ? TColors.darkerGrey : TColors.light,
                child: const Icon(Iconsax.image),
              ),
            ),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Banner Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title.isNotEmpty ? banner.title : banner.targetScreen,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Icon(
                      Iconsax.link,
                      size: 12,
                      color: dark ? TColors.grey : TColors.darkGrey,
                    ),
                    const SizedBox(width: TSizes.xs),
                    Expanded(
                      child: Text(
                        'Target: ${banner.targetScreen}',
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.sm,
                    vertical: TSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: banner.active
                        ? TColors.success.withOpacity(0.1)
                        : TColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                  ),
                  child: Text(
                    banner.active ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: banner.active ? TColors.success : TColors.error,
                        ),
                  ),
                ),
              ],
            ),
          ),

          /// Actions
          Column(
            children: [
              /// Status Toggle
              Switch(
                value: banner.active,
                onChanged: (_) => onToggleStatus(),
                activeColor: TColors.success,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Iconsax.edit, size: 18),
                    tooltip: 'Edit Banner',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Iconsax.trash, size: 18, color: TColors.error),
                    tooltip: 'Delete Banner',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}