class DeliveryBoyModel {
  final String? id;
  final String name;
  final String? phone;

  DeliveryBoyModel({this.id, required this.name, this.phone});

  DeliveryBoyModel copyWith({String? id, String? name, String? phone}) {
    return DeliveryBoyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
    };
  }

  factory DeliveryBoyModel.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryBoyModel(
      id: id,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString(),
    );
  }

  @override
  String toString() => 'DeliveryBoyModel{id: $id, name: $name, phone: $phone}';
}
