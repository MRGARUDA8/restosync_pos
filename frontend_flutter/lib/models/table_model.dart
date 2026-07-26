class TableModel {
  final String id;
  final String tableNumber;
  final int capacity;
  final String section;
  final String status;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.section,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['_id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      capacity: json['capacity'] ?? 4,
      section: json['section'] ?? 'Main Dining',
      status: json['status'] ?? 'Available',
    );
  }
}
