import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/authentication/authentication_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/order_model.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch user orders (for frontend - customer view)
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw 'Unable to find user information. Try again in few minutes.';
      }

      final result = await _db
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .orderBy('orderDate', descending: true)
          .get();
          
      return result.docs
          .map((documentSnapshot) => OrderModel.fromSnapshot(documentSnapshot))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching user Order information: $e';
    }
  }

  /// Save order (for frontend - when placing order)
  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .doc(order.id) // Use custom order ID as document ID
          .set(order.toJson());
      print('✅ Order saved successfully: ${order.id}');
    } catch (e) {
      print('❌ Error saving order: $e');
      throw 'Something went wrong while saving order: $e';
    }
  }

  /// ✅ NEW: Update order status (for admin panel)
  Future<void> updateOrderStatus(String docId, String newStatus) async {
    try {
      print('🔄 Updating order status in repository:');
      print('   📄 Firestore Document ID: $docId');
      print('   📊 New Status: $newStatus');
      
      // Find which user has this order by searching through all users
      final usersSnapshot = await _db.collection('Users').get();
      bool found = false;
      
      for (var userDoc in usersSnapshot.docs) {
        // Check if this user has an order with this document ID
        final orderDoc = await _db
            .collection('Users')
            .doc(userDoc.id)
            .collection('Orders')
            .doc(docId)
            .get();
        
        if (orderDoc.exists) {
          // Update the order status
          await _db
              .collection('Users')
              .doc(userDoc.id)
              .collection('Orders')
              .doc(docId)
              .update({
            'status': newStatus.toLowerCase(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          found = true;
          print('✅ Order status updated successfully for user: ${userDoc.id}');
          print('   📄 Document ID: $docId');
          print('   📊 New Status: $newStatus');
          break;
        }
      }
      
      if (!found) {
        print('❌ Order not found with Firestore Document ID: $docId');
        throw 'Order not found with ID: $docId';
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      throw 'Failed to update order status: $e';
    }
  }

  /// ✅ NEW: Fetch all orders (for admin panel)
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      print('📦 Fetching all orders from all users...');
      
      List<OrderModel> orders = [];
      
      // Get all users
      final usersSnapshot = await _db.collection('Users').get();
      
      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot = await _db
            .collection('Users')
            .doc(userDoc.id)
            .collection('Orders')
            .orderBy('orderDate', descending: true)
            .get();
        
        for (var orderDoc in ordersSnapshot.docs) {
          orders.add(OrderModel.fromSnapshot(orderDoc));
        }
      }
      
      print('✅ Found ${orders.length} total orders');
      return orders;
    } catch (e) {
      print('❌ Error fetching all orders: $e');
      throw 'Failed to fetch orders: $e';
    }
  }

  /// ✅ NEW: Fetch orders by status (for admin panel filtering)
  Future<List<OrderModel>> fetchOrdersByStatus(String status) async {
    try {
      final allOrders = await fetchAllOrders();
      return allOrders.where((order) => order.status.name == status.toLowerCase()).toList();
    } catch (e) {
      throw 'Failed to fetch orders by status: $e';
    }
  }

  /// ✅ NEW: Delete order (for admin panel)
  Future<void> deleteOrder(String docId) async {
    try {
      print('🗑️ Deleting order with ID: $docId');
      
      // Find which user has this order
      final usersSnapshot = await _db.collection('Users').get();
      bool found = false;
      
      for (var userDoc in usersSnapshot.docs) {
        final orderDoc = await _db
            .collection('Users')
            .doc(userDoc.id)
            .collection('Orders')
            .doc(docId)
            .get();
        
        if (orderDoc.exists) {
          await _db
              .collection('Users')
              .doc(userDoc.id)
              .collection('Orders')
              .doc(docId)
              .delete();
          found = true;
          print('✅ Order deleted successfully for user: ${userDoc.id}');
          break;
        }
      }
      
      if (!found) {
        throw 'Order not found with ID: $docId';
      }
    } catch (e) {
      print('❌ Error deleting order: $e');
      throw 'Failed to delete order: $e';
    }
  }
}