class DeliveryBoy {
  final String deliveryBoyId;
  final String? name;
  final String? phone;

  DeliveryBoy({required this.deliveryBoyId, this.name, this.phone});

  factory DeliveryBoy.fromMap(String id, Map<String, dynamic> map) {
    return DeliveryBoy(
      deliveryBoyId: (map['deliveryBoyId'] ?? map['delivery_boy_id'] ?? id)
          .toString(),
      name: (map['name'] ?? map['fullName'] ?? map['full_name'])?.toString(),
      phone: (map['phone'] ?? map['phoneNumber'] ?? map['phone_number'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'deliveryBoyId': deliveryBoyId,
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
  };
}
