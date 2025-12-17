import 'package:flutter/material.dart';
import '../model/station.dart';

class Stationdetailsview extends StatelessWidget {
  final Station station;

  const Stationdetailsview({Key? key, required this.station}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Station Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Dirección: ${station.address}'),
            Text('Capacidad: ${station.capacity}'),
            Text('Estado: ${station.status}'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordenadas:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Latitud: ${station.lat}'),
                    Text('Longitud: ${station.lon}'),
                    Text('Altitud: ${station.altitude} m'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Bicicletas en esta estación:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildBikeList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeList() {
    if (station.bikes.isEmpty) {
      return const Center(
        child: Text('No hay bicicletas disponibles en esta estación.'),
      );
    }
    return ListView.builder(
      itemCount: station.bikes.length,
      itemBuilder: (context, index) {
        final bicicleta = station.bikes[index];
        return ListTile(
          title: Text('ID de bicicleta: ${bicicleta.id}'),
          subtitle: Text('Modelo: ${bicicleta.model}'),
        );
      },
    );
  }
}
