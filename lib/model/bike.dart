class Bike {
  final String id; // "BIKE" o "EBIKE"
  final String type; // "Mecánica" o "Eléctrica"
  final int count;

  Bike({required this.id, required this.type, required this.count});

  factory Bike.fromType(String typeId, int count, {String? propulsionType}) {
    final isElectricFromPropulsion = propulsionType != null
        ? (propulsionType != 'human')
        : null;
    final isElectricFromId =
        typeId == 'EBIKE' ||
        typeId == '2' ||
        typeId.startsWith('E') ||
        typeId == 'BOOST' ||
        typeId == 'COSMO' ||
        typeId == 'ASTRO';
    final isElectric = isElectricFromPropulsion ?? isElectricFromId;
    return Bike(
      id: typeId,
      type: isElectric ? 'Eléctrica' : 'Mecánica',
      count: count,
    );
  }
}
