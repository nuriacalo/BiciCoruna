// lib/services/favorites_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_stations';
  static FavoritesService? _instance;

  FavoritesService._();

  static FavoritesService get instance {
    _instance ??= FavoritesService._();
    return _instance!;
  }

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  Future<bool> toggleFavorite(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_favoritesKey) ?? []).toSet();

    if (favorites.contains(stationId)) {
      favorites.remove(stationId);
    } else {
      favorites.add(stationId);
    }

    return await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<bool> isFavorite(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_favoritesKey) ?? []).toSet();
    return favorites.contains(stationId);
  }
}
