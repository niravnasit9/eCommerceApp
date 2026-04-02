import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/orders/order_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/order_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/enums.dart';

class AdminOrderController extends GetxController {
  static AdminOrderController get instance => Get.find();

  final OrderRepository _orderRepository = OrderRepository.instance;

  final isLoading = false.obs;
  final isUpdating = false.obs; // ✅ For tracking update status
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;
  final selectedStatus = 'All'.obs;

  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final processingOrders = 0.obs;
  final confirmedOrders = 0.obs;
  final shippedOrders = 0.obs;
  final deliveredOrders = 0.obs;
  final cancelledOrders = 0.obs;
  final outForDeliveryOrders = 0.obs;
  final refundedOrders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      print('📦 Fetching orders...');

      allOrders.value = await _orderRepository.fetchAllOrders();
      filteredOrders.value = allOrders;

      // Calculate all stats
      _calculateStats();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching orders: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch orders: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }

  void _calculateStats() {
    totalOrders.value = allOrders.length;
    pendingOrders.value =
        allOrders.where((o) => o.status == OrderStatus.pending).length;
    processingOrders.value =
        allOrders.where((o) => o.status == OrderStatus.processing).length;
    confirmedOrders.value =
        allOrders.where((o) => o.status == OrderStatus.confirmed).length;
    shippedOrders.value =
        allOrders.where((o) => o.status == OrderStatus.shipped).length;
    outForDeliveryOrders.value =
        allOrders.where((o) => o.status == OrderStatus.outForDelivery).length;
    deliveredOrders.value =
        allOrders.where((o) => o.status == OrderStatus.delivered).length;
    cancelledOrders.value =
        allOrders.where((o) => o.status == OrderStatus.cancelled).length;
    refundedOrders.value =
        allOrders.where((o) => o.status == OrderStatus.refunded).length;

    print(
        '✅ Stats calculated - Total: ${totalOrders.value}, Pending: ${pendingOrders.value}');
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders.value = allOrders;
    } else {
      filteredOrders.value = allOrders.where((order) {
        return order.id.toLowerCase().contains(query.toLowerCase()) ||
            order.userId.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    print('🔍 Filtering by status: $status');

    if (status == 'All') {
      filteredOrders.value = allOrders;
    } else {
      OrderStatus? orderStatus = _getOrderStatusFromString(status);

      if (orderStatus != null) {
        filteredOrders.value =
            allOrders.where((order) => order.status == orderStatus).toList();
        print('✅ Found ${filteredOrders.length} orders with status: $status');
      } else {
        filteredOrders.value = [];
      }
    }
  }

  OrderStatus? _getOrderStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return null;
    }
  }

  /// UPDATE ORDER STATUS - Uses Repository
  Future<void> updateOrderStatus(String docId, String newStatus) async {
    try {
      isUpdating.value = true;
      print(
          '🔄 Updating order with Firestore Doc ID: "$docId" to status: $newStatus');

      // Call repository to update - pass the Firestore document ID
      await _orderRepository.updateOrderStatus(docId, newStatus);

      // Refresh orders list
      await fetchOrders();

      // Show success message
      Get.snackbar(
        'Success',
        'Order status updated to $newStatus successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );

      isUpdating.value = false;
    } catch (e) {
      isUpdating.value = false;
      print('❌ Error updating order: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }
}
