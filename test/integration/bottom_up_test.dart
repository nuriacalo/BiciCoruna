import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:bicicoruna/viewmodel/station_viewmodel.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
import 'bottom_up_test.mocks.dart';

void main() {
  group('Integración AScendente: ViewModel + Modelos', () {
    late MockClient mockClient;
    late StationViewModel stationViewModel;

    setUp(() {
      mockClient = MockClient();
      stationViewModel = StationViewModel(httpClient: mockClient);
    });

    test(
      'getStations debe procesar JSON crudo y devolver lista de objetos Station válidos',
      () async {
        final infoJson = {
          'data': {
            'stations': [
              {
                'station_id': '1',
                'name': 'Obelisco',
                'lat': 43.36,
                'lon': -8.40,
                'capacity': 20,
                'vehicle_types_available': [
                  {'vehicle_type_id': 'EBIKE', 'count': 5},
                ],
              },
            ],
          },
        };
        final statusJson = {
          'data': {
            'stations': [
              {
                'station_id': '1',
                'num_bikes_available': 5,
                'num_docks_available': 15,
                'is_renting': true,
              },
            ],
          },
        };
        final typesJson = {
          'data': {
            'vehicle_types': [
              {'vehicle_type_id': 'EBIKE', 'propulsion_type': 'electric'},
            ],
          },
        };

        // Simulamos respostas HTTP
        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_information',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(infoJson), 200));

        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_status',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(statusJson), 200));

        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/vehicle_types',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(typesJson), 200));

        final stations = await stationViewModel.getStations();

        expect(stations.length, 1);
        final station = stations.first;
        expect(station.name, 'Obelisco');
        expect(station.isRenting, true);
        expect(station.capacity, 20);
        expect(station.totalElectricBikes, 5);
        expect(station.bikes.first.type, 'Eléctrica');
      },
    );
  });
}
