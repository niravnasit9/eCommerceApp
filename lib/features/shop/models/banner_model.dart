import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String id;
  String imageUrl;
  String targetScreen;
  String title;
  bool active;

  BannerModel({
    this.id = '',
    required this.imageUrl,
    required this.targetScreen,
    this.title = '',
    required this.active,
  });

  /// Empty helper
  static BannerModel empty() => BannerModel(
        imageUrl: '',
        targetScreen: '',
        active: false,
      );

  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': imageUrl,
      'TargetScreen': targetScreen,
      'Title': title,
      'Active': active,
    };
  }

  factory BannerModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      
      return BannerModel(
        id: document.id,
        imageUrl: data['ImageUrl']?.toString() ?? '',
        targetScreen: data['TargetScreen']?.toString() ?? '',
        title: data['Title']?.toString() ?? '',
        active: data['Active'] == true,
      );
    } else {
      return BannerModel.empty();
    }
  }

  factory BannerModel.fromJson(Map<String, dynamic> json, String id) {
    return BannerModel(
      id: id,
      imageUrl: json['ImageUrl']?.toString() ?? json['imageUrl']?.toString() ?? '',
      targetScreen: json['TargetScreen']?.toString() ?? json['targetScreen']?.toString() ?? '',
      title: json['Title']?.toString() ?? json['title']?.toString() ?? '',
      active: json['Active'] == true || json['active'] == true,
    );
  }
}