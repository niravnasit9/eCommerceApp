import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';

class AdminBrandController extends GetxController {
  static AdminBrandController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;
  final RxList<BrandModel> filteredBrands = <BrandModel>[].obs;

  final totalBrands = 0.obs;
  final featuredBrandsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      isLoading.value = true;
      print('🏷️ Fetching brands...');

      final snapshot = await _db.collection('Brands').get();
      allBrands.value =
          snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
      filteredBrands.value = allBrands;

      // Calculate stats
      totalBrands.value = allBrands.length;
      featuredBrandsCount.value = allBrands
          .where((brand) => brand.isFeatured == true)
          .length;

      print('✅ Total Brands: ${totalBrands.value}');
      print('✅ Featured Brands: ${featuredBrandsCount.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching brands: $e');
    }
  }

  void searchBrands(String query) {
    if (query.isEmpty) {
      filteredBrands.value = allBrands;
    } else {
      filteredBrands.value = allBrands.where((brand) {
        return brand.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> deleteBrand(String brandId) async {
    try {
      await _db.collection('Brands').doc(brandId).delete();
      await fetchBrands();
      Get.snackbar(
        'Success',
        'Brand deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete brand: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }
}