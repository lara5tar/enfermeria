import '../models/user_model.dart';
import '../services/encryption_service.dart';
import '../services/firebase_firestore/api_provider.dart';

/// Servicio de autenticación que utiliza Firestore personalizado
/// Maneja login, registro, sesiones y validación de usuarios
class AuthService {
  static const String _usersCollection = 'users';
  static const String _sessionsCollection = 'user_sessions';
  
  final FirebaseApiProvider _firestoreApi;
  final EncryptionService _encryptionService;
  
  // Singleton pattern
  static AuthService? _instance;
  
  AuthService._internal(this._firestoreApi, this._encryptionService);
  
  factory AuthService({
    required String projectId,
    EncryptionService? encryptionService,
  }) {
    _instance ??= AuthService._internal(
      FirebaseApiProvider(
        idProject: projectId,
        model: _usersCollection,
      ),
      encryptionService ?? EncryptionService(),
    );
    return _instance!;
  }
  
  static AuthService get instance {
    if (_instance == null) {
      throw Exception('AuthService no ha sido inicializado. Llama a AuthService(projectId: "tu-proyecto") primero.');
    }
    return _instance!;
  }

  /// Valida si una contraseña es lo suficientemente fuerte
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  /// Registra un nuevo usuario en el sistema
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String name,
    required String lastName,
    UserRole role = UserRole.user,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Validar fortaleza de la contraseña
      if (!_isPasswordStrong(password)) {
        return AuthResult.failure(
          'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y símbolos.',
        );
      }

