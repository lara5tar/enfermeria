import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class ForgotPasswordController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Controladores de formulario
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  
  // Estados observables
  final isLoading = false.obs;
  final emailSent = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
  
  // Validaciones
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }
  
  void clearErrors() {
    // Limpiar errores del formulario si es necesario
  }
  
  // Navegación
  void goToLogin() {
    Get.back();
  }
  
  // Enviar email de recuperación
  Future<void> sendResetEmail() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      emailSent.value = false;
      
      // Simular envío de email (aquí iría la lógica real)
      await Future.delayed(const Duration(seconds: 2));
      
      // En una implementación real, aquí llamarías al servicio de autenticación
      // await _authController.sendPasswordResetEmail(emailController.text.trim());
      
      emailSent.value = true;
      
      Get.snackbar(
        'Email enviado',
        'Se han enviado las instrucciones a tu correo electrónico',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 4),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al enviar el correo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Reenviar email
  Future<void> resendEmail() async {
    if (emailController.text.trim().isNotEmpty) {
      await sendResetEmail();
    }
  }
}