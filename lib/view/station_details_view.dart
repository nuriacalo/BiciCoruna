import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/station.dart';

class StationDetailsView extends StatelessWidget {
  final Station station;

  const StationDetailsView({Key? key, required this.station}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availability = station.capacity > 0
        ? station.numBikesAvailable / station.capacity
        : 0.0;
    final lastUpdate = DateFormat('HH:mm \'del\' dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(station.lastReported * 1000));

    final mechanicalBikes = station.vehicleTypesAvailable['BIKE'] ?? 0;
    final electricBikes = station.vehicleTypesAvailable['EBIKE'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de la estación')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen de encabezado
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Icon(
                Icons.directions_bike,
                size: 80,
                color: theme.primaryColor,
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y estado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: station.isRenting
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: station.isRenting
                                ? Colors.green
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          station.isRenting ? 'Disponible' : 'No disponible',
                          style: TextStyle(
                            color: station.isRenting
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Dirección
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          station.address,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tarjeta de disponibilidad
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disponibilidad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: availability,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              availability > 0.5
                                  ? Colors.green
                                  : availability > 0.2
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem(
                                Icons.pedal_bike,
                                'Mecánicas',
                                '$mechanicalBikes',
                                Colors.blue,
                              ),
                              _buildInfoItem(
                                Icons.electric_bike,
                                'Eléctricas',
                                '$electricBikes',
                                Colors.purple,
                              ),
                              _buildInfoItem(
                                Icons.local_parking,
                                'Plazas libres',
                                '${station.numDocksAvailable}',
                                Colors.orange,
                              ),
                              _buildInfoItem(
                                Icons.bolt,
                                'Capacidad',
                                '${station.capacity}',
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Más información
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de la estación',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Última actualización',
                            lastUpdate,
                            Icons.update,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Anclajes averiados',
                            '${station.numDocksDisabled}',
                            Icons.warning_amber,
                          ),
                          if (station.postCode > 0) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Código postal',
                              station.postCode.toString(),
                              Icons.numbers,
                            ),
                          ],
                          if (station.physicalConfiguration.isNotEmpty) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Tipo de estación',
                              station.physicalConfiguration,
                              Icons.settings,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
