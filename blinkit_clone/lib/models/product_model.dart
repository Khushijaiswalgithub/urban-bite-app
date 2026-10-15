// Simple product model used by product screens.
// Fields: name, images, quantity, price, discountPercent,
// optional description, productDetail, returnPolicy, variants.
import 'dart:convert';

class ProductVariant {
  final String quantity;
  final double price;
  final double discountPercent;

  ProductVariant({
    required this.quantity,
    required this.price,
    required this.discountPercent,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    return ProductVariant(
      quantity: json['quantity']?.toString() ?? '',
      price: toDouble(json['price']),
      discountPercent: toDouble(
        json['discountpercent'] ?? json['discount_percent'] ?? json['discount'] ?? 0.0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'price': price,
    'discountpercent': discountPercent,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariant &&
        other.quantity == quantity &&
        other.price == price &&
        other.discountPercent == discountPercent;
  }

  @override
  int get hashCode => Object.hash(quantity, price, discountPercent);
}

class ProductModel {
  final String? id; // optional identifier (assumption: some payloads include an id)
  final String name;
  final List<String> images;
  final String quantity;
  final double price;
  final double discountPercent;

  // Category fields
  final String? superCategory;
  final String? subCategory;
  final String? subSubCategory;

  // About / descriptive fields
  final String? description;
  final String? productDetail;
  final String? returnPolicy;

  // Restaurant field (Zomato Clone)
  final String? restaurantName;

  // Variants field
  final List<ProductVariant> variants;

  // New fields for rating and delivery time
  final double rating;
  final int deliveryTime;
  final bool isVeg; // Add isVeg flag

  // Video field
  final String? video;

  ProductModel({
    this.id,
    required this.name,
    List<String>? images,
    String? quantity,
    double? price,
    double? discountPercent,
    this.superCategory,
    this.subCategory,
    this.subSubCategory,
    this.description,
    this.productDetail,
    this.returnPolicy,
    this.restaurantName,
    List<ProductVariant>? variants,
    double? rating,
    int? deliveryTime,
    bool? isVeg,
    this.video,
  }) : images = images ?? [],
       quantity = quantity ?? '0',
       price = price ?? 0.0,
       discountPercent = discountPercent ?? 0.0,
       variants = variants ?? [],
       rating = rating ?? 4.0,
       deliveryTime = deliveryTime ?? 20,
       isVeg = isVeg ?? true;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // images may be under 'image' or 'images'
    List<String> parseImages(dynamic val) {
      if (val is List) return val.map((e) => e?.toString() ?? '').toList();
      if (val is String && val.isNotEmpty) return [val];
      return <String>[];
    }

    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool parseVeg(dynamic jsonVal) {
      if (jsonVal['isVeg'] != null) {
        if (jsonVal['isVeg'] is bool) return jsonVal['isVeg'] as bool;
        if (jsonVal['isVeg'] is String) return jsonVal['isVeg'].toString().toLowerCase() == 'true';
      }
      if (jsonVal['is_veg'] != null) {
        if (jsonVal['is_veg'] is bool) return jsonVal['is_veg'] as bool;
        if (jsonVal['is_veg'] is String) return jsonVal['is_veg'].toString().toLowerCase() == 'true';
      }
      
      // Fallback: check name & description
      final nameLower = (jsonVal['name']?.toString() ?? '').toLowerCase();
      final descLower = (jsonVal['description']?.toString() ?? '').toLowerCase();
      final list = ['chicken', 'pepperoni', 'fish', 'meat', 'mutton', 'egg', 'beef', 'non-veg', 'non_veg'];
      for (final keyword in list) {
        if (nameLower.contains(keyword) || descLower.contains(keyword)) {
          return false;
        }
      }
      return true;
    }

    final variantsData = json['variants'] as List<dynamic>?;
    final List<ProductVariant> variantsList = variantsData != null
        ? variantsData
            .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList()
        : [];

    return ProductModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      images: parseImages(json['image'] ?? json['images']),
      quantity: json['quantity']?.toString() ?? '0',
      price: toDouble(json['price'] ?? json['mrp'] ?? json['rate']),
      discountPercent: toDouble(
        json['discountpercent'] ?? json['discount_percent'] ?? json['discount'],
      ),
      superCategory:
          json['superCategory']?.toString() ??
          json['super_category']?.toString() ??
          json['super category']?.toString(),
      subCategory:
          json['subCategory']?.toString() ??
          json['sub_category']?.toString() ??
          json['sub category']?.toString(),
      subSubCategory:
          json['subSubCategory']?.toString() ??
          json['sub_sub_category']?.toString() ??
          json['sub sub category']?.toString(),
      description: json['description']?.toString(),
      productDetail:
          json['product detail']?.toString() ??
          json['product_detail']?.toString() ??
          json['productDetail']?.toString(),
      returnPolicy:
          json['return']?.toString() ?? json['returnPolicy']?.toString(),
      restaurantName: json['restaurantName']?.toString() ?? json['restaurant_name']?.toString(),
      variants: variantsList,
      rating: toDouble(json['rating'] ?? 4.0),
      deliveryTime: toInt(json['deliveryTime'] ?? json['delivery_time'] ?? 20),
      isVeg: parseVeg(json),
      video: json['video']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    // keep key `image` to match existing shape in database in the repo
    'image': images,
    'quantity': quantity,
    'price': price,
    'discountpercent': discountPercent,
    'superCategory': superCategory,
    'subCategory': subCategory,
    'subSubCategory': subSubCategory,
    'description': description,
    'product detail': productDetail,
    'return': returnPolicy,
    if (restaurantName != null) 'restaurantName': restaurantName,
    'variants': variants.map((v) => v.toJson()).toList(),
    'rating': rating,
    'deliveryTime': deliveryTime,
    'isVeg': isVeg,
    if (video != null) 'video': video,
  };

  ProductModel copyWith({
    String? id,
    String? name,
    List<String>? images,
    String? quantity,
    double? price,
    double? discountPercent,
    String? superCategory,
    String? subCategory,
    String? subSubCategory,
    String? description,
    String? productDetail,
    String? returnPolicy,
    String? restaurantName,
    List<ProductVariant>? variants,
    double? rating,
    int? deliveryTime,
    bool? isVeg,
    String? video,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      superCategory: superCategory ?? this.superCategory,
      subCategory: subCategory ?? this.subCategory,
      subSubCategory: subSubCategory ?? this.subSubCategory,
      description: description ?? this.description,
      productDetail: productDetail ?? this.productDetail,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      restaurantName: restaurantName ?? this.restaurantName,
      variants: variants ?? this.variants,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isVeg: isVeg ?? this.isVeg,
      video: video ?? this.video,
    );
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
        other.id == id &&
        other.name == name &&
        _listEquals(other.images, images) &&
        other.quantity == quantity &&
        other.price == price &&
        other.discountPercent == discountPercent &&
        other.superCategory == superCategory &&
        other.subCategory == subCategory &&
        other.subSubCategory == subSubCategory &&
        other.description == description &&
        other.productDetail == productDetail &&
        other.returnPolicy == returnPolicy &&
        other.restaurantName == restaurantName &&
        other.rating == rating &&
        other.deliveryTime == deliveryTime &&
        other.isVeg == isVeg &&
        other.video == video &&
        _listEquals(other.variants, variants);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    Object.hashAll(images),
    quantity,
    price,
    discountPercent,
    superCategory,
    subCategory,
    subSubCategory,
    description,
    productDetail,
    returnPolicy,
    restaurantName,
    rating,
    deliveryTime,
    isVeg,
    video,
    Object.hashAll(variants),
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

