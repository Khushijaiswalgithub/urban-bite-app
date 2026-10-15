import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _deliveryBoyId;
  String? get deliveryBoyId => _deliveryBoyId;

  String? _name;
  String? get name => _name;

  String? _phone;
  String? get phone => _phone;

  static const _kKeyLoggedIn = 'auth_logged_in';
  static const _kKeyDeliveryBoyId = 'auth_delivery_boy_id';

  AuthProvider() {
    _loadFromPrefs();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> checkDeliveryBoyExists(String phoneNumber) async {
    _setLoading(true);
    try {
      final q = await _db
          .collection('delivery_boys')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      _setLoading(false);
      return q.docs.isNotEmpty;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onVerificationComplete,
  }) async {
    _setLoading(true);
    try {
      String fullPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _setLoading(false);
          onVerificationComplete(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          onError(e.message ?? 'Verification Failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _setLoading(false);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _setLoading(false);
        },
      );
    } catch (e) {
      _setLoading(false);
      onError('Error sending OTP: $e');
    }
  }

  Future<bool> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String originalPhone,
    required void Function(String error) onError,
  }) async {
    _setLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final q = await _db
            .collection('delivery_boys')
            .where('phone', isEqualTo: originalPhone)
            .limit(1)
            .get();

        if (q.docs.isNotEmpty) {
          final doc = q.docs.first;
          final data = doc.data();

          _deliveryBoyId = doc.id;
          _loggedIn = true;
          _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
          _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
          notifyListeners();

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_kKeyLoggedIn, true);
            await prefs.setString(_kKeyDeliveryBoyId, _deliveryBoyId!);
          } catch (_) {}
          
          _setLoading(false);
          return true;
        } else {
           _setLoading(false);
           onError('Account not found in database.');
           return false;
        }
      }
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      onError(e.message ?? 'Invalid OTP');
      return false;
    } catch (e) {
      _setLoading(false);
      onError('Failed to verify OTP');
      return false;
    }
  }

  Future<bool> signInWithCredential(PhoneAuthCredential credential, String originalPhone, Function(String) onError) async {
    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final q = await _db.collection('delivery_boys').where('phone', isEqualTo: originalPhone).limit(1).get();
        if (q.docs.isNotEmpty) {
          final doc = q.docs.first;
          final data = doc.data();
          _deliveryBoyId = doc.id;
          _loggedIn = true;
          _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
          _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
          notifyListeners();

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_kKeyLoggedIn, true);
            await prefs.setString(_kKeyDeliveryBoyId, _deliveryBoyId!);
          } catch (_) {}
          _setLoading(false);
          return true;
        }
      }
      _setLoading(false);
      return false;
    } catch(e) {
      _setLoading(false);
      onError(e.toString());
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (_deliveryBoyId == null) return;
    try {
      final doc = await _db.collection('delivery_boys').doc(_deliveryBoyId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
          _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
          notifyListeners();
          return;
        }
      }
    } catch (_) {}
    
    try {
      final q = await _db
          .collection('delivery_boys')
          .where('deliveryBoyId', isEqualTo: _deliveryBoyId)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final doc = q.docs.first;
        final data = doc.data();
        
        _deliveryBoyId = doc.id;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kKeyDeliveryBoyId, _deliveryBoyId!);
        } catch (_) {}

        _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
        _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Map<String, String?>?> fetchNameAndPhone() async {
    if (_deliveryBoyId == null) return null;
    try {
      final doc = await _db.collection('delivery_boys').doc(_deliveryBoyId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
          _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
          notifyListeners();
          return {'name': _name, 'phone': _phone};
        }
      }
    } catch (_) {}

    try {
      final q = await _db
          .collection('delivery_boys')
          .where('deliveryBoyId', isEqualTo: _deliveryBoyId)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final data = q.docs.first.data();
        _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
        _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
        notifyListeners();
        return {'name': _name, 'phone': _phone};
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, String?>?> fetchProfileByPhone(String phoneNumber) async {
    try {
      final q = await _db
          .collection('delivery_boys')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      final doc = q.docs.first;
      final data = doc.data();

      final foundDeliveryBoyId = doc.id;

      _deliveryBoyId = foundDeliveryBoyId;
      _name = (data['name'] ?? data['fullName'] ?? data['full_name'])?.toString();
      _phone = (data['phone'] ?? data['phoneNumber'] ?? data['phone_number'])?.toString();
      notifyListeners();

      return {'deliveryBoyId': _deliveryBoyId, 'name': _name, 'phone': _phone};
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    _deliveryBoyId = null;
    _loggedIn = false;
    notifyListeners();
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kKeyLoggedIn);
      await prefs.remove(_kKeyDeliveryBoyId);
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLoggedIn = prefs.getBool(_kKeyLoggedIn) ?? false;
      final savedId = prefs.getString(_kKeyDeliveryBoyId);
      final currentUser = _auth.currentUser;
      
      if (savedLoggedIn && savedId != null && currentUser != null) {
        _loggedIn = true;
        _deliveryBoyId = savedId;
        notifyListeners();
        loadProfile();
      } else {
        signOut(); // ensure reset if Firebase isn't authenticated
      }
    } catch (_) {}
  }
}
