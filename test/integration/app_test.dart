import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bicicoruna/main.dart' as app;

// PROBA DE SISTEMA END-TO-END: Fluxo completo de xestión de favoritos
// Simula o comportamento dun usuario real interactuando coa app

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba de Sistema End-to-End: Flujo de Favoritos', () {
    testWidgets(
      'Fluxo completo: Carga → Detalle → Marcar favorito → Filtrar favoritos',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});

        // Mock do path_provider para persistencia local
        const MethodChannel channel = MethodChannel(
          'plugins.flutter.io/path_provider',
        );
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (MethodCall methodCall) async => ".",
        );

        app.main();
        await tester.pumpAndSettle();

        // PASO 1: Esperar carga de datos da API real
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(Card).evaluate().isNotEmpty) break;
        }

        expect(find.text('BiciCoruña'), findsOneWidget);
        expect(find.byType(Card), findsAtLeastNWidgets(1));

        final initialStationCount = find.byType(Card).evaluate().length;

        // PASO 2: Entrar en detalle da primeira estación
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        expect(find.text('Información de la estación'), findsOneWidget);

        // Marcamos a estación como favorita
        find.byIcon(Icons.favorite_border);
        // PASO 3: Marcar como favorito
        final favIconInDetail = find.byIcon(Icons.favorite_border);
        if (favIconInDetail.evaluate().isNotEmpty) {
          await tester.tap(favIconInDetail);
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        } else {
          // Se xa é favorito, desmarcar e volver marcar
          await tester.tap(find.byIcon(Icons.favorite));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.favorite_border));
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        }

        // PASO 4: Volver á lista principal
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();

        expect(find.text('BiciCoruña'), findsOneWidget);
        expect(find.byType(Card), findsAtLeastNWidgets(1));

        // PASO 5: Activar filtro de favoritos no AppBar
        final favoriteFilterButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.favorite_border),
        );

        await tester.tap(favoriteFilterButton);
        await tester.pumpAndSettle();

        // Validar que o filtro funciona (debe haber menos estacións)
        final filteredStationCount = find.byType(Card).evaluate().length;
        expect(filteredStationCount, lessThan(initialStationCount));
        expect(filteredStationCount, greaterThanOrEqualTo(1));

        // PASO 6: Desactivar filtro
        final favoriteFilterButtonActive = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.favorite),
        );

        await tester.tap(favoriteFilterButtonActive);
        await tester.pumpAndSettle();

        // Validar que volven todas as estacións
        expect(
          find.byType(Card).evaluate().length,
          equals(initialStationCount),
        );
      },
    );
  });
}
