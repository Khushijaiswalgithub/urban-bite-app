class AddressModel {
  final String? id;
  final String? label;
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postcode;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.id,
    this.label,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postcode,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String?,
      label: map['label'] as String?,
      line1: (map['house'] ?? map['line1'])?.toString(),
      line2: (map['area'] ?? map['line2'])?.toString(),
      city: map['city']?.toString(),
      state: map['state']?.toString(),
      postcode: (map['pincode'] ?? map['postcode'])?.toString(),
      latitude: (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (line1 != null) 'line1': line1,
      if (line2 != null) 'line2': line2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postcode != null) 'postcode': postcode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  AddressModel copyWith({
    String? label,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? postcode,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id,
      label: label ?? this.label,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      postcode: postcode ?? this.postcode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
