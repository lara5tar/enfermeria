/// Modelo de usuario para el sistema de autenticación
/// Define la estructura de datos del usuario y sus roles
class UserModel {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final UserRole role;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;
  final String? profileImageUrl;
  final Map<String, dynamic>? additionalData;
  final String sessionToken;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.role,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
    this.profileImageUrl,
    this.additionalData,
    required this.sessionToken,
  });

  /// Constructor para crear un nuevo usuario
  UserModel.create({
    required this.email,
    required this.name,
    required this.lastName,
    required this.role,
    required this.passwordHash,
    this.profileImageUrl,
    this.additionalData,
  })  : id = _generateUserId(),
        createdAt = DateTime.now(),
        lastLogin = DateTime.now(),
        isActive = true,
        sessionToken = '';

  /// Genera un ID único para el usuario basado en email y timestamp
  static String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'user_$timestamp';
  }

  /// Convierte el modelo a Map para almacenar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'additionalData': additionalData ?? {},
      'sessionToken': sessionToken,
    };
  }

  /// Crea un UserModel desde datos de Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == data['role'],
        orElse: () => UserRole.user,
      ),
      passwordHash: data['passwordHash'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      lastLogin: DateTime.tryParse(data['lastLogin'] ?? '') ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'],
      additionalData: data['additionalData'] is Map<String, dynamic>
          ? data['additionalData']
          : null,
      sessionToken: data['sessionToken'] ?? '',
    );
  }

  /// Crea una copia del usuario con campos actualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? lastName,
    UserRole? role,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
    String? sessionToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      additionalData: additionalData ?? this.additionalData,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }

  /// Obtiene el nombre completo del usuario
  String get fullName => '$name $lastName'.trim();

  /// Verifica si el usuario es administrador
  bool get isAdmin => role == UserRole.admin;

  /// Verifica si el usuario es usuario normal
  bool get isUser => role == UserRole.user;

  /// Obtiene los permisos del usuario según su rol
  UserPermissions get permissions => UserPermissions.fromRole(role);

  /// Verifica si el usuario tiene un permiso específico
  bool hasPermission(String permission) {
    return permissions.hasPermission(permission);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

/// Enum para definir los roles de usuario
enum UserRole {
  admin,
  user,
}

/// Extensión para obtener información adicional de los roles
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.user:
        return 'Usuario';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Acceso completo al sistema, puede gestionar usuarios y configuraciones';
      case UserRole.user:
        return 'Acceso básico al sistema, puede usar las funcionalidades principales';
    }
  }

  List<String> get defaultPermissions {
    switch (this) {
      case UserRole.admin:
        return [
          'read_all',
          'write_all',
          'delete_all',
          'manage_users',
          'manage_settings',
          'view_analytics',
          'export_data',
        ];
      case UserRole.user:
        return [
          'read_own',
          'write_own',
          'view_reminders',
          'create_reminders',
          'edit_own_reminders',
          'delete_own_reminders',
        ];
    }
  }
}

/// Clase para manejar permisos de usuario
class UserPermissions {
  final List<String> permissions;

  UserPermissions(this.permissions);

  factory UserPermissions.fromRole(UserRole role) {
    return UserPermissions(role.defaultPermissions);
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }

  /// Verifica si puede leer datos
  bool get canRead => hasAnyPermission(['read_all', 'read_own']);

  /// Verifica si puede escribir datos
  bool get canWrite => hasAnyPermission(['write_all', 'write_own']);

  /// Verifica si puede eliminar datos
  bool get canDelete => hasAnyPermission(['delete_all', 'delete_own_reminders']);

  /// Verifica si puede gestionar usuarios
  bool get canManageUsers => hasPermission('manage_users');

  /// Verifica si puede gestionar configuraciones
  bool get canManageSettings => hasPermission('manage_settings');

  /// Verifica si puede ver analíticas
  bool get canViewAnalytics => hasPermission('view_analytics');

  /// Verifica si puede exportar datos
  bool get canExportData => hasPermission('export_data');
}