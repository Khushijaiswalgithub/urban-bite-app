import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:blinkit_admin/models/banner_model.dart';

class BannerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  /// Adds a new banner. Sets createdAt and updatedAt automatically.
  Future<String?> addBanner(BannerModel banner) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final now = Timestamp.now();
      final payload = banner.toMap()..removeWhere((k, v) => v == null);
      payload['createdAt'] = now;
      payload['updatedAt'] = now;

      final ref = await _firestore.collection('banners').add(payload);
      return ref.id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update existing banner. This will also remove legacy fields if present
  /// (title, subtitle, order) by performing a partial update and deleting
  /// those fields explicitly.
  Future<bool> updateBanner(BannerModel banner) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (banner.id.isEmpty) {
        _error = 'Banner id is required to update';
        return false;
      }

      final now = Timestamp.now();
      final payload = Map<String, dynamic>.from(banner.toMap());
      payload.remove('createdAt'); // don't overwrite createdAt
      payload['updatedAt'] = now;

      // Use update to patch fields
      try {
        await _firestore.collection('banners').doc(banner.id).update(payload);
      } on FirebaseException catch (err) {
        if (err.code == 'not-found') {
          // create the document if missing
          await _firestore.collection('banners').doc(banner.id).set(payload);
        } else {
          rethrow;
        }
      }

      // Remove legacy fields if they exist on the document
      await _firestore.collection('banners').doc(banner.id).update({
        'title': FieldValue.delete(),
        'subtitle': FieldValue.delete(),
        'order': FieldValue.delete(),
      });

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBanner(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('banners').doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetch all banners. Does not rely on 'order' field anymore.
  Future<List<BannerModel>> fetchAllBanners() async {
    final snap = await _firestore.collection('banners').get();
    return snap.docs
        .map(
          (d) => BannerModel.fromMap(Map<String, dynamic>.from(d.data()), d.id),
        )
        .toList();
  }

  Stream<List<BannerModel>> bannersStream() {
    return _firestore.collection('banners').snapshots().map((snap) {
      return snap.docs
          .map(
            (d) =>
                BannerModel.fromMap(Map<String, dynamic>.from(d.data()), d.id),
          )
          .toList();
    });
  }

  /// Upload raw bytes for a banner image to Firebase Storage and return the
  /// download URL. `bytes` should be the image file bytes. `contentType` is
  /// optional (e.g. 'image/jpeg'). Returns null on failure.
  Future<String?> uploadBannerImageBytes(
    Uint8List bytes, {
    String? contentType,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final storage = FirebaseStorage.instance;
      final fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child(fileName);

      final metadata = SettableMetadata(
        contentType: contentType ?? 'image/jpeg',
      );

      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
