class Recipe {
  final String id;
  final String variantId;
  final String ingredientId;
  final double quantityRequired;

  Recipe({
    required this.id,
    required this.variantId,
    required this.ingredientId,
    required this.quantityRequired,
  });

  factory Recipe.fromMap(Map<String, Object?> map) {
    return Recipe(
      id: map['id'] as String,
      variantId: map['variant_id'] as String,
      ingredientId: map['ingredient_id'] as String,
      quantityRequired: (map['quantity_required'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'variant_id': variantId,
      'ingredient_id': ingredientId,
      'quantity_required': quantityRequired,
    };
  }
}
