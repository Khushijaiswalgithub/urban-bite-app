// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart';

// class UserProvider extends ChangeNotifier {
//   UserModel? _user;
//   bool _isLoading = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   UserModel? get user => _user;
//   bool get isLoading => _isLoading;

//   // Get current Firebase Auth user
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }

//   // Initialize user state
//   Future<void> initialize() async {
//     final currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       await _fetchUserData(currentUser.uid);
//     }
//   }

//   // Phone Authentication
//   Future<void> verifyPhone({
//     required String phoneNumber,
//     required Function(String) onCodeSent,
//     required Function(String) onError,
//     required Function(UserCredential) onVerificationComplete,
//   }) async {
//     try {
//       _setLoading(true);
//       await _auth.verifyPhoneNumber(
//         phoneNumber: '+91$phoneNumber',
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           final userCredential = await _auth.signInWithCredential(credential);
//           onVerificationComplete(userCredential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           onError(e.message ?? 'Verification failed');
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           onCodeSent(verificationId);
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {},
//       );
//     } catch (e) {
//       onError(e.toString());
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Verify OTP
//   Future<(bool success, bool userExists)> verifyOTP({
//     required String verificationId,
//     required String otp,
//   }) async {
//     try {
//       _setLoading(true);
//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otp,
//       );
//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;
//       if (user == null) return (false, false);

//       // Check if user exists in Firestore
//       final userExists = await checkUserExists(
//         user.phoneNumber?.replaceFirst('+91', '') ?? '',
//       );

//       if (userExists) {
//         await _fetchUserData(user.uid);
//       }

//       return (true, userExists);
//     } catch (e) {
//       debugPrint('Error verifying OTP: $e');
//       return (false, false);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Create or Update User Profile
//   Future<void> updateUserProfile({
//     required String name,
//     required String email,
//   }) async {
//     try {
//       _setLoading(true);
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) throw Exception('No authenticated user found');

//       UserModel updatedUser;
//       if (_user != null) {
//         updatedUser = _user!.copyWith(name: name, email: email);
//       } else {
//         updatedUser = UserModel(
//           uid: currentUser.uid,
//           phoneNumber: currentUser.phoneNumber,
//           name: name,
//           email: email,
//         );
//       }

//       await _firestore
//           .collection('users')
//           .doc(currentUser.uid)
//           .set(updatedUser.toMap());

//       _user = updatedUser;
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Add Address
//   Future<void> addAddress(AddressModel address) async {
//     try {
//       _setLoading(true);
//       if (_user == null) throw Exception('No user data found');

//       final List<AddressModel> updatedAddresses = [
//         ..._user!.addresses,
//         address,
//       ];
//       final updatedUser = _user!.copyWith(addresses: updatedAddresses);

//       await _firestore.collection('users').doc(_user!.uid).update({
//         'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
//       });

//       _user = updatedUser;
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Fetch User Data
//   Future<void> _fetchUserData(String uid) async {
//     try {
//       final doc = await _firestore.collection('users').doc(uid).get();
//       if (doc.exists) {
//         _user = UserModel.fromMap({'uid': uid, ...doc.data()!});
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error fetching user data: $e');
//     }
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       _user = null;
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error signing out: $e');
//     }
//   }

