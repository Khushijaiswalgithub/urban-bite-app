import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static const String _storageKey = 'app_notifications_list';

  // Real-time listener subscriptions
  StreamSubscription? _productsSubscription;
  StreamSubscription? _ordersSubscription;

  // Caches to track status shifts
  final Set<String> _cachedProductIds = {};
  final Map<String, double> _cachedProductDiscounts = {};
  final Map<String, String> _cachedOrderStatus = {};
  String? _activeUserId;

  NotificationProvider() {
    loadNotifications();
  }

  /// Load saved notifications from local SharedPreferences
  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_storageKey);
      if (listJson != null) {
        _notifications = listJson
            .map((str) => AppNotification.fromJson(jsonDecode(str) as Map<String, dynamic>))
            .toList();
        // Sort newest first
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  /// Save current notifications to local SharedPreferences
  Future<void> saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_storageKey, listJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Add a new notification (triggers local notification banner & saves)
  Future<void> addNotification({
    required String title,
    required String body,
  }) async {
    final newNotif = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, newNotif);
    notifyListeners();
    await saveNotifications();

    // Trigger native mobile local notification banner
    await NotificationService.showLocalNotification(
      id: newNotif.id.hashCode,
      title: title,
      body: body,
      payload: newNotif.id,
    );
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
      await saveNotifications();
    }
  }

  /// Delete a single notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    await saveNotifications();
  }

  /// Real-time listener: Listen to 'products' collection for additions and offers
  void listenToProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      final isInitial = _cachedProductIds.isEmpty;

      for (var doc in snapshot.docs) {
        final id = doc.id;
        final data = doc.data();
        final name = data['name']?.toString() ?? 'Food Item';
        final discount = double.tryParse((data['discountpercent'] ?? data['discount_percent'] ?? data['discount'] ?? 0).toString()) ?? 0.0;

        if (isInitial) {
          _cachedProductIds.add(id);
          _cachedProductDiscounts[id] = discount;
        } else {
          // If the product is new to our cache
          if (!_cachedProductIds.contains(id)) {
            _cachedProductIds.add(id);
            _cachedProductDiscounts[id] = discount;
            addNotification(
              title: '🆕 New Food Added!',
              body: 'Try the all-new "$name" now!',
            );
          } else {
            // Check if discount percent increased
            final oldDiscount = _cachedProductDiscounts[id] ?? 0.0;
            if (discount > oldDiscount && discount > 0) {
              addNotification(
                title: '🔥 Special Offer Alert!',
                body: 'Get "$name" now at ${discount.toStringAsFixed(0)}% off!',
              );
            }
            _cachedProductDiscounts[id] = discount;
          }
        }
      }
    }, onError: (e) {
      debugPrint('Error listening to products: $e');
    });
  }

  /// Real-time listener: Listen to current user's active orders
  void listenToOrders(String userId) {
    if (_activeUserId == userId && _ordersSubscription != null) return;

    _ordersSubscription?.cancel();
    _cachedOrderStatus.clear();
    _activeUserId = userId;

    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final isInitial = _cachedOrderStatus.isEmpty;

      for (var doc in snapshot.docs) {
        final id = doc.id;
        final data = doc.data();
        final status = data['status']?.toString() ?? 'placed';

        if (isInitial) {
          _cachedOrderStatus[id] = status;
        } else {
          final oldStatus = _cachedOrderStatus[id];
          if (oldStatus != null && oldStatus != status) {
            _cachedOrderStatus[id] = status;

            String title = 'Order Update';
            String body = 'Your order status is now $status';

            if (status == 'placed') {
              title = '🛒 Order Placed!';
              body = 'Your order is placed successfully and is waiting to be accepted.';
            } else if (status == 'accepted') {
              title = '👨‍🍳 Order Accepted!';
              body = 'The kitchen has accepted your order and is preparing your meal.';
            } else if (status == 'out_for_delivery') {
              title = '🚴 Out for Delivery!';
              body = 'Your order is out for delivery! A rider will reach you shortly.';
            } else if (status == 'delivered') {
              title = '🍽️ Order Delivered!';
              body = 'Your order has been successfully delivered. Enjoy your meal!';
            } else if (status == 'cancelled') {
              title = '❌ Order Cancelled';
              body = 'Your order has been cancelled.';
            }

            addNotification(title: title, body: body);
          } else if (oldStatus == null) {
            _cachedOrderStatus[id] = status;
          }
        }
      }
    }, onError: (e) {
      debugPrint('Error listening to orders: $e');
    });
  }

  /// Cancel user order listeners (called on logout)
  void cancelListeners() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _cachedOrderStatus.clear();
    _activeUserId = null;
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

