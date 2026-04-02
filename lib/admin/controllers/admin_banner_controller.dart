import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';

class AdminBannerController extends GetxController {
  static AdminBannerController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String bannersCollection = 'Banners';

  final isLoading = false.obs;
  final RxList<BannerModel> allBanners = <BannerModel>[].obs;
  final RxList<BannerModel> filteredBanners = <BannerModel>[].obs;

  final totalBanners = 0.obs;
  final activeBanners = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      print('🖼️ Fetching banners...');

      final snapshot = await _db.collection(bannersCollection).get();
      
      allBanners.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return BannerModel(
          id: doc.id,
          imageUrl: data['ImageUrl']?.toString() ?? '',
          targetScreen: data['TargetScreen']?.toString() ?? '',
          title: data['Title']?.toString() ?? '',
          active: data['Active'] == true,
        );
      }).toList();
      
      filteredBanners.value = allBanners;

      // Calculate stats
      totalBanners.value = allBanners.length;
      activeBanners.value = allBanners.where((banner) => banner.active == true).length;

      print('✅ Total Banners: ${totalBanners.value}');
      print('✅ Active Banners: ${activeBanners.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching banners: $e');
    }
  }

  void searchBanners(String query) {
    if (query.isEmpty) {
      filteredBanners.value = allBanners;
    } else {
      filteredBanners.value = allBanners.where((banner) {
        return banner.title.toLowerCase().contains(query.toLowerCase()) ||
            banner.targetScreen.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _db.collection(bannersCollection).doc(bannerId).delete();
      await fetchBanners();
      Get.snackbar(
        'Success',
        'Banner deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete banner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }

  Future<void> toggleBannerStatus(String bannerId) async {
    try {
      final banner = allBanners.firstWhere((b) => b.id == bannerId);
      final newStatus = !banner.active;
      
      await _db.collection(bannersCollection).doc(bannerId).update({
        'Active': newStatus,
      });
      
      await fetchBanners();
      
      Get.snackbar(
        'Success',
        newStatus ? 'Banner activated successfully' : 'Banner deactivated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update banner status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      await _db.collection(bannersCollection).add(banner.toJson());
      await fetchBanners();
      Get.snackbar(
        'Success',
        'Banner added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add banner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }

  Future<void> updateBanner(BannerModel banner) async {
    try {
      await _db.collection(bannersCollection).doc(banner.id).update(banner.toJson());
      await fetchBanners();
      Get.snackbar(
        'Success',
        'Banner updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update banner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }
}