import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/product/product_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/category_model.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/popups/loaders.dart';

class AdminProductController extends GetxController {
  static AdminProductController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProductRepository _productRepository = ProductRepository.instance;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<BrandModel> brands = <BrandModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final totalProducts = 0.obs;
  final activeProducts = 0.obs;
  final outOfStockProducts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchBrands();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _db.collection('Products').get();
      allProducts.value =
          snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      filteredProducts.value = allProducts;

      totalProducts.value = allProducts.length;
      activeProducts.value = allProducts.where((p) => p.stock > 0).length;
      outOfStockProducts.value = allProducts.where((p) => p.stock <= 0).length;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error fetching products: $e');
    }
  }

  Future<void> fetchBrands() async {
    try {
      final snapshot = await _db.collection('Brands').get();
      brands.value =
          snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _db.collection('Categories').get();
      categories.value =
          snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
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

  /// ✅ Upload single image to Cloudinary
  Future<String> uploadImage(File image, String folder) async {
    try {
      final url =
          await _productRepository.uploadToCloudinaryFile(image, folder);
      return url;
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to upload image: $e');
      return '';
    }
  }

  /// ✅ Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(
      List<File> images, String folder) async {
    List<String> urls = [];
    for (var image in images) {
      final url = await uploadImage(image, folder);
      if (url.isNotEmpty) {
        urls.add(url);
      }
    }
    return urls;
  }

  /// ✅ Add new product (uploads images then saves to Firestore)
  Future<void> addProduct(ProductModel product,
      {List<File>? newImages, File? newThumbnail}) async {
    try {
      isSaving.value = true;
      TLoaders.customDialog(message: 'Uploading images...');

      // Upload images to Cloudinary if any
      List<String> uploadedImageUrls = [];
      if (newImages != null && newImages.isNotEmpty) {
        uploadedImageUrls =
            await uploadMultipleImages(newImages, 'products/images');
      }

      // Upload thumbnail if provided
      String thumbnailUrl = product.thumbnail;
      if (newThumbnail != null) {
        thumbnailUrl = await uploadImage(newThumbnail, 'products/thumbnail');
      }

      // ✅ Fix: Ensure proper List<String> type
      final existingImages = product.images ?? [];
      final List<String> allImages = [...existingImages, ...uploadedImageUrls];
      final List<String> finalImages = allImages.cast<String>();

      // Create final product with uploaded URLs
      final finalProduct = product.copyWith(
        images: finalImages,
        thumbnail: thumbnailUrl,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _productRepository.saveProduct(finalProduct);

      await fetchProducts();
      isSaving.value = false;
      TLoaders.hideDialog();
      TLoaders.successSnackBar(
          title: 'Success', message: 'Product added successfully');
    } catch (e) {
      isSaving.value = false;
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to add product: $e');
    }
  }

  /// ✅ Update existing product
  Future<void> updateProduct(ProductModel product,
      {List<File>? newImages, File? newThumbnail}) async {
    try {
      isSaving.value = true;
      TLoaders.customDialog(message: 'Updating product...');

      // Upload new images if any
      List<String> newImageUrls = [];
      if (newImages != null && newImages.isNotEmpty) {
        newImageUrls = await uploadMultipleImages(newImages, 'products/images');
      }

      // Upload new thumbnail if provided
      String thumbnailUrl = product.thumbnail;
      if (newThumbnail != null) {
        thumbnailUrl = await uploadImage(newThumbnail, 'products/thumbnail');
      }

      // ✅ Fix: Convert to List<String> explicitly
      final existingImages = product.images ?? [];
      final List<String> allImages = [...existingImages, ...newImageUrls];

      // ✅ Fix: Ensure allImages is List<String>
      final List<String> finalImages = allImages.cast<String>();

      // Create final product with updated URLs
      final finalProduct = product.copyWith(
        images: finalImages, // Now this is List<String>
        thumbnail: thumbnailUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _productRepository.updateProduct(finalProduct);

      await fetchProducts();
      isSaving.value = false;
      TLoaders.hideDialog(); // ✅ Use hideDialog instead
      TLoaders.successSnackBar(
          title: 'Success', message: 'Product updated successfully');
    } catch (e) {
      isSaving.value = false;
      TLoaders.hideDialog();
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to update product: $e');
    }
  }

  /// ✅ Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productRepository.deleteProduct(productId);
      await fetchProducts();
      TLoaders.successSnackBar(
          title: 'Success', message: 'Product deleted successfully');
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to delete product: $e');
    }
  }
}
