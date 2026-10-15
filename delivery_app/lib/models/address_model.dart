// Address model

class Address {
  final String house;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final bool isActive;

  Address({
    required this.house,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      house: map['house'] ?? '',
      area: map['area'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'house': house,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return '$house, $area, $city, $state - $pincode';
  }
}
