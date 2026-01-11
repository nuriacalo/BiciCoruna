// lib/services/app_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _seenTutorialKey = 'has_seen_tutorial';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool get hasSeenTutorial {
    return _prefs?.getBool(_seenTutorialKey) ?? false;
  }

  static Future<void> setTutorialSeen() async {
    await _prefs?.setBool(_seenTutorialKey, true);
  }
}
