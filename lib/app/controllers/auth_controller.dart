import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService(projectId: 'enfermeria-cafe9');
  
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();
  final sessionToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  /// Verifica si existe una sesión activa
  Future<void> _checkExistingSession() async {
    final token = sessionToken.value;
    if (token.isNotEmpty) {
      final isValid = await _authService.validateSession(token);
      if (isValid == true) {
        isLoggedIn.value = true;
      } else {
        await logout();
      }
    }
  }

  /// Inicia sesión con email y contraseña
  Future<void> login(String email, String password) async {
    print('🎮 [CONTROLLER] Iniciando login desde controlador');
    print('📧 [CONTROLLER] Email: $email');
    print('🔐 [CONTROLLER] Password: $password');
    
    if (email.isEmpty || password.isEmpty) {
      print('❌ [CONTROLLER] Email o contraseña vacíos');
      Get.snackbar(
        'Error',
        'Por favor ingresa email y contraseña válidos',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    print('⏳ [CONTROLLER] Estado de carga activado');
    
    try {
      print('🔄 [CONTROLLER] Llamando al servicio de autenticación...');
      final result = await _authService.login(email: email, password: password);
      
      print('📋 [CONTROLLER] Resultado del servicio:');
      print('   - isSuccess: ${result.isSuccess}');
      print('   - message: ${result.message}');
      print('   - user: ${result.user?.name} ${result.user?.lastName}');
      print('   - sessionToken: ${result.sessionToken}');
      
      if (result.isSuccess) {
        print('✅ [CONTROLLER] Login exitoso, actualizando estado...');
        isLoggedIn.value = true;
        currentUser.value = result.user;
        sessionToken.value = result.sessionToken ?? '';
        
        print('🎉 [CONTROLLER] Estado actualizado correctamente');
        print('   - isLoggedIn: ${isLoggedIn.value}');
        print('   - currentUser: ${currentUser.value?.name}');
        print('   - sessionToken: ${sessionToken.value}');
        
        Get.snackbar(
          'Login exitoso',
          'Bienvenido ${result.user?.name ?? email}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('❌ [CONTROLLER] Login fallido: ${result.message}');
        Get.snackbar(
          'Error de autenticación',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('💥 [CONTROLLER] Error inesperado: $e');
      Get.snackbar(
        'Error',
        'Error inesperado durante el login: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print('✅ [CONTROLLER] Estado de carga desactivado');
    }
  }

  /// Registra un nuevo usuario
  Future<void> register(String email, String password, String name, {UserRole role = UserRole.user}) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son obligatorios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      final result = await _authService.registerUser(email: email, password: password, name: name, lastName: '', role: role);
      
      if (result.isSuccess) {
        Get.snackbar(
          'Registro exitoso',
          'Usuario creado correctamente. Puedes iniciar sesión ahora.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error de registro',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado durante el registro: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cierra la sesión actual
  Future<void> logout() async {
    try {
      if (sessionToken.value.isNotEmpty) {
        await _authService.logout(sessionToken.value);
      }
    } catch (e) {
      // Continuar con el logout local aunque falle el remoto
    }
    
    isLoggedIn.value = false;
    currentUser.value = null;
    sessionToken.value = '';

    Get.snackbar(
      'Sesión cerrada',
      'Has cerrado sesión exitosamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Cambia la contraseña del usuario actual
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (currentUser.value == null) {
      Get.snackbar(
        'Error',
        'No hay usuario autenticado',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      final result = await _authService.changePassword(
        userId: currentUser.value!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result.isSuccess) {
        Get.snackbar(
          'Contraseña actualizada',
          'Tu contraseña ha sido cambiada exitosamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado al cambiar contraseña: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getters de conveniencia
  bool get canSaveReminders => isLoggedIn.value;
  String get userEmail => currentUser.value?.email ?? '';
  String get userName => currentUser.value?.name ?? '';
  UserRole get userRole => currentUser.value?.role ?? UserRole.user;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get canManageUsers => currentUser.value?.permissions.canManageUsers ?? false;
  bool get canViewReports => currentUser.value?.permissions.canViewAnalytics ?? false;
  bool get canManageSettings => currentUser.value?.permissions.canManageSettings ?? false;
}
