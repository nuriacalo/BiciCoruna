// lib/viewmodel/station_viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/station.dart';

class StationViewModel {
  static const String _baseUrl =
      'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl';
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _cacheDuration = Duration(minutes: 1);
  static const Duration _vehicleTypesCacheDuration = Duration(hours: 24);

  final http.Client _httpClient;

  List<Station>? _cachedStations;
  DateTime? _lastFetchTime;
  Exception? _lastError;

  Map<String, dynamic>? _cachedVehicleTypes;
  DateTime? _lastVehicleTypesFetchTime;

  StationViewModel({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Exception? get lastError => _lastError;

  Future<List<Station>> getStations({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedStations != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedStations!;
    }

    try {
      final vehicleTypesFuture = _getVehicleTypes();

      final [info, status, vehicleTypes] = await Future.wait([
        _fetchData('station_information'),
        _fetchData('station_status'),
        vehicleTypesFuture,
      ]);

      final vehicleTypeList =
          (vehicleTypes['data']?['vehicle_types'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[];

      final propulsionByVehicleTypeId = <String, String>{
        for (final vt in vehicleTypeList)
          if (vt['vehicle_type_id'] != null && vt['propulsion_type'] != null)
            vt['vehicle_type_id'].toString(): vt['propulsion_type'].toString(),
      };

      final formFactorByVehicleTypeId = <String, String>{
        for (final vt in vehicleTypeList)
          if (vt['vehicle_type_id'] != null && vt['form_factor'] != null)
            vt['vehicle_type_id'].toString(): vt['form_factor'].toString(),
      };

      final stations = _mergeStationData(
        info,
        status,
        propulsionByVehicleTypeId: propulsionByVehicleTypeId,
        formFactorByVehicleTypeId: formFactorByVehicleTypeId,
      );
      _cachedStations = stations;
      _lastFetchTime = DateTime.now();
      _lastError = null;
      return stations;
    } catch (e) {
      _lastError = e is Exception ? e : Exception('Error desconocido');
      if (_cachedStations != null) {
        return _cachedStations!;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchData(String endpoint) async {
    final response = await _httpClient
        .get(Uri.parse('$_baseUrl/$endpoint'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al cargar los datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _getVehicleTypes() async {
    if (_cachedVehicleTypes != null &&
        _lastVehicleTypesFetchTime != null &&
        DateTime.now().difference(_lastVehicleTypesFetchTime!) <
            _vehicleTypesCacheDuration) {
      return _cachedVehicleTypes!;
    }

    final data = await _fetchData('vehicle_types');
    _cachedVehicleTypes = data;
    _lastVehicleTypesFetchTime = DateTime.now();
    return data;
  }

  List<Station> _mergeStationData(
    Map<String, dynamic> info,
    Map<String, dynamic> status, {
    Map<String, String>? propulsionByVehicleTypeId,
    Map<String, String>? formFactorByVehicleTypeId,
  }) {
    final infoSt = (info['data']['stations'] as List)
        .cast<Map<String, dynamic>>();
    final statusSt = (status['data']['stations'] as List)
        .cast<Map<String, dynamic>>();

    final statusById = <String, Map<String, dynamic>>{
      for (final s in statusSt)
        if (s['station_id'] != null) s['station_id']: s,
    };

    final stations = <Station>[];
    for (final infoStation in infoSt) {
      final id = infoStation['station_id'];
      final statusStation = statusById[id];
      if (statusStation == null) continue;
      final mergedJson = {...infoStation, ...statusStation};
      stations.add(
        Station.fromJson(
          mergedJson,
          propulsionByVehicleTypeId: propulsionByVehicleTypeId,
          formFactorByVehicleTypeId: formFactorByVehicleTypeId,
        ),
      );
    }
    return stations;
  }
}
