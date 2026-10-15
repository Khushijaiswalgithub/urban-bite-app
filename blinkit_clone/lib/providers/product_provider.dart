import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];
  List<ProductModel> _categoryProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  List<ProductModel> get products => _products;
  List<ProductModel> get categoryProducts => _categoryProducts;
  List<ProductModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSearching(bool v) {
    _isSearching = v;
    notifyListeners();
  }

  /// Fetch all products from [collection] (default: 'products').
  Future<void> fetchProducts({String collection = 'products'}) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore.collection(collection).get();

      _products = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data() as Map);
        // ensure id is available to the model
        data['id'] = d.id;
        return ProductModel.fromJson(data);
      }).toList();

      // Also sync category products to the full list by default
      _categoryProducts = List.from(_products);

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch products matching a field/value pair, e.g. category, subcategory, etc.
  Future<void> fetchProductsByField(
    String field,
    dynamic value, {
    String collection = 'products',
  }) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();

      _categoryProducts = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data() as Map);
        data['id'] = d.id;
        return ProductModel.fromJson(data);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products by $field: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Convenience: fetch products by the `superCategory` field.
  /// Use [field] override if your Firestore uses a different key (e.g. 'super_category').
  Future<void> fetchProductsBySuperCategory(
    String superCategory, {
    String collection = 'products',
    String field = 'superCategory',
  }) async {
    return fetchProductsByField(field, superCategory, collection: collection);
  }

  /// Convenience: fetch products by the `subCategory` field.
  /// Use [field] override if your Firestore uses a different key (e.g. 'sub_category').
  Future<void> fetchProductsBySubCategory(
    String subCategory, {
    String collection = 'products',
    String field = 'subCategory',
  }) async {
    return fetchProductsByField(field, subCategory, collection: collection);
  }

  /// Convenience: fetch products by both `subCategory` and `subSubCategory` fields.
  Future<void> fetchProductsBySubSubCategory(
    String subCategory,
    String subSubCategory, {
    String collection = 'products',
  }) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection(collection)
          .where('subCategory', isEqualTo: subCategory)
          .where('subSubCategory', isEqualTo: subSubCategory)
          .get();

      _categoryProducts = snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data() as Map);
        data['id'] = d.id;
        return ProductModel.fromJson(data);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products by subSubCategory: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch single product by document id
  Future<ProductModel?> fetchProductById(
    String id, {
    String collection = 'products',
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      return ProductModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching product by id: $e');
      return null;
    }
  }

  Future<void> searchProducts(
    String query, {
    String collection = 'products',
  }) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      _setSearching(false);
      return;
    }

    try {
      _setSearching(true);
      _searchQuery = query;

      // Search in product names (case insensitive)
      final snapshot = await _firestore.collection(collection).get();

      final lowerQuery = query.toLowerCase();
      _searchResults = snapshot.docs
          .map((d) {
            final data = Map<String, dynamic>.from(d.data() as Map);
            data['id'] = d.id;
            return ProductModel.fromJson(data);
          })
          .where(
            (product) =>
                product.name.toLowerCase().contains(lowerQuery) ||
                (product.superCategory ?? '').toLowerCase().contains(
                  lowerQuery,
                ) ||
                (product.subCategory ?? '').toLowerCase().contains(lowerQuery),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error searching products: $e');
      _searchResults = [];
    } finally {
      _setSearching(false);
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}

