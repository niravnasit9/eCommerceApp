import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/admin/controllers/admin_order_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/order_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onUpdateStatus,
    required this.onViewDetails,
  });

  final OrderModel order;
  final Function(String, String) onUpdateStatus;
  final VoidCallback onViewDetails;

  String _getDropdownValue(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'confirmed':
      case 'order confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'out for delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<AdminOrderController>();
    
    String dropdownValue = _getDropdownValue(order.orderStatusText);
    final String firestoreDocId = order.docId;
    final String displayOrderId = order.id.length > 8 
        ? order.id.substring(0, 8) 
        : order.id;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.dark : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: Border.all(
          color: dark ? TColors.borderSecondary : TColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            children: [
              /// Order ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$displayOrderId',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      order.formattedOrderDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              /// Status Dropdown
              Obx(() {
                if (controller.isUpdating.value) {
                  return const SizedBox(
                    width: 100,
                    height: 40,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.sm,
                    vertical: TSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    underline: const SizedBox(),
                    icon: const Icon(Iconsax.arrow_down, size: 16),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: TSizes.fontSizeSm,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Processing', child: Text('Processing')),
                      DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                      DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
                      DropdownMenuItem(value: 'Out for Delivery', child: Text('Out for Delivery')),
                      DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                      DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                      DropdownMenuItem(value: 'Refunded', child: Text('Refunded')),
                    ],
                    onChanged: (value) {
                      if (value != null && value != dropdownValue) {
                        _showStatusUpdateDialog(context, value, () {
                          onUpdateStatus(firestoreDocId, value);
                        });
                      }
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: TSizes.spaceBtwItems),

          /// Customer Info
          Row(
            children: [
              Icon(
                Iconsax.user,
                size: 14,
                color: dark ? TColors.grey : TColors.darkGrey,
              ),
              const SizedBox(width: TSizes.xs),
              Text(
                order.userId.length > 12 ? order.userId.substring(0, 12) : order.userId,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Icon(
                Iconsax.money,
                size: 14,
                color: dark ? TColors.grey : TColors.darkGrey,
              ),
              const SizedBox(width: TSizes.xs),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: TSizes.spaceBtwItems),

          /// Items Count
          Row(
            children: [
              Icon(
                Iconsax.shopping_bag,
                size: 14,
                color: dark ? TColors.grey : TColors.darkGrey,
              ),
              const SizedBox(width: TSizes.xs),
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewDetails,
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, String newStatus, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Text('Are you sure you want to change the status to "$newStatus"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return TColors.warning;
      case OrderStatus.processing:
        return TColors.info;
      case OrderStatus.confirmed:
        return TColors.success;
      case OrderStatus.shipped:
        return TColors.primary;
      case OrderStatus.outForDelivery:
        return TColors.secondary;
      case OrderStatus.delivered:
        return TColors.success;
      case OrderStatus.cancelled:
        return TColors.error;
      case OrderStatus.refunded:
        return TColors.warning;
      default:
        return TColors.primary;
    }
  }
}