import 'package:flutter/material.dart';
import '../viewmodel/station_viewmodel.dart';
import '../services/favorites_services.dart';
import 'station_details_view.dart';
import 'station_search_delegate.dart';
import '../model/station.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import 'package:intl/intl.dart';

class StationListScreen extends StatefulWidget {
  final StationViewModel? viewModel;
  const StationListScreen({super.key, this.viewModel});

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  late final StationViewModel _viewModel;
  final FavoritesService _favoritesService = FavoritesService.instance;
  // Eliminamos _stationsFuture que non se están usando
  Set<String> _favoriteIds = <String>{};
  List<Station> _stations = [];
  List<Station> _filteredStations = [];
  bool _showFavoritesOnly = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? StationViewModel();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stations = await _viewModel.getStations(forceRefresh: true);
      final favoriteIds = await _favoritesService.getFavoriteIds();
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _favoriteIds = favoriteIds;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar las estaciones: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    if (_showFavoritesOnly) {
      _filteredStations = _stations
          .where((station) => _favoriteIds.contains(station.id))
          .toList();
    } else {
      _filteredStations = List.from(_stations);
    }
  }

  Future<void> _toggleFavorite(Station station) async {
    await _favoritesService.toggleFavorite(station.id);
    final favoriteIds = await _favoritesService.getFavoriteIds();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favoriteIds;
      _applyFilters();
    });
  }

  void _onSearchPressed() async {
    final result = await showSearch<Station?>(
      context: context,
      delegate: StationSearchDelegate(_stations),
    );

    if (result != null && mounted) {
      _navigateToStationDetails(result);
    }
  }

  Future<void> _navigateToStationDetails(Station station) async {
    final isFavorite = _favoriteIds.contains(station.id);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailsView(
          station: station,
          isFavorite: isFavorite,
          onFavoriteToggle: () => _toggleFavorite(station),
        ),
      ),
    );

    final favoriteIds = await _favoritesService.getFavoriteIds();
    if (!mounted) return;
    setState(() {
      _favoriteIds = favoriteIds;
      _applyFilters();
    });
  }

  void _toggleFavoritesOnly() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiciCoruña'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStations),
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: _toggleFavoritesOnly,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSearchPressed,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadStations);
    }

    if (_filteredStations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bike, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _showFavoritesOnly
                  ? 'No hay estaciones favoritas'
                  : 'No se encontraron estaciones',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_showFavoritesOnly) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _toggleFavoritesOnly,
                child: const Text('Mostrar todas las estaciones'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStations,
      child: ListView.builder(
        itemCount: _filteredStations.length,
        itemBuilder: (context, index) {
          final station = _filteredStations[index];
          final isFavorite = _favoriteIds.contains(station.id);

          return _buildStationCard(station, isFavorite);
        },
      ),
    );
  }

  Widget _buildStationCard(Station station, bool isFavorite) {
    final theme = Theme.of(context);
    final lastUpdate = DateFormat(
      'HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(station.lastReported * 1000));

    final capacity = station.capacity;
    final occupancy = capacity > 0
        ? (station.numBikesAvailable / capacity).clamp(0.0, 1.0)
        : 0.0;
    final occupancyPercent = (occupancy * 100).round();
    final occupancyColor = occupancy > 0.6
        ? Colors.green
        : occupancy > 0.3
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _navigateToStationDetails(station),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(station),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    station.isRenting ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: station.isRenting ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    station.isRenting ? 'Operativa' : 'No disponible',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Actualizado: $lastUpdate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildInfoChip(
                    '${station.numBikesAvailable} bicis',
                    Icons.directions_bike,
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    '${station.numDocksAvailable} anclajes',
                    Icons.local_parking,
                    theme.colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ocupación',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$occupancyPercent%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: occupancyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: occupancy,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
