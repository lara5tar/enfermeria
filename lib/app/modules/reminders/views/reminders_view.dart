import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reminders_controller.dart';
import '../../../widgets/custom_bottom_navigation_bar.dart';

class RemindersView extends GetView<RemindersController> {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        centerTitle: true,
        actions: [
          Obx(
            () =>
                controller.authController.isLoggedIn.value
                    ? Icon(Icons.cloud, color: Colors.green)
                    : Icon(Icons.cloud_off, color: Colors.orange),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado de login
          Obx(
            () =>
                !controller.authController.isLoggedIn.value
                    ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Inicia sesión en Configuración para guardar recordatorios',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(),
          ),

          // Lista de recordatorios
          Expanded(
            child: Obx(
              () =>
                  controller.reminders.isEmpty
                      ? const Center(
                        child: Text(
                          'No hay recordatorios\nToca + para agregar uno',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: controller.reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = controller.reminders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Icon(
                                reminder['isCompleted']
                                    ? Icons.check_circle
                                    : Icons.notifications,
                                color:
                                    reminder['isCompleted']
                                        ? Colors.green
                                        : Colors.cyan,
                              ),
                              title: Text(
                                reminder['title'],
                                style: TextStyle(
                                  decoration:
                                      reminder['isCompleted']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reminder['description']),
                                  Text(
                                    '${reminder['dateTime'].day}/${reminder['dateTime'].month} - ${reminder['dateTime'].hour}:${reminder['dateTime'].minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      reminder['isCompleted']
                                          ? Icons.undo
                                          : Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed:
                                        () => controller.toggleReminder(
                                          reminder['id'],
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => controller.deleteReminder(
                                          reminder['id'],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Nuevo Recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (titleController.text.isNotEmpty) {
                controller.addReminder(
                  titleController.text,
                  descriptionController.text,
                  DateTime.now().add(const Duration(hours: 1)),
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
