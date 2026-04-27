import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../views/register_view.dart';
import '../views/forgot_password_view.dart';
import '../../../models/user_model.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  
  // Controladores de formulario
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Estados observables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final hasErrors = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  /// Valida el campo de email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }
  
  /// Valida el campo de contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
  
  /// Limpia los errores del formulario
  void clearErrors() {
    hasErrors.value = false;
  }
  
  /// Alterna la visibilidad de la contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  /// Realiza el proceso de login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      hasErrors.value = true;
      return;
    }
    
    isLoading.value = true;
    hasErrors.value = false;
    
    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      // Si el login fue exitoso, navegar a la pantalla principal
      if (authController.isLoggedIn.value) {
        Get.offAllNamed('/home'); // o la ruta principal de tu app
      }
    } catch (e) {
      hasErrors.value = true;
      Get.snackbar(
        'Error',
        'Error inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Navega a la pantalla de registro
  void goToRegister() {
    Get.to(() => const RegisterView());
  }
  
  void goToForgotPassword() {
    Get.to(() => const ForgotPasswordView());
  }
  
  /// Muestra el diálogo de recuperación de contraseña
  void showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo electrónico para recibir instrucciones de recuperación.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Get.back();
                _sendPasswordResetEmail(emailController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
  
  /// Simula el envío de email de recuperación
  void _sendPasswordResetEmail(String email) {
    Get.snackbar(
      'Email Enviado',
      'Se han enviado las instrucciones de recuperación a $email',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      duration: const Duration(seconds: 4),
    );
  }
  
  /// Muestra los términos y condiciones
  void showTermsAndConditions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Términos y Condiciones de Uso\n\n'
            '1. Aceptación de los términos\n'
            'Al utilizar esta aplicación, aceptas cumplir con estos términos y condiciones.\n\n'
            '2. Uso de la aplicación\n'
            'Esta aplicación está diseñada para uso profesional en el ámbito de la enfermería.\n\n'
            '3. Privacidad\n'
            'Nos comprometemos a proteger tu información personal de acuerdo con nuestra política de privacidad.\n\n'
            '4. Responsabilidades\n'
            'El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso.\n\n'
            '5. Modificaciones\n'
            'Nos reservamos el derecho de modificar estos términos en cualquier momento.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra la política de privacidad
  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Política de Privacidad\n\n'
            '1. Información que recopilamos\n'
            'Recopilamos información necesaria para el funcionamiento de la aplicación, incluyendo datos de contacto y preferencias de usuario.\n\n'
            '2. Uso de la información\n'
            'Utilizamos tu información para proporcionar y mejorar nuestros servicios.\n\n'
            '3. Protección de datos\n'
            'Implementamos medidas de seguridad para proteger tu información personal.\n\n'
            '4. Compartir información\n'
            'No compartimos tu información personal con terceros sin tu consentimiento.\n\n'
            '5. Derechos del usuario\n'
            'Tienes derecho a acceder, corregir o eliminar tu información personal.\n\n'
            '6. Contacto\n'
            'Si tienes preguntas sobre esta política, puedes contactarnos a través de la aplicación.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}