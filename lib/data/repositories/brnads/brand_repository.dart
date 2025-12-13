import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/firebase_exceptions.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/format_exceptions.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/platform_exceptions.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db.collection('Brands').get();
      return snapshot.docs.map((e) => BrandModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (__) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Brands.';
    }
  }

  /// Get Brands For Category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      QuerySnapshot brandCategoryQuery = await _db
          .collection('BrandCategory')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      List<String> brandIds = brandCategoryQuery.docs
          .map((doc) => doc['brandId'] as String)
          .toList();

      final brandsQuery = await _db
          .collection('Brands')
          .where(FieldPath.documentId, whereIn: brandIds)
          .limit(2)
          .get();

      List<BrandModel> brands =
          brandsQuery.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();

      return brands;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (__) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Brands.';
    }
  }

  /// Upload or replace brand with image to Firebase Storage
  Future<void> uploadOrReplaceBrand(BrandModel brand) async {
    try {
      // Load image from assets
      ByteData byteData = await rootBundle.load(brand.image);
      Uint8List imageData = byteData.buffer.asUint8List();

      // Upload to Firebase Storage
      final ref = _storage.ref().child('brands/${brand.id}.png');
      await ref.putData(imageData);
      final downloadUrl = await ref.getDownloadURL();

      // Update image URL
      brand.image = downloadUrl;

      // Set / replace document in Firestore
      await _db.collection('Brands').doc(brand.id).set(brand.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } catch (e) {
      throw 'Error uploading brand: $e';
    }
  }

  /// Upload all brands
  Future<void> uploadAllBrands(List<BrandModel> brands) async {
    for (var brand in brands) {
      await uploadOrReplaceBrand(brand);
    }
  }
}
