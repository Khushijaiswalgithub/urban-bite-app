import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user/user_model.dart';

/// A simple provider that loads a `UserModel` from Firestore and exposes
/// loading/error state. Consumers can call `loadForUid` to fetch a user.
class UserProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Load user document by UID. The function expects the user document to
  /// live under `users/{uid}`. Adjust path if your project stores users
  /// elsewhere (e.g., `delivery_boys`).
  Future<void> loadForUid(String uid) async {
    _setLoading(true);
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        _user = null;
        _error = 'User not found';
        notifyListeners();
        return;
      }
      final data = doc.data() ?? {};
      // Normalize: ensure uid present in the map for constructor.
      final map = Map<String, dynamic>.from(data);
      map['uid'] = uid;
      _user = UserModel.fromMap(map);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    final current = _user;
    if (current == null) return;
    await loadForUid(current.uid);
  }

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}

/*
Usage example:

In `main.dart` when creating providers, add:

  ChangeNotifierProvider(create: (_) => UserProvider()),

Then after login or when you have the user's uid (for this project the
AuthProvider exposes `deliveryBoyId`), call:

  final userProvider = context.read<UserProvider>();
  await userProvider.loadForUid(auth.deliveryBoyId!);

Watch `userProvider.user`, `userProvider.isLoading`, and `userProvider.error`
in the UI with `Consumer<UserProvider>` or `context.watch<UserProvider>()`.

Adjust collection path (`users`) if your app stores users in a different
collection like `delivery_boys`.
*/