      // Verificar si el email ya existe
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.failure('El email ya está registrado en el sistema.');
      }

      // Encriptar contraseña
      final hashedPassword = EncryptionService.hashPassword(password, email);
      
      // Crear usuario
      final user = UserModel.create(
        email: email.toLowerCase().trim(),
        name: name.trim(),
        lastName: lastName.trim(),
        role: role,
        passwordHash: hashedPassword,
        profileImageUrl: profileImageUrl,
        additionalData: additionalData,
      );

      // Guardar en Firestore
      final response = await _firestoreApi.addWithCustomId(
        user.id,
        user.toFirestore(),
      );

      if (response['success'] == true) {
        return AuthResult.success(
          user: user,
          message: 'Usuario registrado exitosamente.',
        );
      } else {
        return AuthResult.failure('Error al registrar usuario: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      return AuthResult.failure('Error inesperado durante el registro: $e');
    }
  }

  /// Inicia sesión con email y contraseña
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔐 [AUTH] Iniciando proceso de login para: $email');
      
      // Buscar usuario por email
      print('🔍 [AUTH] Buscando usuario por email...');
      final user = await _getUserByEmail(email);
      if (user == null) {
        print('❌ [AUTH] Usuario no encontrado para email: $email');
        return AuthResult.failure('Email o contraseña incorrectos.');
      }
      
      print('✅ [AUTH] Usuario encontrado: ${user.name} ${user.lastName} (${user.role.name})');
      print('📧 [AUTH] Email del usuario: ${user.email}');
      print('🔑 [AUTH] Hash almacenado: ${user.passwordHash}');

      // Verificar si el usuario está activo
      if (!user.isActive) {
        print('❌ [AUTH] Usuario inactivo: ${user.email}');
        return AuthResult.failure('La cuenta está desactivada. Contacta al administrador.');
      }
      
      print('✅ [AUTH] Usuario activo, verificando contraseña...');

      // Verificar contraseña
      print('🔐 [AUTH] Contraseña ingresada: $password');
      final expectedHash = EncryptionService.hashPassword(password, user.email);
      print('🔑 [AUTH] Hash esperado: $expectedHash');
      print('🔑 [AUTH] Hash almacenado: ${user.passwordHash}');
      
      final isPasswordValid = EncryptionService.verifyPassword(
        password,
        user.email,
        user.passwordHash,
      );
      
      print('🔐 [AUTH] Resultado verificación contraseña: $isPasswordValid');
      
      if (!isPasswordValid) {
        print('❌ [AUTH] Contraseña incorrecta para: $email');
        return AuthResult.failure('Email o contraseña incorrectos.');
      }
      
      print('✅ [AUTH] Contraseña válida, generando token de sesión...');

      // Generar token de sesión
      final sessionToken = EncryptionService.generateSessionToken();
      print('🎫 [AUTH] Token de sesión generado: $sessionToken');
      
      // Actualizar último login y token de sesión
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
        sessionToken: sessionToken,
      );

      print('💾 [AUTH] Actualizando datos de sesión en Firestore...');
      // Actualizar en Firestore
      final updateResponse = await _firestoreApi.update(
        user.id,
        {
          'lastLogin': updatedUser.lastLogin.toIso8601String(),
          'sessionToken': sessionToken,
        },
      );

      if (updateResponse['success'] != true) {
        print('❌ [AUTH] Error al actualizar sesión: ${updateResponse['error']}');
        return AuthResult.failure('Error al actualizar sesión: ${updateResponse['error'] ?? 'Error desconocido'}');
      }
      
      print('✅ [AUTH] Sesión actualizada correctamente');

      // Crear sesión si se solicita recordar
      if (rememberMe) {
        print('💾 [AUTH] Creando sesión persistente...');
        await _createUserSession(updatedUser, sessionToken);
      }

      print('🎉 [AUTH] Login exitoso para: ${user.email}');
      return AuthResult.success(
        user: updatedUser,
        sessionToken: sessionToken,
        message: 'Inicio de sesión exitoso.',
      );
    } catch (e) {
      print('💥 [AUTH] Error inesperado durante el login: $e');
      return AuthResult.failure('Error inesperado durante el login: $e');
    }
  }

  /// Valida un token de sesión
  Future<AuthResult> validateSession(String sessionToken) async {
    try {
      // Buscar usuario por token de sesión
      final users = await _firestoreApi.queryByFieldFormatted(
        field: 'sessionToken',
        value: sessionToken,
      );

      if (users.isEmpty) {
        return AuthResult.failure('Sesión inválida o expirada.');
      }

      final userData = users.first;
      final user = UserModel.fromFirestore(userData);

      // Verificar si el usuario está activo
      if (!user.isActive) {
        return AuthResult.failure('La cuenta está desactivada.');
      }

      // Verificar si la sesión no ha expirado (24 horas)
      final sessionAge = DateTime.now().difference(user.lastLogin);
      if (sessionAge.inHours > 24) {
        await logout(user.id);
        return AuthResult.failure('La sesión ha expirado.');
      }

      return AuthResult.success(
        user: user,
        sessionToken: sessionToken,
        message: 'Sesión válida.',
      );
    } catch (e) {
      return AuthResult.failure('Error al validar sesión: $e');
    }
  }

  /// Cierra la sesión del usuario
  Future<AuthResult> logout(String userId) async {
    try {
      // Limpiar token de sesión
      final response = await _firestoreApi.update(
        userId,
        {'sessionToken': ''},
      );

      if (response['success'] == true) {
        // Eliminar sesión persistente si existe
        await _deleteUserSession(userId);
        return AuthResult.success(message: 'Sesión cerrada exitosamente.');
      } else {
        return AuthResult.failure('Error al cerrar sesión: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      return AuthResult.failure('Error inesperado al cerrar sesión: $e');
    }
  }

  /// Cambia la contraseña del usuario
  Future<AuthResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Obtener usuario actual
      final user = await getUserById(userId);
      if (user == null) {
        return AuthResult.failure('Usuario no encontrado.');
      }

      // Verificar contraseña actual
      final isCurrentPasswordValid = EncryptionService.verifyPassword(
        currentPassword,
        user.email,
        user.passwordHash,
      );
      
      if (!isCurrentPasswordValid) {
        return AuthResult.failure('La contraseña actual es incorrecta.');
      }

      // Validar nueva contraseña
      if (!_isPasswordStrong(newPassword)) {
        return AuthResult.failure(
          'La nueva contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y símbolos.',
        );
      }

      // Encriptar nueva contraseña
      final newHashedPassword = EncryptionService.hashPassword(newPassword, user.email);
      
      // Actualizar en Firestore
      final response = await _firestoreApi.update(
        userId,
        {'passwordHash': newHashedPassword},
      );

      if (response['success'] == true) {
        return AuthResult.success(message: 'Contraseña actualizada exitosamente.');
      } else {
        return AuthResult.failure('Error al actualizar contraseña: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      return AuthResult.failure('Error inesperado al cambiar contraseña: $e');
    }
  }

  /// Obtiene un usuario por su ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _firestoreApi.get(userId);
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromFirestore(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un usuario por email
  Future<UserModel?> _getUserByEmail(String email) async {
    try {
      final users = await _firestoreApi.queryByFieldFormatted(
        field: 'email',
        value: email.toLowerCase().trim(),
      );
      
      if (users.isNotEmpty) {
        return UserModel.fromFirestore(users.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crea una sesión persistente para "recordar usuario"
  Future<void> _createUserSession(UserModel user, String sessionToken) async {
    try {
      final sessionApi = FirebaseApiProvider(
        idProject: _firestoreApi.idProject,
        model: _sessionsCollection,
      );
      
      await sessionApi.addWithCustomId(
        user.id,
        {
          'userId': user.id,
          'sessionToken': sessionToken,
          'createdAt': DateTime.now().toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        },
      );
    } catch (e) {
      // Error silencioso, no afecta el login principal
    }
  }

  /// Elimina la sesión persistente
  Future<void> _deleteUserSession(String userId) async {
    try {
      final sessionApi = FirebaseApiProvider(
        idProject: _firestoreApi.idProject,
        model: _sessionsCollection,
      );
      
      await sessionApi.delete(userId);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Obtiene todos los usuarios (solo para administradores)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _firestoreApi.getAll();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersData = response['data'];
        return usersData.map((userData) => UserModel.fromFirestore(userData)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Actualiza el rol de un usuario (solo para administradores)
  Future<AuthResult> updateUserRole(String userId, UserRole newRole) async {
    try {
      final response = await _firestoreApi.update(
        userId,
        {'role': newRole.toString().split('.').last},
      );

      if (response['success'] == true) {
        return AuthResult.success(message: 'Rol actualizado exitosamente.');
      } else {
        return AuthResult.failure('Error al actualizar rol: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      return AuthResult.failure('Error inesperado al actualizar rol: $e');
    }
  }

  /// Crea un usuario administrador por defecto si no existe
  Future<AuthResult> createDefaultAdmin() async {
    try {
      // Verificar si ya existe un admin
      final adminUsers = await _firestoreApi.queryByFieldFormatted(
        field: 'role',
        value: 'admin',
      );

      if (adminUsers.isNotEmpty) {
        return AuthResult.success(
          message: 'Ya existe un usuario administrador.',
        );
      }

      // Crear admin por defecto
      const adminEmail = 'admin@enfermeria.com';
      const adminPassword = 'Admin123!';
      
      final result = await registerUser(
        email: adminEmail,
        password: adminPassword,
        name: 'Administrador',
        lastName: 'Sistema',
        role: UserRole.admin,
      );

      if (result.isSuccess) {
        return AuthResult.success(
          message: 'Usuario administrador creado exitosamente.\nEmail: $adminEmail\nContraseña: $adminPassword',
          user: result.user,
        );
      } else {
        return result;
      }
    } catch (e) {
      return AuthResult.failure('Error al crear administrador por defecto: $e');
    }
  }

  /// Activa o desactiva un usuario (solo para administradores)
  Future<AuthResult> toggleUserStatus(String userId, bool isActive) async {
    try {
      final response = await _firestoreApi.update(
        userId,
        {'isActive': isActive},
      );

      if (response['success'] == true) {
        final status = isActive ? 'activado' : 'desactivado';
        return AuthResult.success(message: 'Usuario $status exitosamente.');
      } else {
        return AuthResult.failure('Error al cambiar estado: ${response['error'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      return AuthResult.failure('Error inesperado al cambiar estado: $e');
    }
  }
}

/// Clase para manejar resultados de autenticación
class AuthResult {
  final bool isSuccess;
  final String message;
  final UserModel? user;
  final String? sessionToken;
  final String? error;

  AuthResult._(
    this.isSuccess,
    this.message, {
    this.user,
    this.sessionToken,
    this.error,
  });

  factory AuthResult.success({
    required String message,
    UserModel? user,
    String? sessionToken,
  }) {
    return AuthResult._(true, message, user: user, sessionToken: sessionToken);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(false, error, error: error);
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message, user: ${user?.email})';
  }
}