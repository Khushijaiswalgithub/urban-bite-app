class CartItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final double discountPercent;
  final String quantity;
  final String? restaurantName;
  int count;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.discountPercent,
    required this.quantity,
    this.restaurantName,
    this.count = 1,
  });

  double get discountedPrice => price * (1 - discountPercent / 100);
  double get totalPrice => discountedPrice * count;
  double get originalTotalPrice => price * count;
  double get savings => originalTotalPrice - totalPrice;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    double? discountPercent,
    String? quantity,
    String? restaurantName,
    int? count,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      quantity: quantity ?? this.quantity,
      restaurantName: restaurantName ?? this.restaurantName,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'discountPercent': discountPercent,
      'quantity': quantity,
      'restaurantName': restaurantName,
      'count': count,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      quantity: json['quantity'] as String,
      restaurantName: json['restaurantName'] as String?,
      count: json['count'] as int,
    );
  }
}

