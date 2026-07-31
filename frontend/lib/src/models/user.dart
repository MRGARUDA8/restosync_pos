enum UserRole { admin, manager, cashier, kitchen }

class User {
  final String id;
  final String name;
  final UserRole role;
  final String pin;
  final List<String> permissions;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.pin,
    required this.permissions,
  });

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere((role) => role.name == map['role']),
      pin: map['pin'] as String,
      permissions: (map['permissions'] as String).split(',').where((value) => value.isNotEmpty).toList(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'pin': pin,
      'permissions': permissions.join(','),
    };
  }
}
