class Customer {
  final String id;
  final String name;
  final String mobile;
  final int totalOrders;
  final double totalSpent;
  final int loyaltyPoints;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.totalOrders,
    required this.totalSpent,
    required this.loyaltyPoints,
  });

  factory Customer.fromMap(Map<String, Object?> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      totalOrders: map['total_orders'] as int,
      totalSpent: (map['total_spent'] as num).toDouble(),
      loyaltyPoints: map['loyalty_points'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'loyalty_points': loyaltyPoints,
    };
  }
}
