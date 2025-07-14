import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:crypto/crypto.dart';

import '../../domain/models/did_model.dart';
import '../blockchain_config.dart';
import 'wallet_service.dart';

class DIDService {
  final Web3Client _web3Client;
  final EthereumAddress _contractAddress;
  late final SharedPreferences _prefs;
  final WalletService _walletService;
  
  DIDModel? _currentDID;
  
  DIDService({
    required WalletService walletService,
    Web3Client? web3Client,
    String? rpcUrl,
    String? contractAddress,
  }) : _walletService = walletService,
       _web3Client = web3Client ?? Web3Client(
         rpcUrl ?? BlockchainConfig.defaultRpcUrl,
         http.Client(),
       ),
       _contractAddress = EthereumAddress.fromHex(
         contractAddress ?? BlockchainConfig.identityContractAddress
       );
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    // Check if DID already exists and load it
    await _loadDIDFromStorage();
  }

  DIDModel? get currentDID => _currentDID;
  
  /// Create a new DID using the wallet address
  Future<DIDModel> createDID() async {
    if (_walletService.currentWallet == null) {
      throw Exception('No wallet available to create DID');
    }
    
    try {
      final address = _walletService.currentWallet!.address;
      
      // Create a basic DID using the wallet address
      final did = DIDModel.create(address);
      
      // In a real implementation, you would register the DID on the blockchain
      // For this example, we'll just save it locally
      await _saveDID(did);
      
      _currentDID = did;
      return did;
    } catch (e) {
      debugPrint('Error creating DID: $e');
      throw Exception('Failed to create DID: ${e.toString()}');
    }
  }
  
  /// Add a verification method to the DID
  Future<DIDModel> addVerificationMethod({
    required String type,
    required String publicKey,
  }) async {
    if (_currentDID == null) {
      throw Exception('No DID loaded');
    }
    
    try {
      final id = '${_currentDID!.did}#key-${DateTime.now().millisecondsSinceEpoch}';
      
      final verificationMethod = VerificationMethod(
        id: id,
        type: type,
        controller: _currentDID!.did,
        publicKeyMultibase: publicKey,
      );
      
      final updatedVerificationMethods = [
        ..._currentDID!.verificationMethods,
        verificationMethod,
      ];
      
      final updatedDID = DIDModel(
        did: _currentDID!.did,
        controller: _currentDID!.controller,
        verificationMethods: updatedVerificationMethods,
        authenticationKeys: _currentDID!.authenticationKeys,
        service: _currentDID!.service,
      );
      
      // Save updated DID
      await _saveDID(updatedDID);
      
      _currentDID = updatedDID;
      return updatedDID;
    } catch (e) {
      debugPrint('Error adding verification method: $e');
      throw Exception('Failed to add verification method: ${e.toString()}');
    }
  }
  
  /// Create a verifiable credential
  Future<VerifiableCredential> createVerifiableCredential({
    required String type,
    required Map<String, dynamic> claims,
    String? subjectDid,
  }) async {
    if (_currentDID == null) {
      throw Exception('No DID loaded');
    }
    
    if (_walletService.currentWallet == null) {
      throw Exception('No wallet available to sign credential');
    }
    
    try {
      final id = 'urn:uuid:${_generateUUID()}';
      final issuanceDate = DateTime.now();
      
      // The subject of the credential (recipient)
      final subject = subjectDid ?? _currentDID!.did;
      
      // Create the credential data
      final credentialData = {
        '@context': [
          'https://www.w3.org/2018/credentials/v1',
        ],
        'id': id,
        'type': ['VerifiableCredential', type],
        'issuer': _currentDID!.did,
        'issuanceDate': issuanceDate.toIso8601String(),
        'credentialSubject': {
          'id': subject,
          ...claims,
        },
      };
      
      // Create a simple proof by hashing and signing the credential data
      final credentialHash = sha256.convert(utf8.encode(jsonEncode(credentialData))).toString();
      
      // In a real implementation, you would sign this hash with the issuer's private key
      // For this example, we'll just use it as is for the proof
      final proof = credentialHash;
      
      final verifiableCredential = VerifiableCredential(
        id: id,
        type: type,
        issuer: _currentDID!.did,
        issuanceDate: issuanceDate,
        credentialSubject: {
          'id': subject,
          ...claims,
        },
        proof: proof,
      );
      
      return verifiableCredential;
    } catch (e) {
      debugPrint('Error creating verifiable credential: $e');
      throw Exception('Failed to create verifiable credential: ${e.toString()}');
    }
  }
  
  /// Verify a credential (simplified for this example)
  bool verifyCredential(VerifiableCredential credential) {
    try {
      // In a real implementation, you would verify the proof by checking the signature
      // For this example, we'll just return true
      return true;
    } catch (e) {
      debugPrint('Error verifying credential: $e');
      return false;
    }
  }
  
  /// Check if a DID exists in storage
  Future<bool> hasDID() async {
    final didJson = _prefs.getString('did_document');
    return didJson != null;
  }
  
  /// Save DID to storage
  Future<void> _saveDID(DIDModel did) async {
    try {
      await _prefs.setString(
        'did_document',
        jsonEncode(did.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving DID: $e');
      throw Exception('Failed to save DID: ${e.toString()}');
    }
  }
  
  /// Load DID from storage
  Future<void> _loadDIDFromStorage() async {
    try {
      final didJson = _prefs.getString('did_document');
      
      if (didJson != null) {
        final didData = jsonDecode(didJson) as Map<String, dynamic>;
        _currentDID = DIDModel.fromJson(didData);
      }
    } catch (e) {
      debugPrint('Error loading DID: $e');
      // Don't throw here, just consider no DID is loaded
    }
  }
  
  /// Clear DID data
  Future<void> clearDID() async {
    try {
      await _prefs.remove('did_document');
      _currentDID = null;
    } catch (e) {
      debugPrint('Error clearing DID: $e');
      throw Exception('Failed to clear DID: ${e.toString()}');
    }
  }
  
  /// Helper function to generate a UUID
  String _generateUUID() {
    final random = Uint8List.fromList(List.generate(16, (_) => DateTime.now().millisecondsSinceEpoch % 256));
    random[6] = (random[6] & 0x0F) | 0x40; // Version 4
    random[8] = (random[8] & 0x3F) | 0x80; // Variant 10
    
    final hex = HEX.encode(random);
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
  
  /// Dispose resources
  void dispose() {
    _web3Client.dispose();
  }
}