//   // Check if user exists
//   Future<bool> checkUserExists(String phoneNumber) async {
//     try {
//       final formattedPhone = '+91$phoneNumber';
//       final querySnapshot = await _firestore
//           .collection('users')
//           .where('phoneNumber', isEqualTo: formattedPhone)
//           .get();
//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       debugPrint('Error checking user existence: $e');
//       return false;
//     }
//   }

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Get current Firebase Auth user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Initialize user state
  Future<void> initialize() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    }
  }

  // Phone Authentication
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(UserCredential) onVerificationComplete,
  }) async {
    try {
      // set loading before starting verification so UI can show spinner
      _setLoading(true);

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            onVerificationComplete(userCredential);
          } finally {
            // ensure loading is cleared after automatic verification completes
            _setLoading(false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          // stop loading and notify caller
          _setLoading(false);
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          // code has been sent, clear loading and notify caller so navigation can occur
          _setLoading(false);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // timeout - ensure loading is cleared
          _setLoading(false);
        },
      );
    } catch (e) {
      // If an exception happens while initiating verification, clear loading and report
      _setLoading(false);
      onError(e.toString());
    }
  }

  // Verify OTP
  Future<(bool success, bool userExists)> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return (false, false);

      // Check if user exists in Firestore
      final userExists = await checkUserExists(
        user.phoneNumber?.replaceFirst('+91', '') ?? '',
      );

      if (userExists) {
        await _fetchUserData(user.uid);
      }

      return (true, userExists);
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return (false, false);
    } finally {
      _setLoading(false);
    }
  }

  // Create or Update User Profile
  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      _setLoading(true);
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No authenticated user found');

      UserModel updatedUser;
      if (_user != null) {
        updatedUser = _user!.copyWith(name: name, email: email);
      } else {
        updatedUser = UserModel(
          uid: currentUser.uid,
          phoneNumber: currentUser.phoneNumber,
          name: name,
          email: email,
        );
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(updatedUser.toMap());

      _user = updatedUser;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add Address (CREATE)
  Future<void> addAddress(AddressModel address) async {
    try {
      _setLoading(true);
      if (_user == null) throw Exception('No user data found');
      // If the added address is active, deactivate others and put it at top
      final List<AddressModel> updatedAddresses = List.from(_user!.addresses);
      if (address.isActive) {
        // deactivate existing active addresses
        for (var i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = AddressModel(
            area: updatedAddresses[i].area,
            city: updatedAddresses[i].city,
            house: updatedAddresses[i].house,
            latitude: updatedAddresses[i].latitude,
            longitude: updatedAddresses[i].longitude,
            pincode: updatedAddresses[i].pincode,
            state: updatedAddresses[i].state,
            isActive: false,
          );
        }
        updatedAddresses.insert(0, address);
      } else {
        updatedAddresses.add(address);
      }
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);

      await _firestore.collection('users').doc(_user!.uid).update({
        'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update Address (UPDATE)
  Future<void> updateAddress(int index, AddressModel updatedAddress) async {
    try {
      _setLoading(true);
      if (_user == null) throw Exception('No user data found');
      if (index < 0 || index >= _user!.addresses.length) {
        throw Exception('Invalid address index');
      }
      final List<AddressModel> updatedAddresses = List.from(_user!.addresses);

      // If updatedAddress isActive, deactivate others and move to top
      if (updatedAddress.isActive) {
        for (var i = 0; i < updatedAddresses.length; i++) {
          if (i == index) continue;
          updatedAddresses[i] = AddressModel(
            area: updatedAddresses[i].area,
            city: updatedAddresses[i].city,
            house: updatedAddresses[i].house,
            latitude: updatedAddresses[i].latitude,
            longitude: updatedAddresses[i].longitude,
            pincode: updatedAddresses[i].pincode,
            state: updatedAddresses[i].state,
            isActive: false,
          );
        }
        // replace and move to front
        updatedAddresses[index] = updatedAddress;
        final moved = updatedAddresses.removeAt(index);
        updatedAddresses.insert(0, moved);
      } else {
        updatedAddresses[index] = updatedAddress;
      }
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);

      await _firestore.collection('users').doc(_user!.uid).update({
        'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete Address (DELETE)
  Future<void> deleteAddress(int index) async {
    try {
      _setLoading(true);
      if (_user == null) throw Exception('No user data found');
      if (index < 0 || index >= _user!.addresses.length) {
        throw Exception('Invalid address index');
      }
      final List<AddressModel> updatedAddresses = List.from(_user!.addresses);
      final wasActive = updatedAddresses[index].isActive;
      updatedAddresses.removeAt(index);

      // If deleted address was active, ensure first address (if any) becomes active
      if (wasActive && updatedAddresses.isNotEmpty) {
        updatedAddresses[0] = AddressModel(
          area: updatedAddresses[0].area,
          city: updatedAddresses[0].city,
          house: updatedAddresses[0].house,
          latitude: updatedAddresses[0].latitude,
          longitude: updatedAddresses[0].longitude,
          pincode: updatedAddresses[0].pincode,
          state: updatedAddresses[0].state,
          isActive: true,
        );
      }
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);

      await _firestore.collection('users').doc(_user!.uid).update({
        'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get Address by Index (READ - specific)
  AddressModel? getAddress(int index) {
    if (_user == null || index < 0 || index >= _user!.addresses.length) {
      return null;
    }
    return _user!.addresses[index];
  }

  // Set a specific address active and move it to top
  Future<void> setActiveAddress(int index) async {
    try {
      _setLoading(true);
      if (_user == null) throw Exception('No user data found');
      if (index < 0 || index >= _user!.addresses.length) {
        throw Exception('Invalid address index');
      }

      final List<AddressModel> updatedAddresses = List.from(_user!.addresses);
      for (var i = 0; i < updatedAddresses.length; i++) {
        updatedAddresses[i] = AddressModel(
          area: updatedAddresses[i].area,
          city: updatedAddresses[i].city,
          house: updatedAddresses[i].house,
          latitude: updatedAddresses[i].latitude,
          longitude: updatedAddresses[i].longitude,
          pincode: updatedAddresses[i].pincode,
          state: updatedAddresses[i].state,
          isActive: i == index,
        );
      }

      final moved = updatedAddresses.removeAt(index);
      updatedAddresses.insert(0, moved);

      final updatedUser = _user!.copyWith(addresses: updatedAddresses);

      await _firestore.collection('users').doc(_user!.uid).update({
        'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting active address: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clear active flag on all addresses
  Future<void> clearActiveAddress() async {
    try {
      _setLoading(true);
      if (_user == null) return;

      final List<AddressModel> updatedAddresses = List.from(_user!.addresses);
      for (var i = 0; i < updatedAddresses.length; i++) {
        updatedAddresses[i] = AddressModel(
          area: updatedAddresses[i].area,
          city: updatedAddresses[i].city,
          house: updatedAddresses[i].house,
          latitude: updatedAddresses[i].latitude,
          longitude: updatedAddresses[i].longitude,
          pincode: updatedAddresses[i].pincode,
          state: updatedAddresses[i].state,
          isActive: false,
        );
      }

      final updatedUser = _user!.copyWith(addresses: updatedAddresses);

      await _firestore.collection('users').doc(_user!.uid).update({
        'addresses': updatedAddresses.map((a) => a.toMap()).toList(),
      });

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing active address: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get All Addresses (READ - all)
  List<AddressModel> getAllAddresses() {
    return _user?.addresses ?? [];
  }

  // Search Addresses
  List<AddressModel> searchAddresses(String query) {
    if (_user == null || query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _user!.addresses.where((address) {
      return address.house.toLowerCase().contains(lowercaseQuery) ||
          address.area.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Fetch User Data
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 5));
      if (doc.exists) {
        _user = UserModel.fromMap({'uid': uid, ...doc.data()!});
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final formattedPhone = '+91$phoneNumber';
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  // Refresh User Data
  Future<void> refreshUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

