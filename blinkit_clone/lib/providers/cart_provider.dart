import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class RestaurantConflictException implements Exception {
  final String existingRestaurant;
  final String newRestaurant;

  RestaurantConflictException({
    required this.existingRestaurant,
    required this.newRestaurant,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  CartProvider() {
    _loadCartFromPrefs();
  }

  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items', cartData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  List<CartItem> get items => [..._items];

  int get itemCount => _items.fold(0, (sum, item) => sum + item.count);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get originalTotalAmount => _items.fold(0.0, (sum, item) => sum + item.originalTotalPrice);

  double get totalSavings => originalTotalAmount - totalAmount;

  bool get isEmpty => _items.isEmpty;

  void addItem(ProductModel product, {bool force = false}) {
    if (_items.isNotEmpty && !force) {
      final firstWithRestaurant = _items.firstWhere(
        (item) => item.restaurantName != null,
        orElse: () => _items.first,
      );
      final existingRestaurant = firstWithRestaurant.restaurantName;
      
      if (existingRestaurant != null &&
          product.restaurantName != null &&
          existingRestaurant != product.restaurantName) {
        throw RestaurantConflictException(
          existingRestaurant: existingRestaurant,
          newRestaurant: product.restaurantName!,
        );
      }
    }

    if (force) {
      _items.clear();
    }

    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id && item.quantity == product.quantity,
    );
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        count: _items[existingIndex].count + 1,
      );
    } else {
      _items.add(
        CartItem(
          id: DateTime.now().toString(),
          productId: product.id ?? '',
          name: product.name,
          image: product.images.isNotEmpty ? product.images[0] : '',
          price: product.price,
          discountPercent: product.discountPercent,
          quantity: product.quantity,
          restaurantName: product.restaurantName,
        ),
      );
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(String productId, String quantity) {
    _items.removeWhere((item) => item.productId == productId && item.quantity == quantity);
    _saveCartToPrefs();
    notifyListeners();
  }

  void updateQuantity(String productId, String quantity, int newCount) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId && item.quantity == quantity,
    );
    
    if (existingIndex >= 0) {
      if (newCount <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex] = _items[existingIndex].copyWith(count: newCount);
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }
}

