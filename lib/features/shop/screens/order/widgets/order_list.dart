import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/loaders/animation_loader.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/controller/product/order_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/screens/order/order_details.dart';
import 'package:yt_ecommerce_admin_panel/navigation_menu.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/image_strings.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/cloud_helper_functions.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  /// Helper function to safely truncate string
  String _truncateString(String text, int maxLength) {
    if (text.isEmpty) return 'N/A';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());
    
    return FutureBuilder(
      future: controller.fetchUserOrders(),
      builder: (_, snapshot) {
        final emptyWidget = TAnimationLoaderWidget(
          text: 'Whoops! No Orders Yet',
          animation: TImages.orderCompletedAnimation,
          showAction: true,
          actionText: 'Let\'s fill it.',
          onActionPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAll(() => const NavigationMenu());
            });
          },
        );

        final response = TCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot, 
          nothingFound: emptyWidget
        );
        if (response != null) return response;

        final orders = snapshot.data;
        return ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: orders!.length,
          separatorBuilder: (_, Index) => const SizedBox(
            height: TSizes.spaceBtwItems,
          ),
          itemBuilder: (_, index) {
            final order = orders[index];
            
            return GestureDetector(
              onTap: () {
                Get.to(() => OrderDetailsScreen(order: order));
              },
              child: TRoundedContainer(
                showBorder: true,
                borderColor: dark ? TColors.borderSecondary : TColors.borderPrimary,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.dark : TColors.white,
                child: Column(
                  children: [
                    /// Row 1 - Order Status and Date
                    Row(
                      children: [
                        /// Status Icon
                        Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                          ),
                          child: Icon(
                            _getStatusIcon(order.status),
                            size: TSizes.iconMd,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        
                        /// Status & Order Date
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderStatusText,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: TSizes.xs),
                              Text(
                                'Ordered on: ${order.formattedOrderDate}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: dark ? TColors.textWhite : TColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        /// View Details Icon
                        IconButton(
                          onPressed: () {
                            Get.to(() => OrderDetailsScreen(order: order));
                          },
                          icon: Icon(
                            Iconsax.arrow_right_34, 
                            size: TSizes.iconSm,
                            color: dark ? TColors.textWhite : TColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    /// Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dark ? TColors.borderSecondary : TColors.borderPrimary,
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    /// Row 2 - Order ID & Payment Method
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.tag, 
                                size: TSizes.iconSm,
                                color: dark ? TColors.textWhite : TColors.textSecondary,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: dark ? TColors.textWhite : TColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: TSizes.xs),
                                    Text(
                                      _truncateString(order.id, 12),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: dark ? TColors.textWhite : TColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.card, 
                                size: TSizes.iconSm,
                                color: dark ? TColors.textWhite : TColors.textSecondary,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: dark ? TColors.textWhite : TColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: TSizes.xs),
                                    Text(
                                      order.paymentMethod,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: dark ? TColors.textWhite : TColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    /// Row 3 - Items Count & Total Amount
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.shopping_bag, 
                                size: TSizes.iconSm,
                                color: dark ? TColors.textWhite : TColors.textSecondary,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Items',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: dark ? TColors.textWhite : TColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: TSizes.xs),
                                    Text(
                                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: dark ? TColors.textWhite : TColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.money, 
                                size: TSizes.iconSm,
                                color: dark ? TColors.textWhite : TColors.textSecondary,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: dark ? TColors.textWhite : TColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: TSizes.xs),
                                    Text(
                                      '₹${order.totalAmount.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: TColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: TSizes.spaceBtwItems),
                    
                    /// Row 4 - Delivery Date & Shipping Status
                    Container(
                      padding: const EdgeInsets.all(TSizes.sm),
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkContainer : TColors.softGrey,
                        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.truck, 
                            size: TSizes.iconSm,
                            color: dark ? TColors.textWhite : TColors.textSecondary,
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems / 2),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected Delivery',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: dark ? TColors.textWhite : TColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: TSizes.xs),
                                Text(
                                  order.formattedDeliveryDate,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: order.status == OrderStatus.delivered 
                                        ? TColors.success 
                                        : TColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (order.status == OrderStatus.delivered)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.sm,
                                vertical: TSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.tick_circle,
                                    size: 14,
                                    color: TColors.success,
                                  ),
                                  const SizedBox(width: TSizes.xs),
                                  Text(
                                    'Delivered',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: TColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  /// Get status color based on order status
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return TColors.warning;
      case OrderStatus.confirmed:
        return TColors.info;
      case OrderStatus.shipped:
        return TColors.primary;
      case OrderStatus.outForDelivery:
        return TColors.secondary;
      case OrderStatus.delivered:
        return TColors.success;
      case OrderStatus.cancelled:
        return TColors.error;
      case OrderStatus.refunded:
        return TColors.darkGrey;
      default:
        return TColors.primary;
    }
  }
  
  /// Get status icon based on order status
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Iconsax.clock;
      case OrderStatus.confirmed:
        return Iconsax.tick_circle;
      case OrderStatus.shipped:
        return Iconsax.ship;
      case OrderStatus.outForDelivery:
        return Iconsax.truck;
      case OrderStatus.delivered:
        return Iconsax.tick_circle;
      case OrderStatus.cancelled:
        return Iconsax.close_circle;
      case OrderStatus.refunded:
        return Iconsax.money_recive;
      default:
        return Iconsax.box;
    }
  }
}