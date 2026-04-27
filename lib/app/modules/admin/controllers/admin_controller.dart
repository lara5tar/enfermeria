import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class AdminController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final AuthService authService = Get.find<AuthService>();
  
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'dashboard'.obs;
  
  // Estadísticas del dashboard
  final RxInt totalUsers = 0.obs;
  final RxInt totalAdmins = 0.obs;
  final RxInt activeUsers = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }
  
  void changeTab(String tab) {
    selectedTab.value = tab;
  }
  
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      await loadAllUsers();
      calculateStatistics();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar datos del dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadAllUsers() async {
    try {
      final users = await authService.getAllUsers();
      allUsers.value = users;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar usuarios: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void calculateStatistics() {
    totalUsers.value = allUsers.length;
    totalAdmins.value = allUsers.where((user) => user.role == UserRole.admin).length;
    activeUsers.value = allUsers.where((user) => user.isActive).length;
  }
  
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      isLoading.value = true;
      final result = await authService.updateUserRole(userId, newRole);
      if (result.isSuccess) {
        await loadAllUsers();
        calculateStatistics();
        
        Get.snackbar(
          'Éxito',
          'Rol de usuario actualizado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar rol: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      isLoading.value = true;
      // Por ahora comentamos esta funcionalidad hasta implementar el método
      // await authService.updateUserStatus(userId, isActive);
      await loadAllUsers();
      calculateStatistics();
      
      Get.snackbar(
        'Éxito',
        'Estado de usuario actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar estado: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      
      if (result == true) {
        isLoading.value = true;
        // Por ahora comentamos esta funcionalidad hasta implementar el método
        // await authService.deleteUser(userId);
        await loadAllUsers();
        calculateStatistics();
        
        Get.snackbar(
          'Éxito',
          'Usuario eliminado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar usuario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}