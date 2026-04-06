import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// 🔥 YOUR CLOUDINARY DETAILS
  final String cloudName = "dtnfznfid";
  final String uploadPreset = "flutter_upload";

  /// 📦 LOCAL BANNER IMAGES
  final List<String> bannerAssets = [
    'assets/images/banners/banner_1.jpg',
    'assets/images/banners/banner_2.jpg',
    'assets/images/banners/banner_3.jpg',
    'assets/images/banners/banner_4.jpg',
    'assets/images/banners/banner_5.jpg',
    'assets/images/banners/banner_6.jpg',
    'assets/images/banners/banner_7.jpg',
    'assets/images/banners/banner_8.jpg',
  ];

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db
          .collection('Banners')
          .where('Active', isEqualTo: true)
          .get();

      return result.docs.map((doc) => BannerModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Something went wrong while fetching banners.';
    }
  }

  /// ✅ Upload file to Cloudinary
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
        filename: "banner.png",
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

  Future<void> uploadBannersForceClean() async {
    try {
      print("🚀 FORCE CLEAN Uploading Banners");

      for (var assetPath in bannerAssets) {
        final fileName = assetPath.split('/').last.split('.').first;
        
        final imageUrl = await uploadToCloudinary(assetPath, 'banners');

        final banner = BannerModel(
          imageUrl: imageUrl,
          active: true,
          targetScreen: '/home',
          title: 'Banner ${fileName.replaceAll('banner_', '')}',
        );

        await _db.collection('Banners').doc(fileName).set(banner.toJson());

        print("✅ Uploaded/Updated: $fileName");
      }

      print("🎉 ALL BANNERS UPDATED (NO DUPLICATES)");
    } catch (e) {
      throw "Force upload clean failed: $e";
    }
  }

  /// 🚀 UPLOAD ALL BANNERS (FIRST TIME)
  Future<void> uploadBannersToCloudinary() async {
    try {
      print("🚀 START Uploading Banners");

      for (var asset in bannerAssets) {
        print("➡️ Uploading: $asset");

        final imageUrl = await uploadToCloudinary(asset, 'banners');
        final fileName = asset.split('/').last.split('.').first;

        final banner = BannerModel(
          imageUrl: imageUrl,
          active: true,
          targetScreen: '/home',
          title: 'Banner ${fileName.replaceAll('banner_', '')}',
        );

        await _db.collection('Banners').add(banner.toJson());

        print("✅ Uploaded Banner: $imageUrl");
      }

      print("🎉 All banners uploaded successfully!");
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  /// 🔁 SYNC ONLY NEW (SMART)
  Future<void> syncNewBannersOnly() async {
    try {
      final snapshot = await _db.collection('Banners').get();
      final existingUrls = snapshot.docs.map((e) => e['ImageUrl'] as String).toSet();

      for (var asset in bannerAssets) {
        final fileName = asset.split('/').last;

        final alreadyExists = existingUrls.any((url) => url.contains(fileName));

        if (alreadyExists) {
          print("⏭️ Skipping existing: $fileName");
          continue;
        }

        final imageUrl = await uploadToCloudinary(asset, 'banners');

        final banner = BannerModel(
          imageUrl: imageUrl,
          active: true,
          targetScreen: '/home',
          title: 'New Banner',
        );

        await _db.collection('Banners').add(banner.toJson());

        print("✅ Added new banner: $fileName");
      }

      print("🎉 Sync complete!");
    } catch (e) {
      throw "Error syncing banners: $e";
    }
  }

  /// ❌ DELETE ONLY FIRESTORE
  Future<void> deleteAllBanners() async {
    final docs = await _db.collection('Banners').get();

    for (var doc in docs.docs) {
      await doc.reference.delete();
    }

    print("🗑️ All banners deleted");
  }
}