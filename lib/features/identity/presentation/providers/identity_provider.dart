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
  
  // Request a new verifiable credential
  Future<VerifiableCredential?> requestCredential({
    required String issuerDid,
    required String issuerName,
    required String credentialType,
    required Map<String, dynamic> credentialSubject
  }) async {
    _status = IdentityStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_identityRepository != null && _identity != null) {
        // In a real implementation, this would make an API call to the issuer
        // For now, we'll create a simulated credential
        final credential = await _identityRepository.requestCredential(
          holderDid: _identity!.did,
          issuerDid: issuerDid,
          issuerName: issuerName,
          credentialType: credentialType,
          credentialSubject: credentialSubject
        );
        
        // Add the new credential to our list
        if (credential != null) {
          _credentials.add(credential);
        }
        
        _status = IdentityStatus.loaded;
        notifyListeners();
        return credential;
      }
      
      _status = IdentityStatus.loaded;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _status = IdentityStatus.error;
      notifyListeners();
      return null;
    }
  }
}
