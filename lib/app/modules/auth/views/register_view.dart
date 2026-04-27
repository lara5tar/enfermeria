import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Título
              Column(
                children: [
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa los datos para crear tu cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Formulario de registro
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // Campo de nombre
                    TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ingresa tu nombre',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.cyan),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: controller.validateName,
                      onChanged: (value) => controller.clearErrors(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de apellido
                    TextFormField(
                      controller: controller.lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        hintText: 'Ingresa tu apellido',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.cyan),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: controller.validateLastName,
                      onChanged: (value) => controller.clearErrors(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de email
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.cyan),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: controller.validateEmail,
                      onChanged: (value) => controller.clearErrors(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de contraseña
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.cyan),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: controller.validatePassword,
                        onChanged: (value) => controller.clearErrors(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de confirmar contraseña
                    Obx(
                      () => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Repite tu contraseña',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmPassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.cyan),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: controller.validateConfirmPassword,
                        onChanged: (value) => controller.clearErrors(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Selector de rol (solo visible para administradores)
                    Obx(
                      () => controller.canSelectRole.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rol de usuario',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      RadioListTile<String>(
                                        title: const Text('Usuario Normal'),
                                        subtitle: const Text('Acceso básico a la aplicación'),
                                        value: 'user',
                                        groupValue: controller.selectedRole.value,
                                        onChanged: (value) => controller.selectedRole.value = value!,
                                        activeColor: Colors.cyan,
                                      ),
                                      RadioListTile<String>(
                                        title: const Text('Administrador'),
                                        subtitle: const Text('Acceso completo y gestión de usuarios'),
                                        value: 'admin',
                                        groupValue: controller.selectedRole.value,
                                        onChanged: (value) => controller.selectedRole.value = value!,
                                        activeColor: Colors.cyan,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    
                    // Términos y condiciones
                    Row(
                      children: [
                        Obx(
                          () => Checkbox(
                            value: controller.acceptTerms.value,
                            onChanged: (value) => controller.acceptTerms.value = value ?? false,
                            activeColor: Colors.cyan,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.acceptTerms.value = !controller.acceptTerms.value,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  const TextSpan(text: 'Acepto los '),
                                  TextSpan(
                                    text: 'Términos y Condiciones',
                                    style: const TextStyle(
                                      color: Colors.cyan,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' y la '),
                                  TextSpan(
                                    text: 'Política de Privacidad',
                                    style: const TextStyle(
                                      color: Colors.cyan,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de registro
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Link para ir al login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: controller.goToLogin,
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}