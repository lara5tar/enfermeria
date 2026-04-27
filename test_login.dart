import 'dart:io';
import 'lib/app/services/encryption_service.dart';

void main() async {
  print('🧪 [TEST] Probando la contraseña correcta del admin...');
  
  final email = 'admin@enfermeria.com';
  final storedHash = 'ecc7fffa1d0659cd1d6d85ebf6b44f46e224e59cb84f9d459cd97099855d44f1';
  final correctPassword = 'Admin123!'; // Contraseña encontrada en auth_service.dart línea 425
  
  print('📧 [TEST] Email: $email');
  print('🔑 [TEST] Hash almacenado: $storedHash');
  print('🔐 [TEST] Contraseña a probar: $correctPassword');
  print('');
  
  final generatedHash = EncryptionService.hashPassword(correctPassword, email);
  final matches = generatedHash == storedHash;
  
  print('🔑 [TEST] Hash generado: $generatedHash');
  print('✅ [TEST] ¿Coincide? $matches');
  
  if (matches) {
    print('🎉 [TEST] ¡CONTRASEÑA CORRECTA! El admin puede iniciar sesión con: "$correctPassword"');
    
    // Probar también la verificación de contraseña
    final isValid = EncryptionService.verifyPassword(correctPassword, storedHash, email);
    print('🔍 [TEST] Verificación con verifyPassword: $isValid');
  } else {
    print('❌ [TEST] La contraseña "$correctPassword" no coincide.');
    print('💡 [TEST] Puede que haya un problema con el algoritmo de hash.');
  }
  
  print('✅ [TEST] Prueba completada');
}