import 'dart:convert';
import 'package:bicicoruna/services/favorites_services.dart';
import 'package:bicicoruna/view/station_list_screen.dart';
import 'package:bicicoruna/viewmodel/station_viewmodel.dart';
import 'package:bicicoruna/widgets/error_view.dart';
import 'package:bicicoruna/widgets/loading_indicator.dart';
import 'package:bicicoruna/model/station.dart';
import 'package:bicicoruna/model/bike.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client, FavoritesService])
import 'bottom_up_test.mocks.dart';

// ESTRATEXIA BOTTOM-UP: Probamos desde as capas máis baixas (Modelos)
// ata as superiores (UI completa)

void main() {
  Future<void> pumpWidget(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: child));
  }

  late MockClient mockClient;
  late StationViewModel stationViewModel;
  late MockFavoritesService mockFavoritesService;

  setUp(() {
    mockClient = MockClient();
    stationViewModel = StationViewModel(httpClient: mockClient);
    mockFavoritesService = MockFavoritesService();
    when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async => {});
    when(
      mockFavoritesService.toggleFavorite(any),
    ).thenAnswer((_) async => true);
    when(mockFavoritesService.isFavorite(any)).thenAnswer((_) async => false);
  });

  // NIVEL 1: Modelos - Parseado e validación de datos
  group('Nivel 1 - Modelos: Parseado y Validación de Datos', () {
    test('Station debe crearse correctamente desde JSON', () {
      final json = {
        'station_id': '1',
        'name': 'Obelisco',
        'lat': 43.36,
        'lon': -8.40,
        'capacity': 20,
        'is_renting': true,
        'num_bikes_available': 5,
        'num_docks_available': 15,
      };

      final station = Station.fromJson(json);

      expect(station.id, '1');
      expect(station.name, 'Obelisco');
      expect(station.lat, 43.36);
      expect(station.capacity, 20);
      expect(station.isRenting, true);
      expect(station.numBikesAvailable, 5);
    });

    test('Bike debe crearse correctamente con tipo eléctrico', () {
      final bike = Bike(id: 'E1', type: 'Eléctrica', count: 3);

      expect(bike.id, 'E1');
      expect(bike.type, 'Eléctrica');
      expect(bike.count, 3);
    });

    test('Station debe manejar datos incompletos sin fallar', () {
      final json = {'station_id': '2', 'name': 'Cuatro Caminos'};

      expect(() => Station.fromJson(json), returnsNormally);
    });
  });

  // NIVEL 2: ViewModel + Modelos - Procesamento de datos
  group('Nivel 2 - ViewModel + Modelos: Procesamiento de Datos', () {
    test(
      'getStations debe procesar JSON y devolver lista de objetos Station válidos',
      () async {
        final infoJson = {
          'data': {
            'stations': [
              {
                'station_id': '1',
                'name': 'Obelisco',
                'lat': 43.36,
                'lon': -8.40,
                'capacity': 20,
                'vehicle_types_available': [
                  {'vehicle_type_id': 'EBIKE', 'count': 5},
                ],
              },
            ],
          },
        };
        final statusJson = {
          'data': {
            'stations': [
              {
                'station_id': '1',
                'num_bikes_available': 5,
                'num_docks_available': 15,
                'is_renting': true,
              },
            ],
          },
        };
        final typesJson = {
          'data': {
            'vehicle_types': [
              {'vehicle_type_id': 'EBIKE', 'propulsion_type': 'electric'},
            ],
          },
        };

        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_information',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(infoJson), 200));

        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_status',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(statusJson), 200));

        when(
          mockClient.get(
            Uri.parse(
              'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/vehicle_types',
            ),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(typesJson), 200));

        final stations = await stationViewModel.getStations();

        expect(stations.length, 1);
        final station = stations.first;
        expect(station.name, 'Obelisco');
        expect(station.isRenting, true);
        expect(station.capacity, 20);
        expect(station.totalElectricBikes, 5);
        expect(station.bikes.first.type, 'Eléctrica');
      },
    );

    test('getStations debe manejar múltiples estaciones correctamente', () async {
      final infoJson = {
        'data': {
          'stations': [
            {'station_id': '1', 'name': 'Obelisco', 'capacity': 20},
            {'station_id': '2', 'name': 'Cuatro Caminos', 'capacity': 15},
            {'station_id': '3', 'name': 'Torre de Hércules', 'capacity': 25},
          ],
        },
      };
      final statusJson = {
        'data': {
          'stations': [
            {'station_id': '1', 'num_bikes_available': 5, 'is_renting': true},
            {'station_id': '2', 'num_bikes_available': 8, 'is_renting': true},
            {'station_id': '3', 'num_bikes_available': 0, 'is_renting': false},
          ],
        },
      };

      when(
        mockClient.get(
          Uri.parse(
            'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_information',
          ),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(infoJson), 200));
      when(
        mockClient.get(
          Uri.parse(
            'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_status',
          ),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(statusJson), 200));
      when(
        mockClient.get(
          Uri.parse(
            'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/vehicle_types',
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"data":{"vehicle_types":[]}}', 200),
      );

      final stations = await stationViewModel.getStations();

      expect(stations.length, 3);
      expect(stations[0].name, 'Obelisco');
      expect(stations[1].name, 'Cuatro Caminos');
      expect(stations[2].name, 'Torre de Hércules');
      expect(stations[2].isRenting, false); // Tercera estación no operativa
    });
  });

  // NIVEL 3: ViewModel + Services + Modelos - Lóxica de negocio
  group('Nivel 3 - ViewModel + Services + Modelos: Lógica de Negocio', () {
    test(
      'FavoritesService debe persistir y recuperar IDs de favoritos',
      () async {
        await mockFavoritesService.toggleFavorite('1');
        when(
          mockFavoritesService.getFavoriteIds(),
        ).thenAnswer((_) async => {'1'});

        final favorites = await mockFavoritesService.getFavoriteIds();

        expect(favorites, contains('1'));
        verify(mockFavoritesService.toggleFavorite('1')).called(1);
      },
    );

    test(
      'ViewModel debe coordinar con FavoritesService correctamente',
      () async {
        final infoJson = jsonEncode({
          'data': {
            'stations': [
              {'station_id': '1', 'name': 'Obelisco'},
              {'station_id': '2', 'name': 'Cuatro Caminos'},
            ],
          },
        });

        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(infoJson, 200));
        when(
          mockFavoritesService.getFavoriteIds(),
        ).thenAnswer((_) async => {'1'});

        final stations = await stationViewModel.getStations();
        final favorites = await mockFavoritesService.getFavoriteIds();

        expect(stations.length, 2);
        expect(favorites, contains('1'));
        expect(favorites, isNot(contains('2')));
      },
    );
  });

  // NIVEL 4: UI + ViewModel + Services - Integración completa
  group('Nivel 4 - UI + ViewModel + Services: Integración Completa', () {
    testWidgets(
      'Debe mostrar LoadingIndicator mientras se cargan las estaciones',
      (WidgetTester tester) async {
        when(mockClient.get(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return http.Response('{}', 200);
        });

        await pumpWidget(
          tester,
          StationListScreen(
            stationViewModel: stationViewModel,
            favoritesService: mockFavoritesService,
          ),
        );

        expect(find.byType(LoadingIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets('Debe mostrar la lista de estaciones si la carga es exitosa', (
      WidgetTester tester,
    ) async {
      final infoJson = jsonEncode({
        'data': {
          'stations': [
            {'station_id': '1', 'name': 'Obelisco'},
          ],
        },
      });
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(infoJson, 200));

      await pumpWidget(
        tester,
        StationListScreen(
          stationViewModel: stationViewModel,
          favoritesService: mockFavoritesService,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.text('Obelisco'), findsOneWidget);
    });

    testWidgets('Debe mostrar ErrorView si la carga falla', (
      WidgetTester tester,
    ) async {
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      await pumpWidget(
        tester,
        StationListScreen(
          stationViewModel: stationViewModel,
          favoritesService: mockFavoritesService,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.byType(ErrorView), findsOneWidget);
    });

    testWidgets(
      'Debe llamar a toggleFavorite y actualizar la UI al tocar el icono de favorito',
      (WidgetTester tester) async {
        final stationData = {
          'station_id': '1',
          'name': 'Obelisco',
          'is_renting': true,
          'num_bikes_available': 5,
          'num_docks_available': 15,
          'vehicle_types_available': [],
          'lat': 43.36,
          'lon': -8.40,
          'capacity': 20,
        };
        final infoJson = jsonEncode({
          'data': {
            'stations': [stationData],
          },
        });

        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(infoJson, 200));

        // Configurar resposta secuencial: baleiro -> con favorito
        reset(mockFavoritesService);
        var callCount = 0;
        when(mockFavoritesService.getFavoriteIds()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? {} : {'1'};
        });
        when(
          mockFavoritesService.toggleFavorite(any),
        ).thenAnswer((_) async => true);

        await pumpWidget(
          tester,
          StationListScreen(
            stationViewModel: stationViewModel,
            favoritesService: mockFavoritesService,
          ),
        );
        await tester.pumpAndSettle();

        final stationCardFinder = find.ancestor(
          of: find.text('Obelisco'),
          matching: find.byType(Card),
        );
        final favoriteIconFinder = find.descendant(
          of: stationCardFinder,
          matching: find.byIcon(Icons.favorite_border),
        );

        expect(find.text('Obelisco'), findsOneWidget);
        expect(favoriteIconFinder, findsOneWidget);

        await tester.tap(favoriteIconFinder);
        await tester.pumpAndSettle();

        verify(mockFavoritesService.toggleFavorite('1')).called(1);

        final favoriteFilledIconFinder = find.descendant(
          of: stationCardFinder,
          matching: find.byIcon(Icons.favorite),
        );

        expect(favoriteFilledIconFinder, findsOneWidget);
        expect(favoriteIconFinder, findsNothing);
      },
    );

    testWidgets('Debe filtrar estaciones favoritas correctamente en la UI', (
      WidgetTester tester,
    ) async {
      final infoJson = jsonEncode({
        'data': {
          'stations': [
            {'station_id': '1', 'name': 'Obelisco', 'capacity': 20},
            {'station_id': '2', 'name': 'Cuatro Caminos', 'capacity': 15},
          ],
        },
      });

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(infoJson, 200));
      when(
        mockFavoritesService.getFavoriteIds(),
      ).thenAnswer((_) async => {'1'});

      await pumpWidget(
        tester,
        StationListScreen(
          stationViewModel: stationViewModel,
          favoritesService: mockFavoritesService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Obelisco'), findsOneWidget);
      expect(find.text('Cuatro Caminos'), findsOneWidget);

      // Premer botón de filtro no AppBar
      final appBarFavoriteButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.favorite_border),
      );
      await tester.tap(appBarFavoriteButton);
      await tester.pumpAndSettle();

      expect(find.text('Obelisco'), findsOneWidget);
      expect(find.text('Cuatro Caminos'), findsNothing);
    });

    testWidgets('Debe buscar y filtrar estaciones mediante SearchDelegate', (
      WidgetTester tester,
    ) async {
      final infoJson = jsonEncode({
        'data': {
          'stations': [
            {'station_id': '1', 'name': 'Obelisco', 'capacity': 20},
            {'station_id': '2', 'name': 'Cuatro Caminos', 'capacity': 15},
            {'station_id': '3', 'name': 'Torre de Hércules', 'capacity': 25},
          ],
        },
      });

      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response(infoJson, 200));

      await pumpWidget(
        tester,
        StationListScreen(
          stationViewModel: stationViewModel,
          favoritesService: mockFavoritesService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Obelisco'), findsOneWidget);
      expect(find.text('Cuatro Caminos'), findsOneWidget);
      expect(find.text('Torre de Hércules'), findsOneWidget);

      // Abrir SearchDelegate (FloatingActionButton)
      final searchButton = find.byType(FloatingActionButton);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Escribir en el campo de búsqueda
      await tester.enterText(find.byType(TextField), 'Torre');
      await tester.pumpAndSettle();

      // Validar que solo aparece la estación filtrada
      expect(find.text('Torre de Hércules'), findsOneWidget);
      expect(find.text('Obelisco'), findsNothing);
      expect(find.text('Cuatro Caminos'), findsNothing);
    });
  });
}
