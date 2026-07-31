class Ingredient {
  final String id;
  final String name;
  final double currentStock;
  final String unit;
  final double costPerUnit;

  Ingredient({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.unit,
    required this.costPerUnit,
  });

  factory Ingredient.fromMap(Map<String, Object?> map) {
    return Ingredient(
      id: map['id'] as String,
      name: map['name'] as String,
      currentStock: (map['current_stock'] as num).toDouble(),
      unit: map['unit'] as String,
      costPerUnit: (map['cost_per_unit'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'current_stock': currentStock,
      'unit': unit,
      'cost_per_unit': costPerUnit,
    };
  }
}
