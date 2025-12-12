class Bike {
  final int id;
  final String model;
  final int count;

  Bike({required this.id, required this.model, required this.count});

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: (json['id'] as num).toInt(),
      model: json['model'],
      count: (json['count'] as num).toInt(),
    );
  }
}
