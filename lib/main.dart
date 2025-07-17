import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/auth_controller.dart';

void main() {
  // Inicializar controladores globales
  Get.put(ThemeController());
  Get.put(AuthController());

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: Get.find<ThemeController>().lightTheme,
      darkTheme: Get.find<ThemeController>().darkTheme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.noTransition,
    ),
  );
}
