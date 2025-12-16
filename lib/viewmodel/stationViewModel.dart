import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/station.dart';

class Stationviewmodel {
  static const String _base =
      'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl';

  Future<Map<String, dynamic>> getInfoJson() async {
    final res = await http.get(Uri.parse('$_base/station_information'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load station info');
    }
  }

  Future<Map<String, dynamic>> getStatusJson() async {
    final res = await http.get(Uri.parse('$_base/station_status'));
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

    final stations = <Station>[];

    for (final infoStation in infoSt) {
      Map<String, dynamic>? statusStation;
      for (final s in statusSt) {
        if (s['station_id'] == infoStation['station_id']) {
          statusStation = s;
          break;
        }
      }
      if (statusStation != null) {
        final mergedJson = {...infoStation, ...statusStation};
        stations.add(Station.fromJson(mergedJson));
      }
    }
    if (stations.isEmpty) {
      throw Exception('No stations found after merging data');
    }
    return stations;
  }
}
