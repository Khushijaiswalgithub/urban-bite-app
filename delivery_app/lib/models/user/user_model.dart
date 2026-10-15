import 'address_model.dart';

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
