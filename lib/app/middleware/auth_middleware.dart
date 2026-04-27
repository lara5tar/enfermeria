import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../modules/auth/views/login_view.dart';

/// Middleware de autenticación que verifica si el usuario está logueado
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // Si el usuario no está logueado, redirigir al login
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }
    
    return null;
  }
}

/// Middleware de autorización que verifica permisos específicos
class RoleMiddleware extends GetMiddleware {
  final UserRole requiredRole;
  final List<String>? requiredPermissions;
  
  RoleMiddleware({
    required this.requiredRole,
    this.requiredPermissions,
  });

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // Verificar si el usuario está logueado
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }
    
    final user = authController.currentUser.value;
    if (user == null) {
      return const RouteSettings(name: '/login');
    }
    
    // Verificar rol requerido
    if (!_hasRequiredRole(user.role)) {
      _showUnauthorizedDialog();
      return const RouteSettings(name: '/unauthorized');
    }
    
    // Verificar permisos específicos si se proporcionaron
    if (requiredPermissions != null && !_hasRequiredPermissions(user.permissions)) {
      _showUnauthorizedDialog();
      return const RouteSettings(name: '/unauthorized');
    }
    
    return null;
  }
  
  bool _hasRequiredRole(UserRole userRole) {
    switch (requiredRole) {
      case UserRole.admin:
        return userRole == UserRole.admin;
      case UserRole.user:
        return userRole == UserRole.user || userRole == UserRole.admin;
    }
  }
  
  bool _hasRequiredPermissions(UserPermissions permissions) {
    if (requiredPermissions == null) return true;
    
    for (String permission in requiredPermissions!) {
      switch (permission) {
        case 'canRead':
          if (!permissions.canRead) return false;
          break;
        case 'canWrite':
          if (!permissions.canWrite) return false;
          break;
        case 'canDelete':
          if (!permissions.canDelete) return false;
          break;
        case 'canManageUsers':
          if (!permissions.canManageUsers) return false;
          break;
        case 'canManageSettings':
          if (!permissions.canManageSettings) return false;
          break;
        case 'canViewAnalytics':
          if (!permissions.canViewAnalytics) return false;
          break;
        case 'canExportData':
          if (!permissions.canExportData) return false;
          break;
      }
    }
    
    return true;
  }
  
  void _showUnauthorizedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Acceso Denegado'),
        content: const Text(
          'No tienes permisos suficientes para acceder a esta sección. '
          'Contacta al administrador si crees que esto es un error.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo
              Get.back(); // Volver a la pantalla anterior
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// Middleware específico para administradores
class AdminMiddleware extends RoleMiddleware {
  AdminMiddleware() : super(requiredRole: UserRole.admin);
}

/// Middleware para funciones que requieren permisos de escritura
class WritePermissionMiddleware extends RoleMiddleware {
  WritePermissionMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canWrite'],
  );
}

/// Middleware para funciones que requieren permisos de eliminación
class DeletePermissionMiddleware extends RoleMiddleware {
  DeletePermissionMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canDelete'],
  );
}

/// Middleware para gestión de usuarios
class UserManagementMiddleware extends RoleMiddleware {
  UserManagementMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canManageUsers'],
  );
}

/// Middleware para configuraciones del sistema
class SettingsMiddleware extends RoleMiddleware {
  SettingsMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canManageSettings'],
  );
}

/// Middleware para analytics y reportes
class AnalyticsMiddleware extends RoleMiddleware {
  AnalyticsMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canViewAnalytics'],
  );
}

/// Middleware para exportación de datos
class ExportMiddleware extends RoleMiddleware {
  ExportMiddleware() : super(
    requiredRole: UserRole.user,
    requiredPermissions: ['canExportData'],
  );
}

/// Utilidad para verificar permisos en widgets
class PermissionChecker {
  static final AuthController _authController = Get.find<AuthController>();
  
  /// Verifica si el usuario actual tiene un rol específico
  static bool hasRole(UserRole role) {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    
    switch (role) {
      case UserRole.admin:
        return user.role == UserRole.admin;
      case UserRole.user:
        return user.role == UserRole.user || user.role == UserRole.admin;
    }
  }
  
  /// Verifica si el usuario actual tiene un permiso específico
  static bool hasPermission(String permission) {
    final user = _authController.currentUser.value;
    if (user == null) return false;
    
    switch (permission) {
      case 'canRead':
        return user.permissions.canRead;
      case 'canWrite':
        return user.permissions.canWrite;
      case 'canDelete':
        return user.permissions.canDelete;
      case 'canManageUsers':
        return user.permissions.canManageUsers;
      case 'canManageSettings':
        return user.permissions.canManageSettings;
      case 'canViewAnalytics':
        return user.permissions.canViewAnalytics;
      case 'canExportData':
        return user.permissions.canExportData;
      default:
        return false;
    }
  }
  
  /// Verifica si el usuario es administrador
  static bool get isAdmin => hasRole(UserRole.admin);
  
  /// Verifica si el usuario puede gestionar otros usuarios
  static bool get canManageUsers => hasPermission('canManageUsers');
  
  /// Verifica si el usuario puede ver analytics
  static bool get canViewAnalytics => hasPermission('canViewAnalytics');
  
  /// Verifica si el usuario puede exportar datos
  static bool get canExportData => hasPermission('canExportData');
}

/// Widget que muestra contenido basado en permisos
class PermissionWidget extends StatelessWidget {
  final UserRole? requiredRole;
  final String? requiredPermission;
  final Widget child;
  final Widget? fallback;
  
  const PermissionWidget({
    super.key,
    this.requiredRole,
    this.requiredPermission,
    required this.child,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    bool hasAccess = true;
    
    if (requiredRole != null) {
      hasAccess = hasAccess && PermissionChecker.hasRole(requiredRole!);
    }
    
    if (requiredPermission != null) {
      hasAccess = hasAccess && PermissionChecker.hasPermission(requiredPermission!);
    }
    
    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}