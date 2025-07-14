import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BiometricStatus {
  enabled,
  disabled,
  unsupported,
}

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _biometricKey = 'biometric_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _pinRequirementKey = 'pin_requirement';
  
  // Default values
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  BiometricStatus _biometricStatus = BiometricStatus.disabled;
  String _pinRequirement = 'always'; // 'always', 'transactions', 'disabled'
  
  bool _isLoaded = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  BiometricStatus get biometricStatus => _biometricStatus;
  String get pinRequirement => _pinRequirement;
  bool get isLoaded => _isLoaded;
  
  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme setting
      final themeModeString = prefs.getString(_themeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == 'ThemeMode.$themeModeString',
          orElse: () => ThemeMode.system,
        );
      }
      
      // Load biometric setting
      final biometricStatusString = prefs.getString(_biometricKey);
      if (biometricStatusString != null) {
        _biometricStatus = BiometricStatus.values.firstWhere(
          (e) => e.toString() == 'BiometricStatus.$biometricStatusString',
          orElse: () => BiometricStatus.disabled,
        );
      }
      
      // Load notifications setting
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      
      // Load PIN requirement setting
      _pinRequirement = prefs.getString(_pinRequirementKey) ?? 'always';
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use default settings if loading fails
    }
  }
  
  // Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString().split('.').last);
    } catch (e) {
      debugPrint('Error saving theme setting: $e');
    }
  }
  
  // Update biometric status
  Future<void> setBiometricStatus(BiometricStatus status) async {
    _biometricStatus = status;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_biometricKey, status.toString().split('.').last);
    } catch (e) {
      debugPrint('Error saving biometric setting: $e');
    }
  }
  
  // Update notifications setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
    }
  }
  
  // Update PIN requirement setting
  Future<void> setPinRequirement(String requirement) async {
    _pinRequirement = requirement;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinRequirementKey, requirement);
    } catch (e) {
      debugPrint('Error saving PIN requirement setting: $e');
    }
  }
}
