# Estructura de Firestore para Autenticación

## Colección: `users`

### Estructura del Documento

Cada documento de usuario tendrá la siguiente estructura:

```json
{
  "id": "user_unique_id",
  "email": "usuario@ejemplo.com",
  "name": "Nombre",
  "lastName": "Apellido",
  "role": "admin" | "user",
  "passwordHash": "hash_encriptado_de_la_contraseña",
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLogin": "2024-01-15T15:45:00Z",
  "isActive": true,
  "profileImageUrl": "https://ejemplo.com/imagen.jpg",
  "sessionToken": "token_de_sesion_actual",
  "additionalData": {
    "preferences": {},
    "settings": {}
  }
}
```

### Campos Obligatorios

- **id**: Identificador único del usuario (generado automáticamente)
- **email**: Correo electrónico único del usuario
- **name**: Nombre del usuario
- **lastName**: Apellido del usuario
- **role**: Rol del usuario (`admin` o `user`)
- **passwordHash**: Hash de la contraseña (encriptada del lado del cliente)
- **createdAt**: Fecha de creación de la cuenta
- **isActive**: Estado de la cuenta (activa/inactiva)

### Campos Opcionales

- **lastLogin**: Última fecha de inicio de sesión
- **profileImageUrl**: URL de la imagen de perfil
- **sessionToken**: Token de sesión actual (para validación)
- **additionalData**: Datos adicionales del usuario

## Índices Recomendados

### Índices Simples

1. **email** (único): Para búsquedas rápidas por email
2. **role**: Para filtrar usuarios por rol
3. **isActive**: Para filtrar usuarios activos
4. **createdAt**: Para ordenar por fecha de creación

### Índices Compuestos

1. **role + isActive**: Para obtener usuarios activos por rol
2. **email + isActive**: Para validar usuarios activos por email

## Reglas de Seguridad de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para la colección users
    match /users/{userId} {
      // Permitir lectura solo al propio usuario o administradores
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      
      // Permitir escritura solo al propio usuario para campos específicos
      allow update: if request.auth != null && 
        request.auth.uid == userId &&
        !('role' in request.resource.data.diff(resource.data).affectedKeys()) &&
        !('passwordHash' in request.resource.data.diff(resource.data).affectedKeys());
      
      // Solo administradores pueden crear usuarios
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Solo administradores pueden eliminar usuarios
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Consideraciones de Seguridad

### Encriptación de Contraseñas

1. **Hash del lado del cliente**: Las contraseñas se hashean usando un algoritmo personalizado antes de enviarlas a Firestore
2. **Salt único**: Cada contraseña usa un salt único basado en el email del usuario
3. **Múltiples rondas**: El algoritmo aplica múltiples rondas de hash para mayor seguridad

### Gestión de Sesiones

1. **Tokens de sesión**: Se generan tokens únicos para cada sesión
2. **Validación de tokens**: Los tokens se validan en cada operación sensible
3. **Expiración automática**: Los tokens tienen un tiempo de vida limitado

### Roles y Permisos

#### Rol: `admin`
- Gestionar usuarios (crear, leer, actualizar, eliminar)
- Gestionar configuraciones del sistema
- Ver analíticas y reportes
- Exportar datos
- Leer/escribir/eliminar todos los datos

#### Rol: `user`
- Leer sus propios datos
- Actualizar su perfil (excepto rol y contraseña)
- Crear/editar/eliminar sus propios recordatorios
- Ver datos básicos del sistema

## Consultas Comunes

### Autenticación
```dart
// Buscar usuario por email
final user = await firestore
  .collection('users')
  .where('email', isEqualTo: email)
  .where('isActive', isEqualTo: true)
  .limit(1)
  .get();
```

### Gestión de Usuarios (Admin)
```dart
// Obtener todos los usuarios activos
final users = await firestore
  .collection('users')
  .where('isActive', isEqualTo: true)
  .orderBy('createdAt', descending: true)
  .get();

// Obtener usuarios por rol
final admins = await firestore
  .collection('users')
  .where('role', isEqualTo: 'admin')
  .where('isActive', isEqualTo: true)
  .get();
```

### Validación de Sesión
```dart
// Validar token de sesión
final user = await firestore
  .collection('users')
  .where('sessionToken', isEqualTo: token)
  .where('isActive', isEqualTo: true)
  .limit(1)
  .get();
```

## Migración y Mantenimiento

### Datos Iniciales

Se debe crear al menos un usuario administrador inicial:

```json
{
  "id": "admin_001",
  "email": "admin@enfermeria.com",
  "name": "Administrador",
  "lastName": "Sistema",
  "role": "admin",
  "passwordHash": "hash_de_contraseña_segura",
  "createdAt": "2024-01-01T00:00:00Z",
  "isActive": true,
  "additionalData": {
    "isSystemAdmin": true
  }
}
```

### Limpieza de Datos

1. **Tokens expirados**: Limpiar tokens de sesión antiguos periódicamente
2. **Usuarios inactivos**: Revisar y limpiar usuarios inactivos después de cierto tiempo
3. **Logs de acceso**: Mantener logs de acceso para auditoría

## Backup y Recuperación

1. **Backup automático**: Configurar backups automáticos de la colección users
2. **Exportación de datos**: Implementar funcionalidad para exportar datos de usuarios
3. **Recuperación de contraseñas**: Proceso seguro para resetear contraseñas (requiere validación adicional)