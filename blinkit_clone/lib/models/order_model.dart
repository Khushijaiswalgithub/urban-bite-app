import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final DateTime createdAt;
  final String status;
  final String? otp;
  final bool isOtpVerified;
  final Map<String, dynamic>? deliveryBoy;
  final Map<String, dynamic>? deliveryAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.createdAt,
    this.status = 'placed',
    this.otp,
    this.isOtpVerified = false,
    this.deliveryBoy,
    this.deliveryAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items
          .map(
            (i) => {
              'id': i.id,
              'productId': i.productId,
              'name': i.name,
              'image': i.image,
              'price': i.price,
              'discountPercent': i.discountPercent,
              'quantity': i.quantity,
              'count': i.count,
              'totalPrice': i.totalPrice,
            },
          )
          .toList(),
      'totalAmount': totalAmount,
      'originalAmount': originalAmount,
      'savings': savings,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'otp': otp,
      'isOtpVerified': isOtpVerified,
      'deliveryBoy': deliveryBoy,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = (data['items'] as List<dynamic>?) ?? [];
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: itemsData
          .map(
            (e) => CartItem(
              id: e['id'] as String? ?? '',
              productId: e['productId'] as String? ?? '',
              name: e['name'] as String? ?? '',
              image: e['image'] as String? ?? '',
              price: (e['price'] as num?)?.toDouble() ?? 0.0,
              discountPercent:
                  (e['discountPercent'] as num?)?.toDouble() ?? 0.0,
              quantity: e['quantity'] as String? ?? '',
              count: (e['count'] as int?) ?? 1,
            ),
          )
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      originalAmount: (data['originalAmount'] as num?)?.toDouble() ?? 0.0,
      savings: (data['savings'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'placed',
      otp: data['otp'] as String?,
      isOtpVerified: data['isOtpVerified'] as bool? ?? false,
      deliveryBoy: data['deliveryBoy'] as Map<String, dynamic>?,
      deliveryAddress: data['deliveryAddress'] as Map<String, dynamic>?,
    );
  }
}

