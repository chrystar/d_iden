import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class SecurityService {
  static const String _encryptionKeyName = 'encryption_key';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  
  SecurityService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _localAuth = localAuth ?? LocalAuthentication();
       
  // Initialize the security service
  Future<void> initialize() async {
    // Check if encryption key exists, if not, create one
    final hasKey = await _secureStorage.containsKey(key: _encryptionKeyName);
    if (!hasKey) {
      // Generate a random key for encryption
      final key = _generateRandomKey(32); // 256 bit key
      await _secureStorage.write(key: _encryptionKeyName, value: base64Encode(key));
    }
  }
  
  // Get available biometric authentication methods
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }
  
  // Check if device supports biometric authentication
  Future<bool> isBiometricsAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics && 
             await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }
  
  // Check if biometric authentication is enabled by the user
  Future<bool> isBiometricsEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricsEnabledKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }
  
  // Enable or disable biometric authentication
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricsEnabledKey, 
      value: enabled.toString(),
    );
  }
  
  // Authenticate user using biometrics
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Authenticate to access secure data',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isEnabled = await isBiometricsEnabled();
      if (!isEnabled) {
        return true; // Skip if not enabled
      }
      
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) {
        return false;
      }
      
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // Handle specific error codes
        return false;
      }
      return false;
    }
  }
  
  // Encrypt data
  Future<String> encryptData(String data) async {
    try {
      final keyString = await _secureStorage.read(key: _encryptionKeyName);
      if (keyString == null) {
        throw Exception('Encryption key not found');
      }
      
      final keyBytes = base64Decode(keyString);
      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV.fromLength(16);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(data, iv: iv);
      
      // Return IV + encrypted data in base64
      return '${base64Encode(iv.bytes)}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Failed to encrypt data: ${e.toString()}');
    }
  }
  
  // Decrypt data
  Future<String> decryptData(String encryptedData) async {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }
      
      final iv = encrypt.IV(base64Decode(parts[0]));
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      final keyString = await _secureStorage.read(key: _encryptionKeyName);
      if (keyString == null) {
        throw Exception('Encryption key not found');
      }
      
      final keyBytes = base64Decode(keyString);
      final key = encrypt.Key(keyBytes);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Failed to decrypt data: ${e.toString()}');
    }
  }
  
  // Securely store data
  Future<void> secureWrite({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  // Retrieve securely stored data
  Future<String?> secureRead({required String key}) async {
    return await _secureStorage.read(key: key);
  }
  
  // Delete securely stored data
  Future<void> secureDelete({required String key}) async {
    await _secureStorage.delete(key: key);
  }
  
  // Hash data (one-way)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Generate a random key
  Uint8List _generateRandomKey(int length) {
    final random = encrypt.SecureRandom(length);
    return random.bytes;
  }
}
