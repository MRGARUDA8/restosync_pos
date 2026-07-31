class Expense {
  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;
  final String userId;

  Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
    required this.userId,
  });

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String,
      userId: map['user_id'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'user_id': userId,
    };
  }
}
