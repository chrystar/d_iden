import 'package:flutter/material.dart';
import '../services/security_service.dart';

enum SecurityStatus {
  initializing,
  ready,
  error,
  locked,
  unlocked,
}

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;
  
  SecurityStatus _status = SecurityStatus.initializing;
  String? _error;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  
  SecurityProvider({SecurityService? securityService})
      : _securityService = securityService ?? SecurityService() {
    _initialize();
  }
  
  SecurityStatus get status => _status;
  String? get error => _error;
  bool get biometricsAvailable => _biometricsAvailable;
  bool get biometricsEnabled => _biometricsEnabled;
  
  Future<void> _initialize() async {
    try {
      _status = SecurityStatus.initializing;
      notifyListeners();
      
      // Initialize security service
      await _securityService.initialize();
      
      // Check biometrics availability
      _biometricsAvailable = await _securityService.isBiometricsAvailable();
      _biometricsEnabled = await _securityService.isBiometricsEnabled();
      
      _status = SecurityStatus.ready;
    } catch (e) {
      _error = e.toString();
      _status = SecurityStatus.error;
    } finally {
      notifyListeners();
    }
  }
  
  // Enable or disable biometric authentication
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await _securityService.setBiometricsEnabled(enabled);
      _biometricsEnabled = enabled;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Authenticate user with biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access your wallet',
  }) async {
    try {
      if (!_biometricsEnabled || !_biometricsAvailable) {
        return true; // Skip if not available or not enabled
      }
      
      final result = await _securityService.authenticateWithBiometrics(
        localizedReason: reason,
      );
      
      if (result) {
        _status = SecurityStatus.unlocked;
      } else {
        _status = SecurityStatus.locked;
      }
      
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _status = SecurityStatus.error;
      notifyListeners();
      return false;
    }
  }
  
  // Encrypt sensitive data
  Future<String> encryptData(String data) async {
    try {
      return await _securityService.encryptData(data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Decrypt sensitive data
  Future<String> decryptData(String encryptedData) async {
    try {
      return await _securityService.decryptData(encryptedData);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Securely store data
  Future<void> secureStore(String key, String value) async {
    try {
      await _securityService.secureWrite(key: key, value: value);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Retrieve securely stored data
  Future<String?> secureRetrieve(String key) async {
    try {
      return await _securityService.secureRead(key: key);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
