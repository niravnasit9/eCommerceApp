import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/banners/banner_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/popups/loaders.dart';

class AdminBannerController extends GetxController {
  static AdminBannerController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BannerRepository _bannerRepository = BannerRepository.instance;
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

      totalBanners.value = allBanners.length;
      activeBanners.value = allBanners.where((banner) => banner.active == true).length;

      print('✅ Total Banners: ${totalBanners.value}');
      print('✅ Active Banners: ${activeBanners.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching banners: $e');
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to fetch banners: $e');
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

  /// ✅ Upload banner image to Cloudinary
  Future<String?> uploadBannerImage(File image) async {
    try {
      TLoaders.customDialog(message: 'Uploading image...');
      final imageUrl = await _bannerRepository.uploadToCloudinaryFile(image, 'banners');
      TLoaders.hideDialog();
      
      if (imageUrl.isNotEmpty) {
        TLoaders.successSnackBar(title: 'Success', message: 'Image uploaded successfully');
        return imageUrl;
      } else {
        TLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload image');
        return null;
      }
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload image: $e');
      return null;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      TLoaders.customDialog(message: 'Deleting banner...');
      await _db.collection(bannersCollection).doc(bannerId).delete();
      await fetchBanners();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Banner deleted successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to delete banner: $e');
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
      
      TLoaders.successSnackBar(
        title: 'Success', 
        message: newStatus ? 'Banner activated' : 'Banner deactivated'
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to update banner status: $e');
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      TLoaders.customDialog(message: 'Adding banner...');
      await _db.collection(bannersCollection).add(banner.toJson());
      await fetchBanners();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Banner added successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to add banner: $e');
    }
  }

  Future<void> updateBanner(BannerModel banner) async {
    try {
      TLoaders.customDialog(message: 'Updating banner...');
      await _db.collection(bannersCollection).doc(banner.id).update(banner.toJson());
      await fetchBanners();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Banner updated successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to update banner: $e');
    }
  }
}