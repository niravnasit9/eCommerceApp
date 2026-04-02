import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/order_model.dart';

class AdminController extends GetxController {
  static AdminController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final isLoadingOrders = false.obs;

  final totalProducts = 0.obs;
  final totalOrders = 0.obs;
  final totalUsers = 0.obs;
  final totalRevenue = 0.obs;

  final productGrowth = '+0'.obs;
  final orderGrowth = '+0'.obs;
  final userGrowth = '+0'.obs;
  final revenueGrowth = '+0'.obs;

  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchRecentOrders();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      print('📊 Fetching dashboard data...');

      // Fetch total products from 'Products' collection
      final productsSnapshot = await _db.collection('Products').get();
      totalProducts.value = productsSnapshot.docs.length;
      print('✅ Total Products: ${totalProducts.value}');

      // Fetch total orders from 'Users' -> 'Orders' subcollection
      final usersSnapshot = await _db.collection('Users').get();
      int orderCount = 0;
      double revenue = 0;
      
      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot = await _db
            .collection('Users')
            .doc(userDoc.id)
            .collection('Orders')
            .get();
        
        orderCount += ordersSnapshot.docs.length;
        
        for (var orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data();
          revenue += (orderData['totalAmount'] ?? 0).toDouble();
        }
      }
      
      totalOrders.value = orderCount;
      totalRevenue.value = revenue.toInt();
      print('✅ Total Orders: ${totalOrders.value}');
      print('✅ Total Revenue: ${totalRevenue.value}');

      // Fetch total users from 'Users' collection
      totalUsers.value = usersSnapshot.docs.length;
      print('✅ Total Users: ${totalUsers.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching dashboard data: $e');
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      isLoadingOrders.value = true;
      
      List<OrderModel> allOrders = [];
      
      // Get all users and their orders
      final usersSnapshot = await _db.collection('Users').get();
      
      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot = await _db
            .collection('Users')
            .doc(userDoc.id)
            .collection('Orders')
            .orderBy('orderDate', descending: true)
            .limit(5)
            .get();
        
        for (var orderDoc in ordersSnapshot.docs) {
          allOrders.add(OrderModel.fromSnapshot(orderDoc));
        }
      }
      
      // Sort by order date and take top 5
      allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      recentOrders.value = allOrders.take(5).toList();

      isLoadingOrders.value = false;
    } catch (e) {
      isLoadingOrders.value = false;
      print('Error fetching recent orders: $e');
    }
  }
}