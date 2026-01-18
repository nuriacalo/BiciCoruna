// test/models/station_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bicicoruna/model/station.dart';
import 'package:bicicoruna/model/bike.dart';

/// GRUPO 2: Tests do modelo Station
///
/// Relevancia: Station é o modelo central da app. Os getters
/// totalElectricBikes e totalMechanicalBikes son críticos para mostrar
/// a dispoñibilidade real de bicis ao usuario. Erros aquí impactan
/// directamente na experiencia do usuario.
void main() {
  group('Station - Getters de conteo de bicicletas', () {
    /// Test 1: Verifica o conteo correcto cando hai lista de bikes
    test(
      'totalElectricBikes y totalMechanicalBikes deben contar correctamente',
      () {
        final bikes = [
          Bike(id: 'E1', type: 'Eléctrica', count: 3),
          Bike(id: 'M1', type: 'Mecánica', count: 5),
          Bike(id: 'E2', type: 'Eléctrica', count: 2),
          Bike(id: 'M2', type: 'Mecánica', count: 4),
        ];

        final station = Station(
          id: '1',
          name: 'Test Station',
          lat: 43.3713,
          lon: -8.3960,
          altitude: 0,
          address: 'Test Address',
          postCode: 15001,
          capacity: 20,
          isChargingStation: false,
          nearbyDistance: '100',
          numBikesAvailable: 14,
          numDocksAvailable: 6,
          numBikesDisabled: 0,
          numDocksDisabled: 0,
          lastReported: 1234567890,
          vehicleTypesAvailable: {},
          status: 'IN_SERVICE',
          isRenting: true,
          isReturning: true,
          bikes: bikes,
        );

        expect(station.totalElectricBikes, 5); // 3 + 2
        expect(station.totalMechanicalBikes, 9); // 5 + 4
      },
    );

    /// Test 2: Verifica que devolve 0 cando a lista de bikes está baleira

    test('debe devolver 0 cuando la lista de bikes está vacía', () {
      final station = Station(
        id: '2',
        name: 'Empty Station',
        lat: 43.3713,
        lon: -8.3960,
        altitude: 0,
        address: 'Test Address',
        postCode: 15001,
        capacity: 20,
        isChargingStation: false,
        nearbyDistance: '100',
        numBikesAvailable: 0,
        numDocksAvailable: 20,
        numBikesDisabled: 0,
        numDocksDisabled: 0,
        lastReported: 1234567890,
        vehicleTypesAvailable: {'EBIKE': 0, 'BIKE': 0},
        status: 'IN_SERVICE',
        isRenting: true,
        isReturning: true,
        bikes: [], // Lista vacía
      );

      expect(station.totalElectricBikes, 0);
      expect(station.totalMechanicalBikes, 0);
    });

    /// Test 3: Verifica fallback a vehicleTypesAvailable cando bikes está baleira

    test(
      'debe usar vehicleTypesAvailable como fallback cuando bikes está vacío',
      () {
        final station = Station(
          id: '3',
          name: 'Fallback Station',
          lat: 43.3713,
          lon: -8.3960,
          altitude: 0,
          address: 'Test Address',
          postCode: 15001,
          capacity: 20,
          isChargingStation: false,
          nearbyDistance: '100',
          numBikesAvailable: 10,
          numDocksAvailable: 10,
          numBikesDisabled: 0,
          numDocksDisabled: 0,
          lastReported: 1234567890,
          vehicleTypesAvailable: {'EBIKE': 6, 'BIKE': 4},
          status: 'IN_SERVICE',
          isRenting: true,
          isReturning: true,
          bikes: [], // Vacío, debe usar vehicleTypesAvailable
        );

        // Act & Assert
        expect(station.totalElectricBikes, 6);
        expect(station.totalMechanicalBikes, 4);
      },
    );
  });

  group('Station.fromJson - Constructor', () {
    /// Test 4: Verifica o parsing correcto con datos válidos completos

    test('debe crear Station correctamente con datos JSON válidos', () {
      final json = {
        'station_id': '123',
        'name': 'Plaza de María Pita',
        'lat': 43.3713,
        'lon': -8.3960,
        'altitude': 5.5,
        'address': 'Praza de María Pita',
        'post_code': '15001',
        'capacity': 25,
        'is_charging_station': true,
        'nearby_distance': '150',
        'num_bikes_available': 10,
        'num_docks_available': 15,
        'num_bikes_disabled': 2,
        'num_docks_disabled': 1,
        'last_reported': 1640000000,
        'vehicle_types_available': [
          {'vehicle_type_id': 'EBIKE', 'count': 6},
          {'vehicle_type_id': 'BIKE', 'count': 4},
        ],
        'status': 'IN_SERVICE',
        'is_renting': true,
        'is_returning': true,
      };

      final station = Station.fromJson(json);

      expect(station.id, '123');
      expect(station.name, 'Plaza de María Pita');
      expect(station.lat, 43.3713);
      expect(station.lon, -8.3960);
      expect(station.altitude, 5.5);
      expect(station.address, 'Praza de María Pita');
      expect(station.postCode, 15001);
      expect(station.capacity, 25);
      expect(station.isChargingStation, true);
      expect(station.numBikesAvailable, 10);
      expect(station.status, 'IN_SERVICE');
      expect(station.bikes.length, 2);
    });

    /// Test 5: Verifica o manexo robusto de campos null ou baleiros

    test('debe manejar campos null o vacíos sin crashear', () {
      final json = {
        'station_id': '456',
        // name: null (será "Unknown Station")
        'lat': null, // será 0.0
        'lon': null, // será 0.0
        // address: null (será "")
        'post_code': null, // será 0
        'capacity': null, // será 0
        // vehicle_types_available: null (será {})
      };

      final station = Station.fromJson(json);

      // Assert - debe usar valores por defecto sen crashear
      expect(station.id, '456');
      expect(station.name, 'Unknown Station');
      expect(station.lat, 0.0);
      expect(station.lon, 0.0);
      expect(station.address, '');
      expect(station.postCode, 0);
      expect(station.capacity, 0);
      expect(station.bikes, isEmpty);
    });

    /// Test 6: Verifica o parsing de tipos incorrectos (ex: string a int)

    test('debe parsear correctamente tipos inesperados (string a int)', () {
      // Arrange
      final json = {
        'station_id': '789',
        'name': 'Test',
        'lat': 43.0,
        'lon': -8.0,
        'altitude': 0.0,
        'address': 'Test',
        'post_code': '15002', // String en lugar de int
        'capacity': '30', // String en lugar de int
        'num_bikes_available': '15', // String en lugar de int
        'is_charging_station': false,
        'nearby_distance': '200',
        'num_docks_available': '15',
        'num_bikes_disabled': '0',
        'num_docks_disabled': '0',
        'last_reported': '1640000000',
        'vehicle_types_available': [],
        'status': 'IN_SERVICE',
        'is_renting': true,
        'is_returning': true,
      };

      final station = Station.fromJson(json);

      // Assert - debe converter strings a ints correctamente
      expect(station.postCode, 15002);
      expect(station.capacity, 30);
      expect(station.numBikesAvailable, 15);
      expect(station.lastReported, 1640000000);
    });
  });
}
