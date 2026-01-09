import 'bike.dart';

class Station {
  final String id;
  final String name;
  String physicalConfiguration;
  final double lat;
  final double lon;
  final double altitude;
  final String address;
  final int postCode;
  final int capacity;
  final bool isChargingStation;
  final String nearbyDistance;
  final int numBikesAvailable;
  final int numDocksAvailable;
  final int numBikesDisabled;
  final int numDocksDisabled;
  final int lastReported;
  final Map<String, int> vehicleTypesAvailable;
  final String status;
  final bool isRenting;
  final bool isReturning;
  final List<Bike> bikes;

  Station({
    required this.id,
    required this.name,
    this.physicalConfiguration = '',
    required this.lat,
    required this.lon,
    required this.altitude,
    required this.address,
    required this.postCode,
    required this.capacity,
    required this.isChargingStation,
    required this.nearbyDistance,
    required this.numBikesAvailable,
    required this.numDocksAvailable,
    required this.numBikesDisabled,
    required this.numDocksDisabled,
    required this.lastReported,
    required this.vehicleTypesAvailable,
    required this.status,
    required this.isRenting,
    required this.isReturning,
    required this.bikes,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final int postCode = parseInt(json['post_code']);

    final Map<String, int> vehicleTypesAvailable = {};
    final vehicleTypesJson = json['vehicle_types_available'];
    if (vehicleTypesJson is List) {
      for (final type in vehicleTypesJson) {
        if (type is Map<String, dynamic>) {
          final id = type['vehicle_type_id'] as String?;
          final count = parseInt(type['count']);
          if (id != null) {
            vehicleTypesAvailable[id] = count;
          }
        }
      }
    }


    return Station(
      id: json['station_id'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      postCode: postCode,
      capacity: parseInt(json['capacity']),
      isChargingStation: json['is_charging_station'] ?? false,
      nearbyDistance: json['nearby_distance']?.toString() ?? '',
      numBikesAvailable: parseInt(json['num_bikes_available']),
      numDocksAvailable: parseInt(json['num_docks_available']),
      numBikesDisabled: parseInt(json['num_bikes_disabled']),
      numDocksDisabled: parseInt(json['num_docks_disabled']),
      lastReported: parseInt(json['last_reported']),
      vehicleTypesAvailable: vehicleTypesAvailable,
      status: json['status'] ?? 'UNKNOWN',
      isRenting: json['is_renting'] ?? false,
      isReturning: json['is_returning'] ?? false,
      bikes:
      (json['bikes'] as List<dynamic>?)
          ?.map(
            (bikeJson) => Bike.fromJson(bikeJson as Map<String, dynamic>),
      )
          .toList() ??
          [],
    );
  }
}
