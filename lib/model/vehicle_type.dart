class VehicleType {
  final String vehicleTypeId;
  final int count;

  VehicleType({required this.vehicleTypeId, required this.count});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    final typeId = json.keys.first;
    final count = json.values.first as int;
    
    return VehicleType(
      vehicleTypeId: typeId,
      count: count,
    );
  }

  String get name {
    switch (vehicleTypeId) {
      case '1':
        return 'Mecánica';
      case '2':
        return 'Eléctrica';
      default:
        return 'Mixta';
    }
  }
}
