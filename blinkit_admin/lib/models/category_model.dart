import 'dart:convert';

/// Model representing a child category with a name and an image URL/path.
class Category {
  final String name;
  final String image;
  final List<Category>? subCategories;

  Category({required this.name, required this.image, this.subCategories});

  Category copyWith({String? name, String? image, List<Category>? subCategories}) {
    return Category(
      name: name ?? this.name, 
      image: image ?? this.image,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name, 
      'image': image,
      if (subCategories != null) 
        'subCategories': subCategories!.map((c) => c.toMap()).toList(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    List<Category>? parsedSubs;
    if (map['subCategories'] != null) {
      final rawList = map['subCategories'];
      if (rawList is List) {
        parsedSubs = rawList.map<Category>((e) {
          if (e is Map<String, dynamic>) return Category.fromMap(e);
          if (e is Map) return Category.fromMap(Map<String, dynamic>.from(e));
          return Category(name: '', image: '');
        }).toList();
      }
    }

    return Category(
      name: map['name'] as String? ?? '',
      image: map['image'] as String? ?? '',
      subCategories: parsedSubs,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));

  @override
  String toString() => 'Category(name: $name, image: $image)';
}

/// Model representing a main category (super category) that has a name
/// and a list of child `Category` items.
class SupCatModel {
  final String name;
  final List<Category> categories;
  final DateTime? createdAt;

  SupCatModel({required this.name, required this.categories, this.createdAt});

  SupCatModel copyWith({String? name, List<Category>? categories, DateTime? createdAt}) {
    return SupCatModel(
      name: name ?? this.name,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categories': categories.map((c) => c.toMap()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory SupCatModel.fromMap(Map<String, dynamic> map) {
    final rawList = map['categories'];
    List<Category> parsed = [];
    if (rawList is List) {
      parsed = rawList.map<Category>((e) {
        if (e is Map<String, dynamic>) return Category.fromMap(e);
        if (e is Map) return Category.fromMap(Map<String, dynamic>.from(e));
        if (e is String) return Category.fromJson(e);
        return Category(name: '', image: '');
      }).toList();
    }

    DateTime? parsedDate;
    final cd = map['createdAt'];
    if (cd != null) {
      if (cd is String) {
        parsedDate = DateTime.tryParse(cd);
      } else if (cd.runtimeType.toString() == 'Timestamp') {
        parsedDate = (cd as dynamic).toDate();
      }
    }

    return SupCatModel(
      name: map['name'] as String? ?? '', 
      categories: parsed,
      createdAt: parsedDate,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupCatModel.fromJson(String source) =>
      SupCatModel.fromMap(json.decode(source));

  @override
  String toString() => 'SupCatModel(name: $name, categories: $categories)';
}
