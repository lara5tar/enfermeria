import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class RemindersController extends GetxController {
  final reminders = <Map<String, dynamic>>[].obs;

  // Obtener referencia al controlador de autenticación
  AuthController get authController => Get.find<AuthController>();

  void addReminder(String title, String description, DateTime dateTime) {
    if (!authController.canSaveReminders) {
      Get.snackbar(
        'Login requerido',
        'Debes iniciar sesión para guardar recordatorios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    reminders.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'isCompleted': false,
    });

    Get.snackbar(
      'Recordatorio agregado',
      'Se ha guardado exitosamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleReminder(int id) {
    if (!authController.canSaveReminders) {
      Get.snackbar(
        'Login requerido',
        'Debes iniciar sesión para modificar recordatorios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final index = reminders.indexWhere((reminder) => reminder['id'] == id);
    if (index != -1) {
      reminders[index]['isCompleted'] = !reminders[index]['isCompleted'];
      reminders.refresh();
    }
  }

  void deleteReminder(int id) {
    if (!authController.canSaveReminders) {
      Get.snackbar(
        'Login requerido',
        'Debes iniciar sesión para eliminar recordatorios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    reminders.removeWhere((reminder) => reminder['id'] == id);
  }
}
