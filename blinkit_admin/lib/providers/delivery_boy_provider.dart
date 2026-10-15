import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:blinkit_admin/models/delivery_boy_model.dart';

class DeliveryBoyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<String?> addDeliveryBoy(DeliveryBoyModel d) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final ref = await _firestore.collection('delivery_boys').add(d.toMap());
      return ref.id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDeliveryBoy(DeliveryBoyModel d) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('delivery_boys').doc(d.id).set(d.toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDeliveryBoy(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('delivery_boys').doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<DeliveryBoyModel>> fetchAll() async {
    final snap = await _firestore.collection('delivery_boys').get();
    return snap.docs
        .map((d) => DeliveryBoyModel.fromMap(Map<String, dynamic>.from(d.data()), d.id))
        .toList();
  }

  Stream<List<DeliveryBoyModel>> streamAll() {
    return _firestore.collection('delivery_boys').snapshots().map((snap) {
      return snap.docs
          .map((d) => DeliveryBoyModel.fromMap(Map<String, dynamic>.from(d.data()), d.id))
          .toList();
    });
  }
}
