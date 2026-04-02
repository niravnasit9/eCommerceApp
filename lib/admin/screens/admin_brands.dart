import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/admin/controllers/admin_brand_controller.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_search_bar.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_brand_card.dart';
import 'package:yt_ecommerce_admin_panel/admin/forms/add_brand_form.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminBrands extends StatelessWidget {
  const AdminBrands({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AdminBrandController());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddBrandForm());
        },
        backgroundColor: TColors.primary,
        icon: const Icon(Iconsax.add),
        label: const Text('Add Brand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// Search Bar
            AdminSearchBar(
              hintText: 'Search brands...',
              onChanged: (value) {
                controller.searchBrands(value);
              },
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Brands',
                    value: controller.totalBrands.value.toString(),
                    icon: Iconsax.tag,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Featured',
                    value: controller.featuredBrandsCount.value.toString(),
                    icon: Iconsax.star,
                    color: TColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Brands Grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredBrands.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.tag,
                          size: 64,
                          color: dark ? TColors.grey : TColors.darkGrey,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          'No brands found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Text(
                          'Click the + button to add your first brand',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: TSizes.spaceBtwItems,
                    crossAxisSpacing: TSizes.spaceBtwItems,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: controller.filteredBrands.length,
                  itemBuilder: (_, index) {
                    final brand = controller.filteredBrands[index];
                    return AdminBrandCard(
                      brand: brand,
                      onEdit: () {
                        Get.to(() => AddBrandForm(brand: brand));
                      },
                      onDelete: () {
                        _showDeleteConfirmation(context, controller, brand.id);
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

  void _showDeleteConfirmation(BuildContext context, AdminBrandController controller, String brandId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Brand'),
          content: const Text('Are you sure you want to delete this brand? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteBrand(brandId);
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