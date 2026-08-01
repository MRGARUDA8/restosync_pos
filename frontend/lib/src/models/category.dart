class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final DateTime createdAt;
  final String? userId;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.userId,
  });

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
