import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Place an order and return the created OrderModel
  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required double originalAmount,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    final savings = (originalAmount - totalAmount).clamp(0, double.infinity);
    final createdAt = DateTime.now();

    // Generate a 6-digit OTP
    final otp = (100000 + DateTime.now().microsecond % 900000).toString();

    // Defensive: ensure deliveryAddress is a plain map if provided
    Map<String, dynamic>? addressToStore;
    if (deliveryAddress != null) {
      try {
        addressToStore = Map<String, dynamic>.from(deliveryAddress);
      } catch (_) {
        addressToStore = null;
      }
    }

    // Debug log
    debugPrint(
      'Placing order for userId=$userId with deliveryAddress=$addressToStore',
    );

    final docRef = await _firestore.collection('orders').add({
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
      'status': 'placed',
      'otp': otp,
      'isOtpVerified': false,
      'deliveryAddress': addressToStore,
    });

    final doc = await docRef.get();
    final order = OrderModel.fromDoc(doc);
    notifyListeners();
    return order;
  }

  // Stream orders for a specific user ordered by createdAt desc
  Stream<List<OrderModel>> streamOrdersForUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => OrderModel.fromDoc(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}

