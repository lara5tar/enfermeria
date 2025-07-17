import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/search');
        break;
      case 2:
        Get.offNamed('/reminders');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
      case 4:
        Get.offNamed('/settings');
        break;
    }
  }
}
