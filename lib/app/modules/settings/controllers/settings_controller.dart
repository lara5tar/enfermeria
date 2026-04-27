import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/auth_controller.dart';

class SettingsController extends GetxController {
  // Configuraciones de la app
  final isNotificationsEnabled = true.obs;
  final isLocationEnabled = false.obs;
  final selectedLanguage = 'Español'.obs;
  final fontSize = 14.0.obs;

  final languages = ['Español', 'English', 'Français'].obs;

  // Obtener referencias a controladores globales
  ThemeController get themeController => Get.find<ThemeController>();
  AuthController get authController => Get.find<AuthController>();

  void toggleDarkMode() {
    themeController.toggleTheme();
  }

  void toggleNotifications() {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
  }

  void toggleLocation() {
    isLocationEnabled.value = !isLocationEnabled.value;
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }

  void changeFontSize(double size) {
    fontSize.value = size;
  }

  void saveSettings() {
    Get.snackbar(
      'Configuración guardada',
      'Los cambios han sido aplicados exitosamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Iniciar Sesión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/register');
            },
            child: const Text('Crear cuenta'),
          ),
          ElevatedButton(
            onPressed: () {
              authController.login(
                emailController.text,
                passwordController.text,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
