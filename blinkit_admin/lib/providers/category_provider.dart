import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:blinkit_admin/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<String?> uploadCategoryImageBytes(Uint8List bytes) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('categories').child(fileName);

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Adds a top-level super-category document to `categories` collection.
  /// The document shape matches `SupCatModel.toMap()`.
  Future<String?> addSupCategory(SupCatModel supCat) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = supCat.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      final ref = await _firestore.collection('categories').add(data);
      return ref.id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupCategory(String id, SupCatModel supCat) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('categories').doc(id).set(supCat.toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupCategory(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('categories').doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<SupCatModel>> fetchAllSupCategories() async {
    final snap = await _firestore.collection('categories').get();
    return snap.docs
        .map((d) => SupCatModel.fromMap(Map<String, dynamic>.from(d.data())))
        .toList();
  }

  Stream<List<SupCatModel>> supCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snap) {
      return snap.docs
          .map((d) => SupCatModel.fromMap(Map<String, dynamic>.from(d.data())))
          .toList();
    });
  }

  /// Stream of pairs (docId, SupCatModel) so UI can perform update/delete
  /// operations which require the Firestore document id.
  Stream<List<MapEntry<String, SupCatModel>>> supCategoriesWithIdStream() {
    return _firestore.collection('categories').snapshots().map((snap) {
      final list = snap.docs
          .map(
            (d) => MapEntry<String, SupCatModel>(
              d.id,
              SupCatModel.fromMap(Map<String, dynamic>.from(d.data())),
            ),
          )
          .toList();
      
      list.sort((a, b) {
        final timeA = a.value.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.value.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeA.compareTo(timeB);
      });
      
      return list;
    });
  }
}
