import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;
  final userName = ''.obs;

  void login(String email, String password) {
    // Aquí puedes agregar la lógica de autenticación real
    // Por ahora simularemos un login exitoso
    if (email.isNotEmpty && password.isNotEmpty) {
      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = email.split('@')[0]; // Usar parte del email como nombre

      Get.snackbar(
        'Login exitoso',
        'Bienvenido ${userName.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Por favor ingresa email y contraseña válidos',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';

    Get.snackbar(
      'Sesión cerrada',
      'Has cerrado sesión exitosamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool get canSaveReminders => isLoggedIn.value;
}
