import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/delivery_boy.dart';

class DeliveryBoyProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DeliveryBoy? _deliveryBoy;
  DeliveryBoy? get deliveryBoy => _deliveryBoy;

  bool _loading = false;
  bool get loading => _loading;

  Future<DeliveryBoy?> fetchById(String deliveryBoyId) async {
    _loading = true;
    notifyListeners();
    try {
      final doc = await _db.collection('delivery_boys').doc(deliveryBoyId).get();
      if (doc.exists) {
        _deliveryBoy = DeliveryBoy.fromMap(doc.id, doc.data() ?? {});
        return _deliveryBoy;
      }
    } catch (_) {}

    try {
      final q = await _db
          .collection('delivery_boys')
          .where('deliveryBoyId', isEqualTo: deliveryBoyId)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final doc = q.docs.first;
        _deliveryBoy = DeliveryBoy.fromMap(doc.id, doc.data());
        return _deliveryBoy;
      }
      _deliveryBoy = null;
      return null;
    } catch (e) {
      _deliveryBoy = null;
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _deliveryBoy = null;
    notifyListeners();
  }
}
