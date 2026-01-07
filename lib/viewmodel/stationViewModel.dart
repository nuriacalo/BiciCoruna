import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/station.dart';

class Stationviewmodel {
  static const String _base =
      'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl';
  static const Duration _timeout = Duration(seconds: 8);

  Future<Map<String, dynamic>> getInfoJson() async {
    final res = await http
        .get(Uri.parse('$_base/station_information'))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load station info');
    }
  }

  Future<Map<String, dynamic>> getStatusJson() async {
    final res = await http
        .get(Uri.parse('$_base/station_status'))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load station status');
    }
  }

  Future<List<Station>> getStations() async {
    final [info, status] = await Future.wait([getInfoJson(), getStatusJson()]);
    final infoSt = (info['data']['stations'] as List)
        .cast<Map<String, dynamic>>();
    final statusSt = (status['data']['stations'] as List)
        .cast<Map<String, dynamic>>();

    // Index status by station_id to avoid O(n^2) scans.
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
      stations.add(Station.fromJson(mergedJson));
    }
    if (stations.isEmpty) {
      throw Exception('No stations found after merging data');
    }
    return stations;
  }
}
