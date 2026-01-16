// test/models/bike_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bicicoruna/model/bike.dart';

/// GRUPO 1: Tests do modelo Bike
///
/// Relevancia: O modelo Bike é fundamental para clasificar correctamente
/// as bicicletas como eléctricas ou mecánicas. Unha clasificación incorrecta
/// podería mostrar información errónea ao usuario sobre a dispoñibilidade
/// de tipos de bicicletas nas estacións.
void main() {
  group('Bike.fromType - Constructor', () {
    /// Test 1: Verifica que propulsionType != 'human' clasifica como eléctrica
    test('debe clasificar como eléctrica cuando propulsionType != "human"', () {
      final bike1 = Bike.fromType('BIKE', 5, propulsionType: 'electric');
      final bike2 = Bike.fromType('BIKE', 3, propulsionType: 'electric_assist');

      expect(bike1.type, 'Eléctrica');
      expect(bike1.count, 5);
      expect(bike2.type, 'Eléctrica');
      expect(bike2.count, 3);
    });

    /// Test 2: Verifica que propulsionType == 'human' clasifica como mecánica

    test('debe clasificar como mecánica cuando propulsionType es "human"', () {
      final bike = Bike.fromType('EBIKE', 10, propulsionType: 'human');

      expect(bike.type, 'Mecánica');
      expect(bike.count, 10);
    });

    /// Test 3: Verifica que typeId clasifica correctamente cando propulsionType é null

    test(
      'debe clasificar como eléctrica basándose en typeId cuando propulsionType es null',
      () {
        final bikeEBIKE = Bike.fromType('EBIKE', 5);
        final bike2 = Bike.fromType('2', 3);
        final bikeE123 = Bike.fromType('E-123', 7);
        final bikeBOOST = Bike.fromType('BOOST', 2);
        final bikeCOSMO = Bike.fromType('COSMO', 4);
        final bikeASTRO = Bike.fromType('ASTRO', 6);

        expect(bikeEBIKE.type, 'Eléctrica');
        expect(bike2.type, 'Eléctrica');
        expect(bikeE123.type, 'Eléctrica');
        expect(bikeBOOST.type, 'Eléctrica');
        expect(bikeCOSMO.type, 'Eléctrica');
        expect(bikeASTRO.type, 'Eléctrica');
      },
    );

    /// Test 4: Verifica que typeId descoñecidos clasifican como mecánica

    test('debe clasificar como mecánica para typeId desconocidos', () {
      final bike1 = Bike.fromType('BIKE', 8);
      final bike2 = Bike.fromType('1', 12);
      final bike3 = Bike.fromType('MECHANICAL', 5);
      final bike4 = Bike.fromType('UNKNOWN_TYPE', 3);

      expect(bike1.type, 'Mecánica');
      expect(bike2.type, 'Mecánica');
      expect(bike3.type, 'Mecánica');
      expect(bike4.type, 'Mecánica');
    });

    /// Test 5: Verifica que propulsionType ten prioridade sobre typeId

    test('debe dar prioridad a propulsionType sobre typeId', () {
      // propulsionType indica 'human' pero typeId é de eléctrica
      final bike1 = Bike.fromType('EBIKE', 5, propulsionType: 'human');
      // propulsionType indica 'electric' pero typeId é de mecánica
      final bike2 = Bike.fromType('BIKE', 3, propulsionType: 'electric');

      expect(bike1.type, 'Mecánica'); // propulsionType gana
      expect(bike2.type, 'Eléctrica'); // propulsionType gana
    });
  });
}
