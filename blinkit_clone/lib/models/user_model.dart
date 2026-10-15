class AddressModel {
  final String area;
  final String city;
  final String house;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final String pincode;
  final String state;

  AddressModel({
    required this.area,
    required this.city,
    required this.house,
    this.latitude,
    this.longitude,
    this.isActive = false,
    required this.pincode,
    required this.state,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      area: map['area'] as String,
      city: map['city'] as String,
      house: map['house'] as String,
      isActive: map['isActive'] as bool? ?? false,
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      pincode: map['pincode'] as String,
      state: map['state'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'city': city,
      'house': house,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'pincode': pincode,
      'state': state,
    };
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

class UserModel {
  final String uid;
  final String? phoneNumber;
  final String? name;
  final String? email;
  final List<AddressModel> addresses;

  UserModel({
    required this.uid,
    this.phoneNumber,
    this.name,
    this.email,
    this.addresses = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      addresses: (map['addresses'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'addresses': addresses.map((e) => e.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
    );
  }
}

// class UserModel {
//   final String uid;
//   final String? phoneNumber;
//   final String? name;
//   final String? email;
//   final List<String> addresses;

//   UserModel({
//     required this.uid,
//     this.phoneNumber,
//     this.name,
//     this.email,
//     this.addresses = const [],
//   });

//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       uid: map['uid'] as String,
//       phoneNumber: map['phoneNumber'] as String?,
//       name: map['name'] as String?,
//       email: map['email'] as String?,
//       addresses: List<String>.from(map['addresses'] ?? []),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'phoneNumber': phoneNumber,
//       'name': name,
//       'email': email,
//       'addresses': addresses,
//     };
//   }

//   UserModel copyWith({String? name, String? email, List<String>? addresses}) {
//     return UserModel(
//       uid: uid,
//       phoneNumber: phoneNumber,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       addresses: addresses ?? this.addresses,
//     );
//   }
// }

