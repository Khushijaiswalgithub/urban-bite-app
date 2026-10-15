import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String bannerImage; // new field name replacing imageUrl
  final List<String> products; // list of product ids
  final bool active;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  BannerModel({
    required this.id,
    required this.bannerImage,
    List<String>? products,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  }) : products = products ?? [];

  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    final rawProducts = map['products'];
    List<String> parsedProducts = <String>[];
    if (rawProducts is List) {
      parsedProducts = rawProducts
          .map((e) => e?.toString() ?? '')
          .cast<String>()
          .toList();
    }

    return BannerModel(
      id: id,
      bannerImage:
          map['bannerImage'] as String? ?? map['imageUrl'] as String? ?? '',
      products: parsedProducts,
      active: map['active'] == null ? true : (map['active'] as bool),
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bannerImage': bannerImage,
      'products': products,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BannerModel copyWith({
    String? id,
    String? bannerImage,
    List<String>? products,
    bool? active,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      bannerImage: bannerImage ?? this.bannerImage,
      products: products ?? this.products,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
