import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:bicicoruna/view/station_list_screen.dart';
import 'package:bicicoruna/viewmodel/station_viewmodel.dart';
import 'package:bicicoruna/model/station.dart';
import 'package:bicicoruna/model/bike.dart';
import 'package:bicicoruna/services/favorites_services.dart';
import 'package:bicicoruna/widgets/loading_indicator.dart';
import 'package:bicicoruna/widgets/error_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Xerar mocks
@GenerateMocks([StationViewModel, FavoritesService, http.Client])
import 'top_down_test.mocks.dart';

// ESTRATEXIA TOP-DOWN: Probamos desde a UI (todo simulado)
// e imos integrando capas reais progresivamente

void main() {
  // NIVEL 1: UI illada - Todo simulado
  group('Nivel 1 - UI Aislada: Toda la lógica simulada', () {
    late MockStationViewModel mockViewModel;
    late MockFavoritesService mockFavoritesService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockViewModel = MockStationViewModel();
      mockFavoritesService = MockFavoritesService();
      when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async => {});
      when(mockFavoritesService.toggleFavorite(any)).thenAnswer((_) async => true);
    });

    testWidgets(
      'UI debe renderizar correctamente con datos simulados',
      (WidgetTester tester) async {
        final stations = [
          Station(
            id: '1',
            name: 'Torre de Hércules',
            lat: 43.38,
            lon: -8.40,
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
            lastReported: 1234567890,
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

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: mockViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Torre de Hércules'), findsOneWidget);
        expect(find.text('Operativa'), findsOneWidget);
        expect(find.text('5 bicis'), findsOneWidget);
      },
    );

    testWidgets(
      'UI debe manejar estados de carga con ViewModel simulado',
      (WidgetTester tester) async {
        when(mockViewModel.getStations(forceRefresh: anyNamed('forceRefresh')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        });

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: mockViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );

        expect(find.byType(LoadingIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(LoadingIndicator), findsNothing);
      },
    );

    testWidgets(
      'UI debe manejar errores con ViewModel simulado',
      (WidgetTester tester) async {
        when(mockViewModel.getStations(forceRefresh: anyNamed('forceRefresh')))
            .thenThrow(Exception('Error de conexión simulado'));

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: mockViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ErrorView), findsOneWidget);
      },
    );

    testWidgets(
      'UI debe manejar interacción de favoritos con service simulado',
      (WidgetTester tester) async {
        final station = Station(
          id: '1',
          name: 'Obelisco',
          lat: 43.36,
          lon: -8.40,
          altitude: 0,
          address: '',
          postCode: 0,
          capacity: 20,
          isChargingStation: false,
          nearbyDistance: '',
          numBikesAvailable: 5,
          numDocksAvailable: 15,
          numBikesDisabled: 0,
          numDocksDisabled: 0,
          lastReported: 1234567890,
          vehicleTypesAvailable: {},
          status: 'IN_SERVICE',
          isRenting: true,
          isReturning: true,
          bikes: [],
        );

        when(mockViewModel.getStations(forceRefresh: anyNamed('forceRefresh')))
            .thenAnswer((_) async => [station]);
        
        // Configurar respuestas secuenciales para getFavoriteIds
        var callCount = 0;
        when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? {} : {'1'};
        });

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: mockViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tocar el icono de favorito
        final favoriteIcon = find.byIcon(Icons.favorite_border).first;
        await tester.tap(favoriteIcon);
        await tester.pumpAndSettle();

        // Verificar que se llamó al servicio
        verify(mockFavoritesService.toggleFavorite('1')).called(1);

        // El icono debe cambiar
        expect(find.byIcon(Icons.favorite), findsWidgets);
      },
    );
  });

  // NIVEL 2: UI + ViewModel real - Services simulados
  group('Nivel 2 - UI + ViewModel Real: Services simulados', () {
    late MockClient mockHttpClient;
    late StationViewModel realViewModel;
    late MockFavoritesService mockFavoritesService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockHttpClient = MockClient();
      realViewModel = StationViewModel(httpClient: mockHttpClient);
      mockFavoritesService = MockFavoritesService();
      when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async => {});
      when(mockFavoritesService.toggleFavorite(any)).thenAnswer((_) async => true);
    });

    testWidgets(
      'UI + ViewModel real procesan datos HTTP simulados correctamente',
      (WidgetTester tester) async {
        final infoJson = jsonEncode({
          'data': {
            'stations': [
              {
                'station_id': '1',
                'name': 'Cuatro Caminos',
                'lat': 43.36,
                'lon': -8.40,
                'capacity': 15
              }
            ]
          }
        });

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(infoJson, 200));

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: realViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cuatro Caminos'), findsOneWidget);
        verify(mockHttpClient.get(any)).called(greaterThan(0));
      },
    );

    testWidgets(
      'UI + ViewModel real manejan errores HTTP simulados',
      (WidgetTester tester) async {
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: realViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ErrorView), findsOneWidget);
      },
    );

    testWidgets(
      'UI + ViewModel real coordinan con FavoritesService simulado',
      (WidgetTester tester) async {
        final infoJson = jsonEncode({
          'data': {
            'stations': [
              {
                'station_id': '1',
                'name': 'Obelisco',
                'capacity': 20,
                'num_bikes_available': 5,
                'is_renting': true
              }
            ]
          }
        });

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(infoJson, 200));

        var callCount = 0;
        when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? {} : {'1'};
        });

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: realViewModel,
              favoritesService: mockFavoritesService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tocar favorito
        final favoriteIcon = find.byIcon(Icons.favorite_border).first;
        await tester.tap(favoriteIcon);
        await tester.pumpAndSettle();

        // ViewModel REAL coordinó con el service SIMULADO
        verify(mockFavoritesService.toggleFavorite('1')).called(1);
        expect(find.byIcon(Icons.favorite), findsWidgets);
      },
    );
  });

  // NIVEL 3: Integración case completa - Só HTTP simulado
  group('Nivel 3 - Integración Casi Completa: Solo HTTP simulado', () {
    late MockClient mockHttpClient;
    late StationViewModel realViewModel;
    late FavoritesService realFavoritesService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockHttpClient = MockClient();
      realViewModel = StationViewModel(httpClient: mockHttpClient);
      realFavoritesService = FavoritesService.instance;
    });

    testWidgets(
      'Sistema completo funciona con solo HTTP simulado',
      (WidgetTester tester) async {
        final infoJson = jsonEncode({
          'data': {
            'stations': [
              {
                'station_id': '100',
                'name': 'Plaza de España',
                'lat': 43.36,
                'lon': -8.41,
                'capacity': 25,
                'num_bikes_available': 10,
                'is_renting': true
              }
            ]
          }
        });

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(infoJson, 200));

        await tester.pumpWidget(
          MaterialApp(
            home: StationListScreen(
              stationViewModel: realViewModel,
              favoritesService: realFavoritesService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Plaza de España'), findsOneWidget);

        final favoriteIcon = find.byIcon(Icons.favorite_border).first;
        await tester.tap(favoriteIcon);
        await tester.pumpAndSettle();

        final favorites = await realFavoritesService.getFavoriteIds();
        expect(favorites, contains('100'));
      },
    );
  });
}
