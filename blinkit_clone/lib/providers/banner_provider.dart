import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/banner_model.dart';

class BannerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // Fetch banners from 'banners' collection, ordered by 'order'
  Future<void> fetchBanners() async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection('banners')
          .where('active', isEqualTo: true)
          .get();

      _banners = snapshot.docs
          .map((d) => BannerModel.fromMap(d.data(), d.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    } finally {
      _setLoading(false);
    }
  }
}

