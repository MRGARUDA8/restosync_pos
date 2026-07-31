class AuditLog {
  final String id;
  final String userId;
  final String action;
  final String reason;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.reason,
    required this.timestamp,
  });

  factory AuditLog.fromMap(Map<String, Object?> map) {
    return AuditLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      action: map['action'] as String,
      reason: map['reason'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
