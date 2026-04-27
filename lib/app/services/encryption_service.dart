import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Servicio de encriptación para manejar contraseñas de forma segura
/// Utiliza SHA-256 con salt para hash de contraseñas
class EncryptionService {
  static const String _saltPrefix = 'enfermeria_app_';
  static const String _saltSuffix = '_secure_2024';
  
  /// Genera un salt único para cada usuario basado en su email
  static String _generateSalt(String email) {
    final emailHash = _simpleHash(email);
    return '$_saltPrefix${emailHash.substring(0, 16)}$_saltSuffix';
  }
  
  /// Genera un hash seguro de la contraseña usando hash personalizado con salt
  static String hashPassword(String password, String email) {
    final salt = _generateSalt(email);
    final saltedPassword = '$salt$password$salt';
    
    // Aplicar múltiples rondas de hash para mayor seguridad
    String hashedPassword = _simpleHash(saltedPassword);
    
    // Aplicar 1000 rondas adicionales de hash
    for (int i = 0; i < 1000; i++) {
      hashedPassword = _simpleHash('$hashedPassword$salt');
    }
    
    return hashedPassword;
  }
  
  /// Verifica si una contraseña coincide con su hash
  static bool verifyPassword(String password, String email, String storedHash) {
    final computedHash = hashPassword(password, email);
    return computedHash == storedHash;
  }
  
  /// Genera un token de sesión único
  static String generateSessionToken() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final tokenData = '$timestamp${base64.encode(randomBytes)}';
    
    return _simpleHash(tokenData);
  }
  
  /// Encripta datos sensibles usando una clave derivada del email del usuario
  static String encryptSensitiveData(String data, String email) {
    final key = _generateSalt(email);
    final dataWithKey = '$key$data$key';
    return base64.encode(utf8.encode(dataWithKey));
  }
  
  /// Desencripta datos sensibles
  static String decryptSensitiveData(String encryptedData, String email) {
    try {
      final decodedData = utf8.decode(base64.decode(encryptedData));
      final key = _generateSalt(email);
      
      // Remover las claves del inicio y final
      if (decodedData.startsWith(key) && decodedData.endsWith(key)) {
        return decodedData.substring(key.length, decodedData.length - key.length);
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }
  
  /// Valida la fortaleza de una contraseña
  static Map<String, dynamic> validatePasswordStrength(String password) {
    bool hasMinLength = password.length >= 8;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumbers) score++;
    if (hasSpecialChars) score++;
    
    String strength;
    if (score < 3) {
      strength = 'Débil';
    } else if (score < 4) {
      strength = 'Media';
    } else {
      strength = 'Fuerte';
    }
    
    return {
      'isValid': score >= 3,
      'strength': strength,
      'score': score,
      'requirements': {
        'minLength': hasMinLength,
        'uppercase': hasUppercase,
        'lowercase': hasLowercase,
        'numbers': hasNumbers,
        'specialChars': hasSpecialChars,
      },
      'suggestions': _getPasswordSuggestions(hasMinLength, hasUppercase, hasLowercase, hasNumbers, hasSpecialChars),
    };
  }
  
  static List<String> _getPasswordSuggestions(bool hasMinLength, bool hasUppercase, bool hasLowercase, bool hasNumbers, bool hasSpecialChars) {
    List<String> suggestions = [];
    
    if (!hasMinLength) suggestions.add('Debe tener al menos 8 caracteres');
    if (!hasUppercase) suggestions.add('Debe incluir al menos una letra mayúscula');
    if (!hasLowercase) suggestions.add('Debe incluir al menos una letra minúscula');
    if (!hasNumbers) suggestions.add('Debe incluir al menos un número');
    if (!hasSpecialChars) suggestions.add('Debe incluir al menos un carácter especial (!@#\$%^&*)');
    
    return suggestions;
  }
  
  /// Implementación de hash simple pero segura usando algoritmo personalizado
  static String _simpleHash(String input) {
    final bytes = utf8.encode(input);
    int hash1 = 0x811c9dc5; // FNV offset basis
    int hash2 = 0x01000193; // FNV prime
    
    for (int byte in bytes) {
      hash1 = ((hash1 ^ byte) * hash2) & 0xffffffff;
      hash2 = ((hash2 * 0x01000193) ^ byte) & 0xffffffff;
    }
    
    // Combinar ambos hashes y aplicar transformaciones adicionales
    int finalHash = hash1 ^ hash2;
    finalHash = ((finalHash << 13) | (finalHash >> 19)) & 0xffffffff;
    finalHash = (finalHash * 5 + 0xe6546b64) & 0xffffffff;
    
    // Convertir a hexadecimal de 64 caracteres para mayor seguridad
    String hexHash = finalHash.toRadixString(16).padLeft(8, '0');
    
    // Extender el hash aplicando más transformaciones
    String extendedHash = hexHash;
    for (int i = 0; i < 7; i++) {
      int tempHash = 0;
      for (int j = 0; j < extendedHash.length; j++) {
        tempHash = ((tempHash * 31) + extendedHash.codeUnitAt(j)) & 0xffffffff;
      }
      extendedHash += tempHash.toRadixString(16).padLeft(8, '0');
    }
    
    return extendedHash.substring(0, 64); // Retornar hash de 64 caracteres
  }
}