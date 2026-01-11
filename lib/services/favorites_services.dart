// lib/services/favorites_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_stations';
  static FavoritesService? _instance;
  SharedPreferences? _prefs;

  FavoritesService._();

  static FavoritesService get instance {
    _instance ??= FavoritesService._();
    return _instance!;
  }

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Set<String>> getFavoriteIds() async {
    await _init();
    final favorites = _prefs!.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  Future<bool> toggleFavorite(String stationId) async {
    await _init();
    final favorites = await getFavoriteIds();

    if (favorites.contains(stationId)) {
      favorites.remove(stationId);
    } else {
      favorites.add(stationId);
    }

    return await _prefs!.setStringList(_favoritesKey, favorites.toList());
  }

  Future<bool> isFavorite(String stationId) async {
    await _init();
    final favorites = await getFavoriteIds();
    return favorites.contains(stationId);
  }
}
