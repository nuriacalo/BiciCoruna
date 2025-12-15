import 'bike.dart';

class Station {
  final String id;
  final String name;
  String physical_configuration;
  final double lat;
  final double lon;
  final double altitude;
  final String address;
  final int post_code;
  final int capacity;
  final bool is_charging_station;
  final String nearby_distance;
  final int num_bikes_available;
  final int num_bikes_disabled;
  final String status;
  final bool is_renting;
  final bool is_returning;
  final List<Bike> bikes;

  Station({
    required this.id,
    required this.name,
    this.physical_configuration = '',
    required this.lat,
    required this.lon,
    required this.altitude,
    required this.address,
    required this.post_code,
    required this.capacity,
    required this.is_charging_station,
    required this.nearby_distance,
    required this.num_bikes_available,
    required this.num_bikes_disabled,
    required this.status,
    required this.is_renting,
    required this.is_returning,
    required this.bikes,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    int postCode;
    if (json['post_code'] is String) {
      postCode = int.tryParse(json['post_code']) ?? 0;
    } else if (json['post_code'] is int) {
      postCode = json['post_code'];
    } else {
      postCode = 0;
    }

    return Station(
      id: json['station_id'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      post_code: postCode,
      capacity: json['capacity'] ?? 0,
      is_charging_station: json['is_charging_station'] ?? false,
      nearby_distance: json['nearby_distance']?.toString() ?? '',
      num_bikes_available: json['num_bikes_available'] ?? 0,
      num_bikes_disabled: json['num_bikes_disabled'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      is_renting: json['is_renting'] ?? false,
      is_returning: json['is_returning'] ?? false,
      bikes: (json['bikes'] as List<dynamic>?)
              ?.map((bikeJson) => Bike.fromJson(bikeJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
