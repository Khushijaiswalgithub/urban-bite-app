import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SupCatModel> _categories = [];
  bool _isLoading = false;

  List<SupCatModel> get categories => _categories;
  bool get isLoading => _isLoading;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  /// Fetch top-level category documents from [collection] (default: 'categories').
  /// Each document is expected to contain a `name` and `categories` array.
  Future<void> fetchCategories({String collection = 'categories'}) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore.collection(collection).get();

      _categories = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data() as Map);
        return SupCatModel.fromMap(data);
      }).toList();

      _categories.sort((a, b) {
        final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeA.compareTo(timeB);
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }
}

