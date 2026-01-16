import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bicicoruna/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Prueba de Sistema End-to-End: Flujo de Favoritos', () {
    testWidgets('Cargar lista, entrar en detalle, marcar favorito y volver', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      // Interceptamos a chamada ao sistema nativo e devolvemos un punto "."
      const MethodChannel channel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        MethodCall methodCall,
      ) async {
        return ".";
      });
      // Arrancamos a aplicación
      app.main();
      await tester.pumpAndSettle();

      // Damos tiempo á rede para descargar os datos
      bool cardsFound = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));

        if (find.byType(Card).evaluate().isNotEmpty) {
          cardsFound = true;
          break;
        }
      }

      // Verificamos que a pantalla principal cargou e mostra a lista de estacións
      expect(find.text('BiciCoruña'), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // Entramos na pantalla de detalle da primeira estación
      final firstStationCard = find.byType(Card).first;
      await tester.tap(firstStationCard);
      await tester.pumpAndSettle();

      expect(find.text('Información de la estación'), findsOneWidget);

      // Marcamos a estación como favorita
      final favIcon = find.byIcon(Icons.favorite_border);
      if (favIcon.evaluate().isNotEmpty) {
        await tester.tap(favIcon);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      } else {
        // Se xa estaba marcada como favorita, desmarcámola e volvemos a marcar
        final unfavIcon = find.byIcon(Icons.favorite);
        await tester.tap(unfavIcon);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);

        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }

      // Volvemos á pantalla principal
      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('BiciCoruña'), findsOneWidget);
    });
  });
}
