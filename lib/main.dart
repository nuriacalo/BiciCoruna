import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/app_preferences.dart';
import 'view/station_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await AppPreferences.init();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al iniciar la aplicación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0A7D7A);
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return MaterialApp(
      title: 'BiciCoruña',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          iconSize: 26,
        ),
      ),
      home: const StationListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
