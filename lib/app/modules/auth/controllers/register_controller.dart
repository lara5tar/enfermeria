import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Controladores de formulario
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Estados observables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final acceptTerms = false.obs;
  final selectedRole = 'user'.obs;
  final canSelectRole = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Verificar si el usuario actual puede asignar roles (es admin)
    _checkRolePermissions();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void _checkRolePermissions() {
    // Solo los administradores pueden crear otros administradores
    canSelectRole.value = _authController.isLoggedIn.value && 
                         _authController.currentUser.value?.permissions.canManageUsers == true;
  }
  
  // Validaciones
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }
  
  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El apellido es requerido';
    }
    if (value.trim().length < 2) {
      return 'El apellido debe tener al menos 2 caracteres';
    }
    return null;
  }
  
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
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
  
  // Métodos de UI
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }
  
  void clearErrors() {
    // Limpiar errores del formulario si es necesario
  }
  
  // Navegación
  void goToLogin() {
    Get.back();
  }
  
  void showTermsAndConditions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Términos y Condiciones de Uso\n\n'
            '1. Aceptación de los términos\n'
            'Al utilizar esta aplicación, usted acepta estar sujeto a estos términos y condiciones.\n\n'
            '2. Uso de la aplicación\n'
            'Esta aplicación está destinada para uso profesional en el ámbito de enfermería.\n\n'
            '3. Privacidad\n'
            'Nos comprometemos a proteger su información personal de acuerdo con nuestra política de privacidad.\n\n'
            '4. Responsabilidades del usuario\n'
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
  
  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Política de Privacidad\n\n'
            '1. Información que recopilamos\n'
            'Recopilamos información necesaria para el funcionamiento de la aplicación.\n\n'
            '2. Uso de la información\n'
            'La información se utiliza únicamente para los propósitos de la aplicación.\n\n'
            '3. Protección de datos\n'
            'Implementamos medidas de seguridad para proteger su información.\n\n'
            '4. Compartir información\n'
            'No compartimos su información personal con terceros sin su consentimiento.\n\n'
            '5. Sus derechos\n'
            'Usted tiene derecho a acceder, corregir o eliminar su información personal.',
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
  
  // Registro de usuario
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (!acceptTerms.value) {
      Get.snackbar(
        'Error',
        'Debes aceptar los términos y condiciones',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      await _authController.register(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );
      
      Get.snackbar(
        'Éxito',
        'Cuenta creada exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      
      // Regresar a la pantalla de login
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }
}