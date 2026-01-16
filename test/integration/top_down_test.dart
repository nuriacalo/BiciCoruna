import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:bicicoruna/view/station_list_screen.dart';
import 'package:bicicoruna/viewmodel/station_viewmodel.dart';
import 'package:bicicoruna/model/station.dart';
import 'package:bicicoruna/model/bike.dart';

// Xerar mocks
@GenerateMocks([StationViewModel])
import 'top_down_test.mocks.dart';

void main() {
  group('Integración Descendente: UI -> ViewModel Simulado', () {
    late MockStationViewModel mockViewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockViewModel = MockStationViewModel();
    });
    testWidgets(
      'UI debe mostrar lista de estaciones cuando ViewModel devuelve datos',
      (WidgetTester tester) async {
        final stations = [
          Station(
            id: '1',
            name: 'Torre de Hércules',
            lat: 0,
            lon: 0,
            altitude: 0,
            address: '',
            postCode: 0,
            capacity: 10,
            isChargingStation: false,
            nearbyDistance: '',
            numBikesAvailable: 5,
            numDocksAvailable: 5,
            numBikesDisabled: 0,
            numDocksDisabled: 0,
            lastReported: 0,
            vehicleTypesAvailable: {},
            status: 'IN_SERVICE',
            isRenting: true,
            isReturning: true,
            bikes: [Bike(id: 'E1', type: 'Eléctrica', count: 5)],
          ),
        ];
        when(
          mockViewModel.getStations(forceRefresh: anyNamed('forceRefresh')),
        ).thenAnswer((_) async => stations);

        //Arranca UI co ViewModel simulado
        await tester.pumpWidget(
          MaterialApp(home: StationListScreen(viewModel: mockViewModel)),
        );

        //Espera a que se resolva o FutureBuilder
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 100));

        // Verifica que a lista de estacións se mostra correctamente
        expect(find.text('Torre de Hércules'), findsOneWidget);
        expect(find.text('Operativa'), findsOneWidget);
        expect(find.text('5 bicis'), findsOneWidget);
      },
    );
  });
}
