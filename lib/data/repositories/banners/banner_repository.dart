import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/firebase_exceptions.dart';
import 'package:yt_ecommerce_admin_panel/utils/exceptions/platform_exceptions.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// FETCH ACTIVE BANNERS

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db
          .collection('Banners')
          .where('Active', isEqualTo: true)
          .get();

      return result.docs.map((doc) => BannerModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching banners.';
    }
  }

  /// CHECK IF ANY BANNERS ALREADY EXIST

  Future<bool> bannersAlreadyUploaded() async {
    final snapshot = await _db.collection('Banners').get();
    return snapshot.docs.isNotEmpty;
  }

  /// UPLOAD DEFAULT BANNERS (FROM ASSETS)

  Future<void> uploadBanners() async {
    try {
      if (await bannersAlreadyUploaded()) {
        throw 'Banners already exist in the database.';
      }

      final bannerImages = [
        'assets/images/banners/banner_1.jpg',
        'assets/images/banners/banner_2.jpg',
        'assets/images/banners/banner_3.jpg',
        'assets/images/banners/banner_4.jpg',
        'assets/images/banners/banner_5.jpg',
        'assets/images/banners/banner_6.jpg',
        'assets/images/banners/banner_7.jpg',
      ];

      for (int i = 0; i < bannerImages.length; i++) {
        final assetPath = bannerImages[i];
        final fileName = 'banner_${i + 1}.jpg';

        // Load asset bytes
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();

        // Upload to Storage
        final storageRef = _storage.ref().child('Banners/$fileName');
        await storageRef.putData(bytes);

        // Get download URL
        final imageUrl = await storageRef.getDownloadURL();

        // Save to Firestore
        final banner = BannerModel(
          imageUrl: imageUrl,
          active: true,
          targetScreen: '/',
        );

        await _db.collection('Banners').add(banner.toJson());
        print('Uploaded Banner: $fileName');
      }

      print('All banners uploaded successfully.');
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  /// DELETE ALL BANNERS (Firestore + Storage)

  Future<void> deleteAllBanners() async {
    try {
      // Delete Firestore docs
      final docs = await _db.collection('Banners').get();
      for (var doc in docs.docs) {
        await doc.reference.delete();
      }

      // Delete storage files
      final folder = _storage.ref().child('Banners');
      final files = await folder.listAll();

      for (var img in files.items) {
        await img.delete();
      }

      print("All banners deleted successfully.");
    } catch (e) {
      throw 'Error deleting all banners.';
    }
  }

  /// REPLACE BANNERS (Delete + Upload New)
  Future<void> replaceBanners() async {
    await deleteAllBanners();
    await uploadBanners();
  }

  /// DELETE SINGLE BANNER
  Future<void> deleteBanner(String docId, String imageUrl) async {
    try {
      await _db.collection('Banners').doc(docId).delete();
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      throw 'Error deleting banner.';
    }
  }

  /// UPDATE ACTIVE STATUS
  Future<void> updateBannerStatus(String docId, bool isActive) async {
    try {
      await _db.collection('Banners').doc(docId).update({
        'Active': isActive,
      });
    } catch (e) {
      throw 'Error updating banner status.';
    }
  }
}
