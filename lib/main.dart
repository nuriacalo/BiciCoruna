import 'package:flutter/material.dart';
import '../model/station.dart';
import '../viewmodel/stationViewModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bicis Coruña',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Bicis Coruña'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Station>>? futureStations;
  @override
  void initState() {
    super.initState();
    futureStations = Stationviewmodel().getStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Station>>(
          future: futureStations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final stations = snapshot.data!;
              if (stations.isEmpty) {
                return const Text('No hay estaciones disponibles en este momento.');
              }
              return ListView.builder(
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(station.name),
                      subtitle: Text('Bicicletas disponibles: ${station.num_bikes_available}'),
                      trailing: Icon(
                        station.is_renting ? Icons.check_circle : Icons.cancel,
                        color: station.is_renting ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('No se encontraron estaciones.');
            }
          },
        ),
      ),
    );
  }
}
