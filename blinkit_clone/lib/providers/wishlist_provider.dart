import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  List<String> _wishlistProductIds = [];

  List<String> get wishlistProductIds => _wishlistProductIds;

  WishlistProvider() {
    _loadWishlistFromPrefs();
  }

  bool isFavorite(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  void toggleFavorite(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    _saveWishlistToPrefs();
    notifyListeners();
  }

  Future<void> _loadWishlistFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.getString('wishlist_items');
      if (wishlistData != null) {
        final List<dynamic> decoded = jsonDecode(wishlistData);
        _wishlistProductIds = decoded.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _saveWishlistToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = jsonEncode(_wishlistProductIds);
      await prefs.setString('wishlist_items', wishlistData);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }
}

