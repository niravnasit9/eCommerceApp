import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:yt_ecommerce_admin_panel/data/abstract/products.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/firebase_exceptions.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/platform_exceptions.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// 🔥 CLOUDINARY CONFIG
  final String cloudName = "dtnfznfid";
  final String uploadPreset = "flutter_upload";

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _db.collection('Products').get();
      print('📦 getAllProducts: Found ${snapshot.docs.length} products');
      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } catch (e) {
      print('❌ Error in getAllProducts: $e');
      throw 'Error fetching all products: $e';
    }
  }

  /// Upload image from asset path to Cloudinary
  Future<String> uploadToCloudinary(String assetPath, String folder) async {
    try {
      print("📦 Loading image: $assetPath");

      ByteData byteData = await rootBundle.load(assetPath);
      Uint8List imageData = byteData.buffer.asUint8List();

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageData,
        filename: "product.png",
      ));

      print("☁️ Uploading to Cloudinary...");

      var response = await request.send();
      var resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resBody);
        print("✅ Uploaded: ${data['secure_url']}");
        return data['secure_url'];
      } else {
        print("❌ Upload Failed");
        print("Status: ${response.statusCode}");
        print("Response: $resBody");
        throw "Cloudinary upload failed";
      }
    } catch (e) {
      print("❌ Cloudinary ERROR: $e");
      throw e;
    }
  }

  /// Upload file (from camera/gallery) to Cloudinary
  Future<String> uploadToCloudinaryFile(File file, String folder) async {
    try {
      print("📦 Uploading file: ${file.path}");
      
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      
      var request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(resBody);
        print("✅ Uploaded to Cloudinary: ${data['secure_url']}");
        return data['secure_url'];
      } else {
        print("❌ Upload failed: $resBody");
        throw "Upload failed";
      }
    } catch (e) {
      print("❌ Cloudinary upload error: $e");
      throw "Cloudinary upload error: $e";
    }
  }

  /// Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(List<File> images, String folder) async {
    List<String> uploadedUrls = [];
    for (var image in images) {
      final url = await uploadToCloudinaryFile(image, folder);
      uploadedUrls.add(url);
    }
    return uploadedUrls;
  }

  /// ✅ Save single product to Firestore
  Future<void> saveProduct(ProductModel product) async {
    try {
      await _db.collection('Products').doc(product.id).set(product.toJson());
      print("✅ Product saved to Firestore: ${product.title}");
    } catch (e) {
      print("❌ Error saving product: $e");
      throw 'Failed to save product: $e';
    }
  }

  /// ✅ Update existing product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _db.collection('Products').doc(product.id).update(product.toJson());
      print("✅ Product updated in Firestore: ${product.title}");
    } catch (e) {
      print("❌ Error updating product: $e");
      throw 'Failed to update product: $e';
    }
  }

  /// ✅ Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('Products').doc(productId).delete();
      print("✅ Product deleted from Firestore: $productId");
    } catch (e) {
      print("❌ Error deleting product: $e");
      throw 'Failed to delete product: $e';
    }
  }

  /// CHECK IF PRODUCTS ALREADY EXIST
  Future<bool> productsAlreadyUploaded() async {
    final snapshot = await _db.collection('Products').get();
    return snapshot.docs.isNotEmpty;
  }

  /// UPDATE PRODUCTS WITHOUT TOUCHING IMAGES (COMPLETE DATA UPDATE)
  Future<void> updateProductsWithoutImages() async {
    try {
      print("🚀 STARTING PRODUCT DATA UPDATE (IMAGES PRESERVED)");

      for (var product in dummyProducts) {
        print("📝 Processing: ${product.title}");

        DocumentSnapshot existingDoc = await _db.collection('Products').doc(product.id).get();

        if (!existingDoc.exists) {
          print("⚠️ Product ${product.title} not found, skipping...");
          continue;
        }

        Map<String, dynamic> existingData = existingDoc.data() as Map<String, dynamic>;

        Map<String, dynamic> updatePayload = {
          'Title': product.title,
          'Stock': product.stock,
          'Price': product.price,
          'SalePrice': product.salePrice,
          'ProductType': product.productType,
          'Brand': product.brand.toJson(),
          'CategoryId': product.categoryId,
          'ShortDescription': product.shortDescription,
          'FullDescription': product.fullDescription,
          'Highlights': product.highlights,
          'Specifications': product.specifications,
          'IsFeatured': product.isFeatured,
          'ProductAttributes': product.productAttributes?.map((attr) => attr.toJson()).toList(),
          'UpdatedAt': DateTime.now(),
        };

        if (existingData.containsKey('Images')) {
          updatePayload['Images'] = existingData['Images'];
        }

        if (existingData.containsKey('Thumbnail')) {
          updatePayload['Thumbnail'] = existingData['Thumbnail'];
        }

        if (product.productVariations != null) {
          List<Map<String, dynamic>> existingVariations = existingData['ProductVariations'] != null
              ? List<Map<String, dynamic>>.from(existingData['ProductVariations'])
              : [];

          List<Map<String, dynamic>> updatedVariations = [];

          for (var newVariation in product.productVariations!) {
            Map<String, dynamic>? existingVariation;
            for (var ev in existingVariations) {
              if (ev['SKU'] == newVariation.sku || ev['Id'] == newVariation.id) {
                existingVariation = ev;
                break;
              }
            }

            Map<String, dynamic> variationData = {
              'Id': newVariation.id,
              'SKU': newVariation.sku,
              'Price': newVariation.price,
              'SalePrice': newVariation.salePrice,
              'Stock': newVariation.stock,
              'AttributeValues': newVariation.attributeValues,
            };

            if (existingVariation != null &&
                existingVariation.containsKey('Image') &&
                existingVariation['Image'] != null &&
                existingVariation['Image'].toString().isNotEmpty) {
              variationData['Image'] = existingVariation['Image'];
            } else if (newVariation.image.isNotEmpty && newVariation.image.startsWith('http')) {
              variationData['Image'] = newVariation.image;
            } else {
              variationData['Image'] = '';
            }

            updatedVariations.add(variationData);
          }

          updatePayload['ProductVariations'] = updatedVariations;
        }

        await _db.collection('Products').doc(product.id).update(updatePayload);
        print("✅ Updated: ${product.title}");
      }

      print("🎉 ALL PRODUCTS UPDATED SUCCESSFULLY! (Images preserved)");
    } catch (e) {
      print("❌ Error updating products: $e");
      throw 'Error updating products: $e';
    }
  }

  /// UPDATE ONLY SPECIFIC FIELDS FOR ALL PRODUCTS
  Future<void> updateProductPricesAndDescriptions() async {
    try {
      print("🚀 START UPDATING PRICES AND DESCRIPTIONS");

      for (var product in dummyProducts) {
        print("➡️ Updating price/description for: ${product.title}");

        Map<String, dynamic> updateData = {
          'Price': product.price,
          'SalePrice': product.salePrice,
          'ShortDescription': product.shortDescription,
          'FullDescription': product.fullDescription,
          'Highlights': product.highlights,
          'Specifications': product.specifications,
          'UpdatedAt': DateTime.now(),
        };

        if (product.productVariations != null) {
          List<Map<String, dynamic>> updatedVariations = [];

          DocumentSnapshot existingProduct = await _db.collection('Products').doc(product.id).get();

          if (existingProduct.exists) {
            Map<String, dynamic> existingData = existingProduct.data() as Map<String, dynamic>;
            List<Map<String, dynamic>> existingVariations = existingData['ProductVariations'] != null
                ? List<Map<String, dynamic>>.from(existingData['ProductVariations'])
                : [];

            for (var newVariation in product.productVariations!) {
              Map<String, dynamic>? existingVariation;
              for (var ev in existingVariations) {
                if (ev['SKU'] == newVariation.sku) {
                  existingVariation = ev;
                  break;
                }
              }

              Map<String, dynamic> variationUpdate = {
                'Id': newVariation.id,
                'SKU': newVariation.sku,
                'Price': newVariation.price,
                'SalePrice': newVariation.salePrice,
                'Stock': newVariation.stock,
                'AttributeValues': newVariation.attributeValues,
              };

              if (existingVariation != null && existingVariation['Image'] != null) {
                variationUpdate['Image'] = existingVariation['Image'];
              }

              updatedVariations.add(variationUpdate);
            }

            updateData['ProductVariations'] = updatedVariations;
          }
        }

        await _db.collection('Products').doc(product.id).update(updateData);
        print("✅ Updated: ${product.title}");
      }

      print("🎉 ALL PRODUCT PRICES AND DESCRIPTIONS UPDATED!");
    } catch (e) {
      print("❌ Error: $e");
      throw 'Error updating prices: $e';
    }
  }

  /// 🔥 FORCE SYNC (UPLOAD EVERYTHING WITH CLOUDINARY)
  Future<void> syncNewProductsOnly() async {
    try {
      print("🚀 START PRODUCT UPLOAD");

      for (var product in dummyProducts) {
        print("➡️ Processing: ${product.title}");

        product.createdAt ??= DateTime.now();
        product.updatedAt = DateTime.now();

        List<String> uploadedImages = [];

        if (product.images != null) {
          for (var imgPath in product.images!) {
            if (!imgPath.startsWith('http')) {
              final url = await uploadToCloudinary(imgPath, "products/images");
              uploadedImages.add(url);
            } else {
              uploadedImages.add(imgPath);
            }
          }
        }

        product.images = uploadedImages;

        final thumbUrl = await uploadToCloudinary(product.thumbnail, "products/thumbnail");
        product.thumbnail = thumbUrl;

        if (product.productVariations != null) {
          for (var variation in product.productVariations!) {
            if (variation.image.isNotEmpty && variation.image.startsWith('assets')) {
              variation.image = await uploadToCloudinary(variation.image, "products/variations");
            }
          }
        }

        await _db.collection('Products').doc(product.id).set(product.toJson());
        print("✅ Uploaded Product: ${product.title}");
      }

      print("🎉 ALL PRODUCTS UPLOADED");
    } catch (e) {
      throw 'Error syncing products: $e';
    }
  }

  /// UPLOAD PRODUCTS FROM ASSETS
  Future<void> uploadProductsFromAssets() async {
    try {
      for (var product in dummyProducts) {
        List<String> uploadedImages = [];

        if (product.images != null) {
          for (var imgPath in product.images!) {
            if (!imgPath.startsWith('http')) {
              final url = await uploadToCloudinary(imgPath, "products/images");
              uploadedImages.add(url);
            } else {
              uploadedImages.add(imgPath);
            }
          }
        }

        product.images = uploadedImages;

        final thumbUrl = await uploadToCloudinary(product.thumbnail, "products/thumbnail");
        product.thumbnail = thumbUrl;

        await _db.collection('Products').doc(product.id).set(product.toJson());
        print('Uploaded Product: ${product.title}');
      }

      print('All products uploaded successfully.');
    } catch (e) {
      throw 'Error uploading products: $e';
    }
  }

  /// DELETE ALL PRODUCTS
  Future<void> deleteAllProductsFromAssets() async {
    try {
      final snapshot = await _db.collection('Products').get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print("All products deleted successfully.");
    } catch (e) {
      throw 'Error deleting products: $e';
    }
  }

  /// REPLACE PRODUCTS
  Future<void> replaceProductsFromAssets() async {
    await deleteAllProductsFromAssets();
    await uploadProductsFromAssets();
  }

  /// ================= FETCH METHODS =================

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .limit(500)
          .get();

      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something Went Wrong. Please try again.';
    }
  }

  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .get();

      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something Went Wrong. Please try again.';
    }
  }

  Future<List<ProductModel>> fetchProductsByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something Went Wrong. Please try again.';
    }
  }

  Future<List<ProductModel>> getFavouriteProducts(List<String> productIds) async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      return snapshot.docs.map((querySnapshot) => ProductModel.fromSnapshot(querySnapshot)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something Went Wrong. Please try again.';
    }
  }

  Future<List<ProductModel>> getProductsForBrand({required String brandName, int limit = -1}) async {
    try {
      final querySnapshot = limit == -1
          ? await _db.collection('Products').where('Brand.Name', isEqualTo: brandName).get()
          : await _db.collection('Products').where('Brand.Name', isEqualTo: brandName).limit(limit).get();

      return querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Something Went Wrong.';
    }
  }

  Future<List<ProductModel>> getProductsForCategory({required String categoryId, int limit = 4}) async {
    try {
      QuerySnapshot productCategoryQuery = await _db
          .collection('ProductCategory')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      List<String> productIds = productCategoryQuery.docs.map((doc) => doc['productId'] as String).toList();

      final productsQuery = await _db
          .collection('Products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      return productsQuery.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Something went wrong.';
    }
  }
}