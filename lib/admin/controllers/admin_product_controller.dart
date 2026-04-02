import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';

class AdminProductController extends GetxController {
  static AdminProductController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final totalProducts = 0.obs;
  final activeProducts = 0.obs;
  final outOfStockProducts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      print('📦 Fetching products...');

      final snapshot = await _db.collection('Products').get();
      allProducts.value =
          snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      filteredProducts.value = allProducts;

      // Calculate stats
      totalProducts.value = allProducts.length;
      activeProducts.value = allProducts.where((p) => p.stock > 0).length;
      outOfStockProducts.value = allProducts.where((p) => p.stock <= 0).length;

      print('✅ Total Products: ${totalProducts.value}');
      print('✅ Active Products: ${activeProducts.value}');
      print('✅ Out of Stock: ${outOfStockProducts.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching products: $e');
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.value = allProducts;
    } else {
      filteredProducts.value = allProducts.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('Products').doc(productId).delete();
      await fetchProducts();
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }
}