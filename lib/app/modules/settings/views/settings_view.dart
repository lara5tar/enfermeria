import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../../../widgets/custom_bottom_navigation_bar.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_pages.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección Cuenta
          _buildSectionHeader('Cuenta'),
          Card(
            child: Obx(
              () => controller.authController.isLoggedIn.value
                      ? Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.cyan.shade100,
                              child: Icon(
                                Icons.person,
                                color: Colors.cyan,
                              ),
                            ),
                            title: Text(
                              controller.authController.userName,
                            ),
                            subtitle: Text(
                              controller.authController.userEmail,
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Cerrar sesión'),
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: controller.logout,
                          ),
                        ],
                      )
                      : ListTile(
                        title: const Text('Iniciar sesión'),
                        subtitle: const Text(
                          'Inicia sesión para guardar recordatorios',
                        ),
                        leading: const Icon(Icons.login, color: Colors.cyan),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: controller.showLoginDialog,
                      ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección Apariencia
          _buildSectionHeader('Apariencia'),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    title: const Text('Modo oscuro'),
                    subtitle: const Text('Cambiar al tema oscuro'),
                    value: controller.themeController.isDarkMode.value,
                    onChanged: (_) => controller.toggleDarkMode(),
                    secondary: const Icon(Icons.dark_mode),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Tamaño de fuente'),
                  subtitle: Obx(
                    () => Text('${controller.fontSize.value.toInt()}px'),
                  ),
                  leading: const Icon(Icons.font_download),
                  trailing: SizedBox(
                    width: 150,
                    child: Obx(
                      () => Slider(
                        value: controller.fontSize.value,
                        min: 12.0,
                        max: 20.0,
                        divisions: 8,
                        onChanged: controller.changeFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección Notificaciones
          _buildSectionHeader('Notificaciones'),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    title: const Text('Notificaciones push'),
                    subtitle: const Text('Recibir alertas y recordatorios'),
                    value: controller.isNotificationsEnabled.value,
                    onChanged: (_) => controller.toggleNotifications(),
                    secondary: const Icon(Icons.notifications),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: const Text('Ubicación'),
                    subtitle: const Text('Permitir acceso a la ubicación'),
                    value: controller.isLocationEnabled.value,
                    onChanged: (_) => controller.toggleLocation(),
                    secondary: const Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección Idioma
          _buildSectionHeader('Idioma'),
          Card(
            child: Obx(
              () => ListTile(
                title: const Text('Idioma de la aplicación'),
                subtitle: Text(controller.selectedLanguage.value),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageDialog(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección Administración (solo para admins)
          Obx(() {
            if (controller.authController.isLoggedIn.value &&
                controller.authController.currentUser.value?.role == UserRole.admin) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Administración'),
                  Card(
                    child: ListTile(
                      title: const Text('Panel de Administración'),
                      subtitle: const Text('Gestionar usuarios y configuraciones'),
                      leading: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.orange,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/admin-panel'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Sección Sobre la app
          _buildSectionHeader('Información'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Acerca de'),
                  subtitle: const Text('Versión 1.0.0'),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Mostrar información de la app
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacidad'),
                  subtitle: const Text('Política de privacidad'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Mostrar política de privacidad
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Soporte'),
                  subtitle: const Text('Contactar soporte técnico'),
                  leading: const Icon(Icons.support),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Contactar soporte
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón para guardar cambios
          ElevatedButton(
            onPressed: controller.saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Guardar Configuración'),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              controller.languages.map((language) {
                return Obx(
                  () => ListTile(
                    title: Text(language),
                    leading: Radio<String>(
                      value: language,
                      groupValue: controller.selectedLanguage.value,
                      onChanged: (value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                          Get.back();
                        }
                      },
                    ),
                    onTap: () {
                      controller.changeLanguage(language);
                      Get.back();
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
