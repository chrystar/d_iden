import 'package:flutter/material.dart';
import '../../domain/models/digital_identity.dart';
import '../../domain/models/verifiable_credential.dart';
import '../../domain/repositories/identity_repository.dart';

enum IdentityStatus {
  initial,
  loading,
  loaded,
  error,
}

class IdentityProvider extends ChangeNotifier {
  final IdentityRepository? _identityRepository;
  
  IdentityStatus _status = IdentityStatus.initial;
  DigitalIdentity? _identity;
  List<VerifiableCredential> _credentials = [];
  String? _error;
  
  IdentityProvider({IdentityRepository? identityRepository})
      : _identityRepository = identityRepository;
  
  // Getters
  IdentityStatus get status => _status;
  DigitalIdentity? get identity => _identity;
  List<VerifiableCredential> get credentials => _credentials;
  String? get error => _error;
  
  // Will implement actual methods when we implement the repository
  // For now, we'll just have placeholder methods
  
  Future<void> loadIdentity(String userId) async {
    _status = IdentityStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_identityRepository != null) {
        _identity = await _identityRepository.getIdentity(userId);
        
        if (_identity != null) {
          _credentials = await _identityRepository.getUserCredentials(_identity!.did);
        }
      }
      
      _status = IdentityStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = IdentityStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> createIdentity(String userId) async {
    _status = IdentityStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_identityRepository != null) {
        _identity = await _identityRepository.createIdentity(userId);
        _credentials = [];
      }
      
      _status = IdentityStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = IdentityStatus.error;
    }
    
    notifyListeners();
  }
  
  // Reset error state
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
