import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../widgets/custom_bottom_navigation_bar.dart';
import '../../../models/user_model.dart';

class AdminPanelView extends GetView<AdminController> {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs de navegación
                    _buildTabNavigation(),
                    const SizedBox(height: 20),
                    
                    // Contenido según tab seleccionado
                    _buildTabContent(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'dashboard',
              'Dashboard',
              Icons.dashboard,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'users',
              'Usuarios',
              Icons.people,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'settings',
              'Config',
              Icons.settings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, IconData icon) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.changeTab(tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: controller.selectedTab.value == tabId
                ? Colors.red.shade600
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: controller.selectedTab.value == tabId
                    ? Colors.white
                    : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: controller.selectedTab.value == tabId
                      ? Colors.white
                      : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 'dashboard':
          return _buildDashboard();
        case 'users':
          return _buildUsersManagement();
        case 'settings':
          return _buildAdminSettings();
        default:
          return _buildDashboard();
      }
    });
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas del Sistema',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Tarjetas de estadísticas
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Usuarios Totales',
                controller.totalUsers.value.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Administradores',
                controller.totalAdmins.value.toString(),
                Icons.admin_panel_settings,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Usuarios Activos',
                controller.activeUsers.value.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sistema',
                'Operativo',
                Icons.health_and_safety,
                Colors.orange,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Acciones rápidas
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Gestionar Usuarios',
                Icons.people_alt,
                Colors.blue,
                () => controller.changeTab('users'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Configuraciones',
                Icons.settings,
                Colors.purple,
                () => controller.changeTab('settings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Recargar Datos',
                Icons.refresh,
                Colors.green,
                () => controller.loadDashboardData(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ver Logs',
                Icons.list_alt,
                Colors.orange,
                () => Get.snackbar(
                  'Próximamente',
                  'Funcionalidad en desarrollo',
                  snackPosition: SnackPosition.BOTTOM,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => controller.loadAllUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Lista de usuarios
        Obx(
          () => controller.allUsers.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No hay usuarios registrados',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.allUsers[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.role == UserRole.admin
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  child: Icon(
                    user.role == UserRole.admin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: user.role == UserRole.admin
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == UserRole.admin
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: user.role == UserRole.admin
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showUserActionsDialog(user),
                  child: const Text('Acciones'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserActionsDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: Text('Acciones para ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Cambiar Rol'),
              onTap: () {
                Get.back();
                _showChangeRoleDialog(user);
              },
            ),
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
              ),
              title: Text(
                user.isActive ? 'Desactivar' : 'Activar',
              ),
              onTap: () {
                Get.back();
                controller.toggleUserStatus(user.id, !user.isActive);
              },
            ),
            if (user.role != UserRole.admin)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Eliminar Usuario',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  controller.deleteUser(user.id);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cambiar Rol de Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Usuario: ${user.fullName}'),
            Text('Rol actual: ${user.role.displayName}'),
            const SizedBox(height: 16),
            const Text('Seleccionar nuevo rol:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          if (user.role != UserRole.admin)
            TextButton(
              onPressed: () {
                Get.back();
                controller.updateUserRole(user.id, UserRole.admin);
              },
              child: const Text('Hacer Admin'),
            ),
          if (user.role != UserRole.user)
            TextButton(
              onPressed: () {
                Get.back();
                controller.updateUserRole(user.id, UserRole.user);
              },
              child: const Text('Hacer Usuario'),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuraciones de Administrador',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Configuraciones del sistema
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Configuración de Seguridad'),
                subtitle: const Text('Gestionar políticas de seguridad'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.snackbar(
                    'Próximamente',
                    'Funcionalidad en desarrollo',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Respaldo de Datos'),
                subtitle: const Text('Crear y gestionar respaldos'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.snackbar(
                    'Próximamente',
                    'Funcionalidad en desarrollo',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Análisis y Reportes'),
                subtitle: const Text('Ver estadísticas detalladas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.snackbar(
                    'Próximamente',
                    'Funcionalidad en desarrollo',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificaciones del Sistema'),
                subtitle: const Text('Configurar alertas administrativas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.snackbar(
                    'Próximamente',
                    'Funcionalidad en desarrollo',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Información del sistema
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Sistema',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Versión', '1.0.0'),
                _buildInfoRow('Base de Datos', 'Firestore'),
                _buildInfoRow('Estado', 'Operativo'),
                _buildInfoRow('Último Respaldo', 'No disponible'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}