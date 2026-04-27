import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/unauthorized_view.dart';
import '../modules/auth/controllers/login_controller.dart';
import '../modules/auth/controllers/register_controller.dart';
import '../modules/auth/controllers/forgot_password_controller.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/reminders/bindings/reminders_binding.dart';
import '../modules/reminders/views/reminders_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_panel_view.dart';
import '../models/user_model.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    // Rutas de autenticación (sin middleware)
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: _Paths.UNAUTHORIZED,
      page: () => const UnauthorizedView(),
    ),
    
    // Rutas principales (accesibles sin login)
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.REMINDERS,
      page: () => const RemindersView(),
      binding: RemindersBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    
    // Rutas de administración (solo para admins)
    GetPage(
      name: _Paths.ADMIN_PANEL,
      page: () => const AdminPanelView(),
      binding: AdminBinding(),
      middlewares: [
        RoleMiddleware(
          requiredRole: UserRole.admin,
        ),
      ],
    ),
  ];
}
