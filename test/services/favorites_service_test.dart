// test/services/favorites_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bicicoruna/services/favorites_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GRUPO 3: Tests do servicio FavoritesService
///
/// Relevancia: O servicio de favoritos é crucial para a experiencia do usuario.
/// Permite gardar estacións preferidas para acceso rápido. Erros aquí poden
/// causar perda de datos do usuario ou comportamento inconsistente.
void main() {
  setUp(() {
    // Limpar SharedPreferences antes de cada test
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService - Gestión de favoritos', () {
    /// Test 1: Verifica que getFavoriteIds devolve conxunto baleiro inicialmente

    test('getFavoriteIds debe devolver conjunto vacío al inicio', () async {
      final service = FavoritesService.instance;

      final favorites = await service.getFavoriteIds();

      expect(favorites, isEmpty);
      expect(favorites, isA<Set<String>>());
    });

    /// Test 2: Verifica que toggleFavorite AÑADE un ID cando non é favorito

    test('toggleFavorite debe AÑADIR un ID si no es favorito', () async {
      final service = FavoritesService.instance;
      const stationId = 'station_123';

      final result = await service.toggleFavorite(stationId);
      final favorites = await service.getFavoriteIds();

      expect(result, isTrue); // setStringList retorna true en éxito
      expect(favorites.contains(stationId), isTrue);
      expect(favorites.length, 1);
    });

    /// Test 3: Verifica que toggleFavorite ELIMINA un ID se xa é favorito

    test('toggleFavorite debe ELIMINAR un ID si ya es favorito', () async {
      final service = FavoritesService.instance;
      const stationId = 'station_456';

      // Primeiro engadir o favorito
      await service.toggleFavorite(stationId);

      final result = await service.toggleFavorite(stationId);
      final favorites = await service.getFavoriteIds();

      expect(result, isTrue);
      expect(favorites.contains(stationId), isFalse);
      expect(favorites, isEmpty);
    });

    /// Test 4: Verifica que isFavorite devolva o estado correcto

    test(
      'isFavorite debe devolver true para favorito y false para no favorito',
      () async {
        final service = FavoritesService.instance;
        const favoriteId = 'station_789';
        const nonFavoriteId = 'station_000';

        // Añadir solo favoriteId
        await service.toggleFavorite(favoriteId);

        final isFav = await service.isFavorite(favoriteId);
        final isNotFav = await service.isFavorite(nonFavoriteId);

        expect(isFav, isTrue);
        expect(isNotFav, isFalse);
      },
    );

    /// Test 5: Verifica que os favoritos persisten entre chamadas

    test('los favoritos deben persistir entre múltiples operaciones', () async {
      final service = FavoritesService.instance;
      const station1 = 'station_A';
      const station2 = 'station_B';
      const station3 = 'station_C';

      // Engadir varios favoritos
      await service.toggleFavorite(station1);
      await service.toggleFavorite(station2);
      await service.toggleFavorite(station3);

      // Quitar un
      await service.toggleFavorite(station2);

      // Verificar estado final
      final favorites = await service.getFavoriteIds();

      expect(favorites.length, 2);
      expect(favorites.contains(station1), isTrue);
      expect(favorites.contains(station2), isFalse); // eliminado
      expect(favorites.contains(station3), isTrue);
    });

    /// Test 6: Verifica que múltiples toggles funcionan correctamente

    test(
      'múltiples toggles del mismo ID deben alternar correctamente',
      () async {
        final service = FavoritesService.instance;
        const stationId = 'station_toggle';

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isTrue); // 1: engadido

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isFalse); // 2: eliminado

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isTrue); // 3: engadido

        await service.toggleFavorite(stationId);
        expect(await service.isFavorite(stationId), isFalse); // 4: eliminado
      },
    );
  });
}
