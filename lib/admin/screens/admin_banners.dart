import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/admin/controllers/admin_banner_controller.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_search_bar.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_banner_card.dart';
import 'package:yt_ecommerce_admin_panel/admin/forms/add_banner_form.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminBanners extends StatelessWidget {
  const AdminBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AdminBannerController());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddBannerForm());
        },
        backgroundColor: TColors.primary,
        icon: const Icon(Iconsax.add),
        label: const Text('Add Banner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// Search Bar
            AdminSearchBar(
              hintText: 'Search banners...',
              onChanged: (value) {
                controller.searchBanners(value);
              },
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Stats
            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Banners',
                    value: controller.totalBanners.value.toString(),
                    icon: Iconsax.image,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Active',
                    value: controller.activeBanners.value.toString(),
                    icon: Iconsax.tick_circle,
                    color: TColors.success,
                  ),
                ),
              ],
            )),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Banners List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredBanners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.image,
                          size: 64,
                          color: dark ? TColors.grey : TColors.darkGrey,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          'No banners found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Text(
                          'Click the + button to add your first banner',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.filteredBanners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                  itemBuilder: (_, index) {
                    final banner = controller.filteredBanners[index];
                    return AdminBannerCard(
                      banner: banner,
                      onEdit: () {
                        Get.to(() => AddBannerForm(banner: banner));
                      },
                      onDelete: () {
                        _showDeleteConfirmation(context, controller, banner.id);
                      },
                      onToggleStatus: () {
                        controller.toggleBannerStatus(banner.id);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color color = TColors.primary,
  }) {
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
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: TSizes.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AdminBannerController controller, String bannerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Banner'),
          content: const Text('Are you sure you want to delete this banner? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteBanner(bannerId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}