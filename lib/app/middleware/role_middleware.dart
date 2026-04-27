import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

/// Middleware para verificar roles de usuario antes de acceder a rutas protegidas
class RoleMiddleware extends GetMiddleware {
  final UserRole requiredRole;
  
  RoleMiddleware({required this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // Verificar si el usuario está autenticado
    if (!authController.isLoggedIn.value) {
      // Redirigir al login si no está autenticado
      return const RouteSettings(name: '/login');
    }
    
    // Verificar si el usuario tiene el rol requerido
    final currentUser = authController.currentUser.value;
    if (currentUser == null || currentUser.role != requiredRole) {
      // Mostrar mensaje de acceso denegado
      Get.snackbar(
        'Acceso Denegado',
        'No tienes permisos para acceder a esta sección.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(
          Icons.block,
          color: Colors.red,
        ),
        duration: const Duration(seconds: 3),
      );
      
      // Redirigir a la página de inicio
      return const RouteSettings(name: '/home');
    }
    
    // Si todo está bien, permitir el acceso
    return null;
  }
  
  @override
  int? get priority => 1;
}