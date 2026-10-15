import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:blinkit_admin/models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImageBytes(Uint8List bytes, {String? contentType}) async {
    final fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    final meta = SettableMetadata(contentType: contentType ?? 'image/jpeg');
    final task = await ref.putData(bytes, meta);
    final url = await task.ref.getDownloadURL();
    return url;
  }

  Future<String> createBanner(BannerModel banner) async {
    final now = Timestamp.now();
    final payload = Map<String, dynamic>.from(banner.toMap());
    payload['createdAt'] = now;
    payload['updatedAt'] = now;
    final ref = await _firestore.collection('banners').add(payload);
    return ref.id;
  }

  Future<void> updateBanner(BannerModel banner) async {
    final now = Timestamp.now();
    final payload = Map<String, dynamic>.from(banner.toMap());
    payload.remove('createdAt');
    payload['updatedAt'] = now;

    await _firestore.collection('banners').doc(banner.id).update(payload);

    // Remove legacy fields
    await _firestore.collection('banners').doc(banner.id).update({
      'title': FieldValue.delete(),
      'subtitle': FieldValue.delete(),
      'order': FieldValue.delete(),
    });
  }

  Future<BannerModel?> fetchBanner(String id) async {
    final doc = await _firestore.collection('banners').doc(id).get();
    if (!doc.exists) return null;
    return BannerModel.fromMap(Map<String, dynamic>.from(doc.data()!), doc.id);
  }
}
