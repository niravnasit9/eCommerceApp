import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/brnads/brand_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/popups/loaders.dart';

class AdminBrandController extends GetxController {
  static AdminBrandController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BrandRepository _brandRepository = BrandRepository.instance;
  final String brandsCollection = 'Brands';

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

      final snapshot = await _db.collection(brandsCollection).get();
      allBrands.value = snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
      filteredBrands.value = allBrands;

      totalBrands.value = allBrands.length;
      featuredBrandsCount.value = allBrands.where((brand) => brand.isFeatured == true).length;

      print('✅ Total Brands: ${totalBrands.value}');
      print('✅ Featured Brands: ${featuredBrandsCount.value}');

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('❌ Error fetching brands: $e');
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to fetch brands: $e');
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

  /// ✅ Upload brand image to Cloudinary
  Future<String?> uploadBrandImage(File image) async {
    try {
      TLoaders.customDialog(message: 'Uploading image...');
      final imageUrl = await _brandRepository.uploadToCloudinaryFile(image, 'brands');
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

  Future<void> deleteBrand(String brandId) async {
    try {
      TLoaders.customDialog(message: 'Deleting brand...');
      await _db.collection(brandsCollection).doc(brandId).delete();
      await fetchBrands();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Brand deleted successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to delete brand: $e');
    }
  }

  Future<void> addBrand(BrandModel brand) async {
    try {
      TLoaders.customDialog(message: 'Adding brand...');
      await _db.collection(brandsCollection).add(brand.toJson());
      await fetchBrands();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Brand added successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to add brand: $e');
    }
  }

  Future<void> updateBrand(BrandModel brand) async {
    try {
      TLoaders.customDialog(message: 'Updating brand...');
      await _db.collection(brandsCollection).doc(brand.id).update(brand.toJson());
      await fetchBrands();
      TLoaders.hideDialog();
      TLoaders.successSnackBar(title: 'Success', message: 'Brand updated successfully');
    } catch (e) {
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to update brand: $e');
    }
  }
}