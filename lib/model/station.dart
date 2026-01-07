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
  final int numBikesDisabled;
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
    required this.numBikesDisabled,
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

    int available = parseInt(json['num_bikes_available']);
    int disabled = parseInt(json['num_bikes_disabled']);

    // Some providers only populate num_bikes_available_types; sum it as a fallback.
    int typesSum = 0;
    final types = json['num_bikes_available_types'];
    if (types is Map<String, dynamic>) {
      for (final v in types.values) {
        typesSum += parseInt(v);
      }
    } else if (types is List) {
      for (final entry in types) {
        if (entry is Map<String, dynamic>) {
          for (final v in entry.values) {
            typesSum += parseInt(v);
          }
        }
      }
    }
    if (available == 0 && typesSum > 0) {
      available = typesSum;
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
      numBikesAvailable: available,
      numBikesDisabled: disabled,
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
