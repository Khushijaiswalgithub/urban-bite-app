import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> assignedOrdersStream({
    required String deliveryBoyId,
  }) {
    return _db
        .collection('orders')
        .where('deliveryBoy.id', isEqualTo: deliveryBoyId)
        .snapshots()
        .map(
          (snap) {
            final list = snap.docs
                .map((d) => OrderModel.fromMap(d.data(), id: d.id))
                .toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final orderRef = _db.collection('orders').doc(orderId);
    await _db.runTransaction((txn) async {
      final doc = await txn.get(orderRef);
      if (!doc.exists) return;
      txn.update(orderRef, {'status': newStatus});
    });
  }

  Future<bool> verifyOtp({required String orderId, required String otp}) async {
    final orderRef = _db.collection('orders').doc(orderId);
    bool success = false;

    await _db.runTransaction((txn) async {
      final doc = await txn.get(orderRef);
      if (!doc.exists) return;

      final data = doc.data();
      if (data != null &&
          data['otp'] == otp &&
          !(data['isOtpVerified'] as bool? ?? false)) {
        txn.update(orderRef, {'isOtpVerified': true, 'status': 'delivered'});
        success = true;
      }
    });

    return success;
  }

  // Stats helpers
  Stream<int> totalCompletedDeliveries({required String deliveryBoyId}) {
    return _db
        .collection('orders')
        .where('deliveryBoy.id', isEqualTo: deliveryBoyId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<double> totalEarnings({required String deliveryBoyId}) {
    return _db
        .collection('orders')
        .where('deliveryBoy.id', isEqualTo: deliveryBoyId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map(
          (s) => s.docs.fold<double>(
            0,
            (sum, d) =>
                sum + ((d.data()['totalAmount'] as num?)?.toDouble() ?? 0),
          ),
        );
  }
}
