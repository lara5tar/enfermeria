import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar controladores globales
  Get.put(ThemeController());
  Get.put(AuthController());

  // Inicializar AuthService y crear admin por defecto
  await _initializeApp();

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: Get.find<ThemeController>().lightTheme,
      darkTheme: Get.find<ThemeController>().darkTheme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.noTransition,
    ),
  );
}

/// Inicializa la aplicación y crea el usuario administrador por defecto
Future<void> _initializeApp() async {
  try {
    // Inicializar AuthService con el ID del proyecto
    final authService = AuthService(projectId: 'enfermeria-cafe9');
    
    // Crear usuario administrador por defecto
    final result = await authService.createDefaultAdmin();
    
    if (result.isSuccess) {
      print('✅ ${result.message}');
    } else {
      print('⚠️ Error al crear admin: ${result.message}');
    }
  } catch (e) {
    print('❌ Error durante la inicialización: $e');
  }
}
