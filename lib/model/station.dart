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
    return Station(
      id: json['station_id'],
      name: json['name'],
      physical_configuration: json['physical_configuration'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      address: json['address'],
      post_code: (json['post_code'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      is_charging_station: json['is_charging_station'],
      nearby_distance: json['nearby_distance'],
      num_bikes_available: (json['num_bikes_available'] as num).toInt(),
      num_bikes_disabled: (json['num_bikes_disabled'] as num).toInt(),
      status: json['status'],
      is_renting: json['is_renting'],
      is_returning: json['is_returning'],
      bikes: (json['bikes'] as List)
          .map((bikeJson) => Bike.fromJson(bikeJson))
          .toList(),
    );
  }
}
