// test/models/bike_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bicicoruna/model/bike.dart';

/// GRUPO 1: Tests del modelo Bike
///
/// Relevancia: El modelo Bike es fundamental para clasificar correctamente
/// las bicicletas como eléctricas o mecánicas. Una clasificación incorrecta
/// podría mostrar información errónea al usuario sobre la disponibilidad
/// de tipos de bicicletas en las estaciones.
void main() {
  group('Bike.fromType - Constructor', () {
    /// Test 1: Verifica que propulsionType != 'human' clasifica como eléctrica
    test('debe clasificar como eléctrica cuando propulsionType != "human"', () {
      // Arrange
      final bike1 = Bike.fromType('BIKE', 5, propulsionType: 'electric');
      final bike2 = Bike.fromType('BIKE', 3, propulsionType: 'electric_assist');

      // Act & Assert
      expect(bike1.type, 'Eléctrica');
      expect(bike1.count, 5);
      expect(bike2.type, 'Eléctrica');
      expect(bike2.count, 3);
    });

    /// Test 2: Verifica que propulsionType == 'human' clasifica como mecánica

    test('debe clasificar como mecánica cuando propulsionType es "human"', () {
      // Arrange
      final bike = Bike.fromType('EBIKE', 10, propulsionType: 'human');

      // Act & Assert
      expect(bike.type, 'Mecánica');
      expect(bike.count, 10);
    });

    /// Test 3: Verifica que typeId clasifica correctamente cuando propulsionType es null

    test(
      'debe clasificar como eléctrica basándose en typeId cuando propulsionType es null',
      () {
        // Arrange & Act
        final bikeEBIKE = Bike.fromType('EBIKE', 5);
        final bike2 = Bike.fromType('2', 3);
        final bikeE123 = Bike.fromType('E-123', 7);
        final bikeBOOST = Bike.fromType('BOOST', 2);
        final bikeCOSMO = Bike.fromType('COSMO', 4);
        final bikeASTRO = Bike.fromType('ASTRO', 6);

        // Assert
        expect(bikeEBIKE.type, 'Eléctrica');
        expect(bike2.type, 'Eléctrica');
        expect(bikeE123.type, 'Eléctrica');
        expect(bikeBOOST.type, 'Eléctrica');
        expect(bikeCOSMO.type, 'Eléctrica');
        expect(bikeASTRO.type, 'Eléctrica');
      },
    );

    /// Test 4: Verifica que typeId desconocidos clasifican como mecánica

    test('debe clasificar como mecánica para typeId desconocidos', () {
      // Arrange & Act
      final bike1 = Bike.fromType('BIKE', 8);
      final bike2 = Bike.fromType('1', 12);
      final bike3 = Bike.fromType('MECHANICAL', 5);
      final bike4 = Bike.fromType('UNKNOWN_TYPE', 3);

      // Assert
      expect(bike1.type, 'Mecánica');
      expect(bike2.type, 'Mecánica');
      expect(bike3.type, 'Mecánica');
      expect(bike4.type, 'Mecánica');
    });

    /// Test 5: Verifica que propulsionType tiene prioridad sobre typeId

    test('debe dar prioridad a propulsionType sobre typeId', () {
      // Arrange & Act
      // Caso: propulsionType dice humano pero typeId dice EBIKE
      final bike1 = Bike.fromType('EBIKE', 5, propulsionType: 'human');
      // Caso: propulsionType dice eléctrico pero typeId dice BIKE
      final bike2 = Bike.fromType('BIKE', 3, propulsionType: 'electric');

      // Assert
      expect(bike1.type, 'Mecánica'); // propulsionType gana
      expect(bike2.type, 'Eléctrica'); // propulsionType gana
    });
  });
}
