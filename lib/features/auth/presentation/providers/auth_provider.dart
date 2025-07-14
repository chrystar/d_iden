import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/auth_user.dart';
import '../../data/datasources/firebase_auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error
}

class AuthProvider extends ChangeNotifier {
  late final AuthRepositoryImpl _authRepository;
  
  AuthStatus _status = AuthStatus.initial;
  AuthUser? _user;
  String? _error;
  
  AuthProvider() {
    final firebaseAuthDataSource = FirebaseAuthDataSource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    
    _authRepository = AuthRepositoryImpl(
      authDataSource: firebaseAuthDataSource,
    );
    
    _checkCurrentUser();
  }
  
  // Getters
  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  // Methods
  Future<void> _checkCurrentUser() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      final isSignedIn = await _authRepository.isSignedIn();
      
      if (isSignedIn) {
        _user = await _authRepository.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _authRepository.signIn(email, password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> signUp(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _authRepository.signUp(email, password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> signOut() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.forgotPassword(email);
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return;
    
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      
      // Get updated user data
      _user = await _authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    if (_user == null) return;
    
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.updatePassword(currentPassword, newPassword);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> deleteAccount(String password) async {
    if (_user == null) return;
    
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await _authRepository.deleteAccount(password);
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    if (_user == null) return;
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.updateEmail(newEmail: newEmail, currentPassword: currentPassword);
      _user = await _authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }
  
  // Reset error state
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
