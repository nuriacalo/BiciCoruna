import '../model/station.dart';
import 'package:flutter/material.dart';

class StationSearchDelegate extends SearchDelegate<Station?> {
  final List<Station> stationsSearch;

  StationSearchDelegate(this.stationsSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFilteredList();
  }

  Widget _buildFilteredList() {
    final List<Station> matchQuery = [];
    for (var station in stationsSearch) {
      if (station.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(station);
      }
    }
    if (matchQuery.isEmpty) {
      return const Center(child: Text('No se encontraron estaciones'));
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.name),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }
}
