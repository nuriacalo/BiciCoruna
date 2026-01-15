// test/services/favorites_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bicicoruna/services/favorites_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GRUPO 3: Tests del servicio FavoritesService
///
/// Relevancia: El servicio de favoritos es crucial para la experiencia del usuario.
/// Permite guardar estaciones preferidas para acceso rápido. Errores aquí pueden
/// causar pérdida de datos del usuario o comportamiento inconsistente.
void main() {
  setUp(() {
    // Limpiar SharedPreferences antes de cada test
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService - Gestión de favoritos', () {
    /// Test 1: Verifica que getFavoriteIds devuelve conjunto vacío inicialmente

    test('getFavoriteIds debe devolver conjunto vacío al inicio', () async {
      // Arrange
      final service = FavoritesService.instance;

      // Act
      final favorites = await service.getFavoriteIds();

      // Assert
      expect(favorites, isEmpty);
      expect(favorites, isA<Set<String>>());
    });

    /// Test 2: Verifica que toggleFavorite AÑADE un ID cuando no es favorito

    test('toggleFavorite debe AÑADIR un ID si no es favorito', () async {
      // Arrange
      final service = FavoritesService.instance;
      const stationId = 'station_123';

      // Act
      final result = await service.toggleFavorite(stationId);
      final favorites = await service.getFavoriteIds();

      // Assert
      expect(result, isTrue); // setStringList retorna true en éxito
      expect(favorites.contains(stationId), isTrue);
      expect(favorites.length, 1);
    });

    /// Test 3: Verifica que toggleFavorite ELIMINA un ID si ya es favorito

    test('toggleFavorite debe ELIMINAR un ID si ya es favorito', () async {
      // Arrange
      final service = FavoritesService.instance;
      const stationId = 'station_456';

      // Primero añadir el favorito
      await service.toggleFavorite(stationId);

      // Act - togglear de nuevo para eliminar
      final result = await service.toggleFavorite(stationId);
      final favorites = await service.getFavoriteIds();

      // Assert
      expect(result, isTrue);
      expect(favorites.contains(stationId), isFalse);
      expect(favorites, isEmpty);
    });

    /// Test 4: Verifica que isFavorite devuelve el estado correcto

    test(
      'isFavorite debe devolver true para favorito y false para no favorito',
      () async {
        // Arrange
        final service = FavoritesService.instance;
        const favoriteId = 'station_789';
        const nonFavoriteId = 'station_000';

        // Añadir solo favoriteId
        await service.toggleFavorite(favoriteId);

        // Act
        final isFav = await service.isFavorite(favoriteId);
        final isNotFav = await service.isFavorite(nonFavoriteId);

        // Assert
        expect(isFav, isTrue);
        expect(isNotFav, isFalse);
      },
    );

    /// Test 5: Verifica que los favoritos persisten entre llamadas

    test('los favoritos deben persistir entre múltiples operaciones', () async {
      // Arrange
      final service = FavoritesService.instance;
      const station1 = 'station_A';
      const station2 = 'station_B';
      const station3 = 'station_C';

      // Act - añadir varios favoritos
      await service.toggleFavorite(station1);
      await service.toggleFavorite(station2);
      await service.toggleFavorite(station3);

      // Quitar uno
      await service.toggleFavorite(station2);

      // Verificar estado final
      final favorites = await service.getFavoriteIds();

      // Assert
      expect(favorites.length, 2);
      expect(favorites.contains(station1), isTrue);
      expect(favorites.contains(station2), isFalse); // eliminado
      expect(favorites.contains(station3), isTrue);
    });

    /// Test 6: Verifica que múltiples toggles funcionan correctamente

    test(
      'múltiples toggles del mismo ID deben alternar correctamente',
      () async {
        // Arrange
        final service = FavoritesService.instance;
        const stationId = 'station_toggle';

        // Act & Assert - alternar 4 veces
        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isTrue); // 1: añadido

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isFalse); // 2: eliminado

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isTrue); // 3: añadido

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isFalse); // 4: eliminado
      },
    );
  });
}
