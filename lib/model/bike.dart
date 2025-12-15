class Bike {
  final int id;
  final String model;
  final int count;

  Bike({required this.id, required this.model, required this.count});

  factory Bike.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': final id, 'model': final model, 'count': final count} => Bike(
        id: id,
        model: model,
        count: count,
      ),
      _ => throw const FormatException('Error al parsear Bike'),
    };
  }
}
