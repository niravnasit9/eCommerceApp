import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/admin/controllers/admin_order_controller.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_order_card.dart';
import 'package:yt_ecommerce_admin_panel/admin/widgets/admin_search_bar.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/order/order_details.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AdminOrderController());

    return Scaffold(
      body: SafeArea(
        // ✅ Add SafeArea to avoid overflow
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // ✅ Wrap with SingleChildScrollView
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Search Bar
                    AdminSearchBar(
                      hintText: 'Search orders by ID or User ID...',
                      onChanged: (value) {
                        controller.searchOrders(value);
                      },
                      onSubmitted: (value) {
                        controller.searchOrders(value);
                        // ✅ Close keyboard after search
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Stats Row 1
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Total Orders',
                                value: controller.totalOrders.value.toString(),
                                icon: Iconsax.shopping_cart,
                                color: TColors.primary,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Pending',
                                value:
                                    controller.pendingOrders.value.toString(),
                                icon: Iconsax.clock,
                                color: TColors.warning,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Processing',
                                value: controller.processingOrders.value
                                    .toString(),
                                icon: Iconsax.repeat,
                                color: TColors.info,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Confirmed',
                                value:
                                    controller.confirmedOrders.value.toString(),
                                icon: Iconsax.tick_circle,
                                color: TColors.success,
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Stats Row 2
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Shipped',
                                value:
                                    controller.shippedOrders.value.toString(),
                                icon: Iconsax.ship,
                                color: TColors.primary,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Out for Delivery',
                                value: controller.outForDeliveryOrders.value
                                    .toString(),
                                icon: Iconsax.truck,
                                color: TColors.secondary,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Delivered',
                                value:
                                    controller.deliveredOrders.value.toString(),
                                icon: Iconsax.tick_circle,
                                color: TColors.success,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Cancelled',
                                value:
                                    controller.cancelledOrders.value.toString(),
                                icon: Iconsax.close_circle,
                                color: TColors.error,
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Stats Row 3
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                title: 'Refunded',
                                value:
                                    controller.refundedOrders.value.toString(),
                                icon: Iconsax.money_recive,
                                color: TColors.warning,
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(child: Container()),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(child: Container()),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(child: Container()),
                          ],
                        )),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Status Filter Chips
                    SizedBox(
                      height: 50,
                      child: Obx(() => ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFilterChip(
                                context,
                                'All',
                                controller.selectedStatus.value == 'All',
                                () {
                                  controller.filterByStatus('All');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Pending',
                                controller.selectedStatus.value == 'Pending',
                                () {
                                  controller.filterByStatus('Pending');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Processing',
                                controller.selectedStatus.value == 'Processing',
                                () {
                                  controller.filterByStatus('Processing');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Confirmed',
                                controller.selectedStatus.value == 'Confirmed',
                                () {
                                  controller.filterByStatus('Confirmed');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Shipped',
                                controller.selectedStatus.value == 'Shipped',
                                () {
                                  controller.filterByStatus('Shipped');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Out for Delivery',
                                controller.selectedStatus.value ==
                                    'Out for Delivery',
                                () {
                                  controller.filterByStatus('Out for Delivery');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Delivered',
                                controller.selectedStatus.value == 'Delivered',
                                () {
                                  controller.filterByStatus('Delivered');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Cancelled',
                                controller.selectedStatus.value == 'Cancelled',
                                () {
                                  controller.filterByStatus('Cancelled');
                                },
                              ),
                              const SizedBox(width: TSizes.sm),
                              _buildFilterChip(
                                context,
                                'Refunded',
                                controller.selectedStatus.value == 'Refunded',
                                () {
                                  controller.filterByStatus('Refunded');
                                },
                              ),
                            ],
                          )),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Orders List - Fixed height
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.45, // ✅ Fixed height
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.filteredOrders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.shopping_cart,
                                  size: 64,
                                  color: dark ? TColors.grey : TColors.darkGrey,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                Text(
                                  'No orders found',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(
                                    height: TSizes.spaceBtwItems / 2),
                                Text(
                                  controller.selectedStatus.value == 'All'
                                      ? 'No orders have been placed yet'
                                      : 'No ${controller.selectedStatus.value.toLowerCase()} orders found',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const AlwaysScrollableScrollPhysics(), // ✅ Always scrollable
                          itemCount: controller.filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: TSizes.spaceBtwItems),
                          itemBuilder: (_, index) {
                            final order = controller.filteredOrders[index];
                            return AdminOrderCard(
                              order: order,
                              onUpdateStatus: (orderId, status) {
                                // ✅ Now receives both parameters
                                print(
                                    '📦 Updating order: $orderId to status: $status');
                                controller.updateOrderStatus(orderId, status);
                              },
                              onViewDetails: () {
                                Get.to(() => OrderDetailsScreen(order: order));
                              },
                            );
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),
                  ],
                ),
              ),
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

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    final dark = THelperFunctions.isDarkMode(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      backgroundColor: dark ? TColors.dark : TColors.white,
      selectedColor: _getStatusColorForFilter(label).withOpacity(0.2),
      checkmarkColor: _getStatusColorForFilter(label),
      labelStyle: TextStyle(
        color: isSelected
            ? _getStatusColorForFilter(label)
            : (dark ? TColors.white : TColors.black),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? _getStatusColorForFilter(label)
            : (dark ? TColors.borderSecondary : TColors.borderPrimary),
      ),
    );
  }

  Color _getStatusColorForFilter(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TColors.warning;
      case 'processing':
        return TColors.info;
      case 'confirmed':
        return TColors.success;
      case 'shipped':
        return TColors.primary;
      case 'out for delivery':
        return TColors.secondary;
      case 'delivered':
        return TColors.success;
      case 'cancelled':
        return TColors.error;
      case 'refunded':
        return TColors.warning;
      default:
        return TColors.primary;
    }
  }
}
