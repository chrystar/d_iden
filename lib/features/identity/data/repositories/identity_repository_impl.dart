import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart' show hex;

import '../../domain/models/digital_identity.dart';
import '../../domain/models/verifiable_credential.dart';
import '../../domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  static const _identitiesStorageKey = 'digital_identities';
  static const _credentialsStorageKey = 'verifiable_credentials';
  static const _issuerMapStorageKey = 'issuer_map';
  
  final _uuid = const Uuid();

  IdentityRepositoryImpl();

  @override
  Future<DigitalIdentity> createIdentity(String userId) async {
    try {
      // Generate a new key pair for identity
      final credentials = EthPrivateKey.createRandom(Random.secure());
      final publicKey = credentials.address.hex;
      
      // Generate a decentralized identifier using the public key
      // Format: did:diden:{publicKey}
      final did = 'did:diden:${publicKey.substring(2)}';
      
      // Create digital identity object
      final identity = DigitalIdentity(
        did: did,
        publicKey: publicKey,
        controller: userId,
        created: DateTime.now(),
        isActive: true,
      );
      
      // Save identity and encrypted private key
      await _saveIdentity(identity, credentials.privateKey);
      
      return identity;
    } catch (e) {
      throw Exception('Failed to create identity: ${e.toString()}');
    }
  }

  @override
  Future<DigitalIdentity?> getIdentity(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final identitiesJson = prefs.getString(_identitiesStorageKey);
      
      if (identitiesJson == null) {
        return null;
      }
      
      final Map<String, dynamic> identitiesMap = json.decode(identitiesJson);
      
      // Find identity by userId (controller)
      DigitalIdentity? foundIdentity;
      identitiesMap.forEach((did, data) {
        if (data['controller'] == userId) {
          foundIdentity = DigitalIdentity.fromJson({
            'did': did,
            ...data,
          });
        }
      });
      
      return foundIdentity;
    } catch (e) {
      throw Exception('Failed to get identity: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyIdentity(String did, String signature, String message) async {
    try {
      // Get identity from storage
      final prefs = await SharedPreferences.getInstance();
      final identitiesJson = prefs.getString(_identitiesStorageKey);
      
      if (identitiesJson == null) {
        throw Exception('No identities found');
      }
      
      final Map<String, dynamic> identitiesMap = json.decode(identitiesJson);
      final identityData = identitiesMap[did];
      
      if (identityData == null) {
        throw Exception('Identity not found');
      }
      
      // Basic validation checks on the signature
      if (signature.startsWith('0x')) {
        signature = signature.substring(2);
      }
      
      // Check signature length (r[32] + s[32] + v[1] = 65 bytes = 130 hex chars)
      if (signature.length != 130) {
        return false;
      }
      
      // In a real implementation, we would do cryptographic verification
      // but we're simplifying here
      return true;
    } catch (e) {
      throw Exception('Failed to verify identity: ${e.toString()}');
    }
  }

  @override
  Future<void> revokeIdentity(String did) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final identitiesJson = prefs.getString(_identitiesStorageKey);
      
      if (identitiesJson == null) {
        throw Exception('No identities found');
      }
      
      final Map<String, dynamic> identitiesMap = json.decode(identitiesJson);
      if (!identitiesMap.containsKey(did)) {
        throw Exception('Identity not found');
      }
      
      // Mark as inactive
      identitiesMap[did]['isActive'] = false;
      identitiesMap[did]['updated'] = DateTime.now().toIso8601String();
      
      // Save updated data
      await prefs.setString(_identitiesStorageKey, json.encode(identitiesMap));
      
      // Also revoke all credentials issued to this DID
      await _revokeAllCredentialsForHolder(did);
    } catch (e) {
      throw Exception('Failed to revoke identity: ${e.toString()}');
    }
  }

  @override
  Future<List<VerifiableCredential>> getUserCredentials(String did) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      
      if (credentialsJson == null) {
        return [];
      }
      
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      final List<VerifiableCredential> credentials = [];
      
      // Filter credentials by holder DID
      credentialsMap.forEach((id, data) {
        if (data['holderDid'] == did) {
          credentials.add(VerifiableCredential.fromJson({
            'id': id,
            ...data,
          }));
        }
      });
      
      // Update status for any expired credentials
      for (var i = 0; i < credentials.length; i++) {
        if (credentials[i].isExpired && credentials[i].status == CredentialStatus.active) {
          credentials[i] = credentials[i].copyWith(
            status: CredentialStatus.expired,
          );
          
          // Update in storage
          credentialsMap[credentials[i].id]['status'] = 'expired';
          await prefs.setString(_credentialsStorageKey, json.encode(credentialsMap));
        }
      }
      
      return credentials;
    } catch (e) {
      throw Exception('Failed to get user credentials: ${e.toString()}');
    }
  }

  @override
  Future<VerifiableCredential> issueCredential(
    String issuerId,
    String holderDid,
    String name,
    CredentialType type,
    Map<String, dynamic> attributes,
    DateTime? expiresAt,
  ) async {
    try {
      // Verify that issuer exists
      final issuerIdentity = await getIdentity(issuerId);
      if (issuerIdentity == null) {
        throw Exception('Issuer identity not found');
      }
      
      // Generate a credential ID
      final credentialId = _uuid.v4();
      
      // Get issuer name from storage or use DID
      final issuerName = await _getIssuerName(issuerIdentity.did) ?? issuerIdentity.did;
      
      // Create the credential
      final credential = VerifiableCredential(
        id: credentialId,
        name: name,
        type: type,
        attributes: attributes,
        issuerId: issuerIdentity.did,
        issuerName: issuerName,
        holderDid: holderDid,
        issuedAt: DateTime.now(),
        expiresAt: expiresAt,
        status: CredentialStatus.active,
        signature: null, // Will add later
        isVerified: false,
      );
      
      // Generate a signature for the credential (simplified)
      final signatureData = json.encode({
        'id': credentialId,
        'type': type.toString().split('.').last,
        'attributes': attributes,
        'issuerId': issuerIdentity.did,
        'holderDid': holderDid,
        'issuedAt': credential.issuedAt.toIso8601String(),
        'expiresAt': credential.expiresAt?.toIso8601String(),
      });
      
      // In a real implementation, we would sign this data with the issuer's private key
      // Here we just create a mock signature
      final signature = 'signed:${base64Encode(utf8.encode(signatureData))}';
      
      // Update credential with signature and verified status
      final verifiedCredential = credential.copyWith(
        signature: signature,
        isVerified: true,
      );
      
      // Save the credential
      await _saveCredential(verifiedCredential);
      
      return verifiedCredential;
    } catch (e) {
      throw Exception('Failed to issue credential: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyCredential(String credentialId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      
      if (credentialsJson == null) {
        throw Exception('No credentials found');
      }
      
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      final credentialData = credentialsMap[credentialId];
      
      if (credentialData == null) {
        throw Exception('Credential not found');
      }
      
      // Check if the credential is active
      if (credentialData['status'] != 'active') {
        return false;
      }
      
      // Check if it's expired
      if (credentialData['expiresAt'] != null) {
        final expiryDate = DateTime.parse(credentialData['expiresAt']);
        if (expiryDate.isBefore(DateTime.now())) {
          // Update status in storage
          credentialData['status'] = 'expired';
          await prefs.setString(_credentialsStorageKey, json.encode(credentialsMap));
          return false;
        }
      }
      
      // In a real implementation, we would verify the signature cryptographically
      // Here we just check if it has a signature
      return credentialData['signature'] != null;
    } catch (e) {
      throw Exception('Failed to verify credential: ${e.toString()}');
    }
  }

  @override
  Future<void> revokeCredential(String credentialId, String issuerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      
      if (credentialsJson == null) {
        throw Exception('No credentials found');
      }
      
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      if (!credentialsMap.containsKey(credentialId)) {
        throw Exception('Credential not found');
      }
      
      final credentialData = credentialsMap[credentialId];
      
      // Check if the revoker is the issuer
      final issuerIdentity = await getIdentity(issuerId);
      if (issuerIdentity == null || issuerIdentity.did != credentialData['issuerId']) {
        throw Exception('Only the issuer can revoke this credential');
      }
      
      // Mark as revoked
      credentialData['status'] = 'revoked';
      
      // Save updated data
      await prefs.setString(_credentialsStorageKey, json.encode(credentialsMap));
    } catch (e) {
      throw Exception('Failed to revoke credential: ${e.toString()}');
    }
  }

  @override
  Future<String> generatePresentationProof(
    List<String> credentialIds,
    String holderDid,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      
      if (credentialsJson == null) {
        throw Exception('No credentials found');
      }
      
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      final List<Map<String, dynamic>> selectedCredentials = [];
      
      // Collect all selected credentials
      for (final id in credentialIds) {
        if (!credentialsMap.containsKey(id)) {
          throw Exception('Credential not found: $id');
        }
        
        final credentialData = credentialsMap[id];
        
        // Check if credential belongs to holder
        if (credentialData['holderDid'] != holderDid) {
          throw Exception('Credential does not belong to this holder');
        }
        
        // Check if credential is active
        if (credentialData['status'] != 'active') {
          throw Exception('Credential is not active: $id');
        }
        
        // Check if expired
        if (credentialData['expiresAt'] != null) {
          final expiryDate = DateTime.parse(credentialData['expiresAt']);
          if (expiryDate.isBefore(DateTime.now())) {
            throw Exception('Credential has expired: $id');
          }
        }
        
        selectedCredentials.add({
          'id': id,
          ...credentialData,
        });
      }
      
      // Create a presentation object
      final presentation = {
        'id': _uuid.v4(),
        'holder': holderDid,
        'created': DateTime.now().toIso8601String(),
        'credentials': selectedCredentials,
      };
      
      // In a real implementation, the holder would sign this presentation
      // Here we just encode it
      return base64Encode(utf8.encode(json.encode(presentation)));
    } catch (e) {
      throw Exception('Failed to generate presentation proof: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyPresentationProof(
    String proof,
    List<String> requiredCredentialTypes,
  ) async {
    try {
      // Decode the presentation
      final presentationJson = utf8.decode(base64Decode(proof));
      final presentation = json.decode(presentationJson);
      
      // Check if it has required fields
      if (!presentation.containsKey('holder') || 
          !presentation.containsKey('credentials') ||
          !presentation.containsKey('created')) {
        return false;
      }
      
      // Check if it's recent (within 5 minutes)
      final created = DateTime.parse(presentation['created']);
      final now = DateTime.now();
      final difference = now.difference(created).inMinutes;
      if (difference > 5) {
        return false;
      }
      
      // Check if it has all required credential types
      final credentials = presentation['credentials'] as List;
      final presentedTypes = credentials
          .map((c) => 'CredentialType.${c['type']}')
          .toList();
          
      for (final requiredType in requiredCredentialTypes) {
        if (!presentedTypes.contains(requiredType)) {
          return false;
        }
      }
      
      // In a real implementation, we would verify the signature
      // For now, return true if all checks passed
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper methods
  Future<void> _saveIdentity(DigitalIdentity identity, List<int> privateKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save identity data
      final identitiesJson = prefs.getString(_identitiesStorageKey);
      Map<String, dynamic> identitiesMap = identitiesJson != null
          ? json.decode(identitiesJson)
          : {};
          
      // Remove the did from the object to use as key
      final identityJson = identity.toJson();
      final did = identityJson.remove('did');
      
      identitiesMap[did] = identityJson;
      await prefs.setString(_identitiesStorageKey, json.encode(identitiesMap));
      
      // Save private key (in a real app, this would be securely encrypted)
      final privateKeysJson = prefs.getString('identity_keys');
      Map<String, dynamic> privateKeysMap = privateKeysJson != null
          ? json.decode(privateKeysJson)
          : {};
          
      privateKeysMap[did] = hex.encode(privateKey);
      await prefs.setString('identity_keys', json.encode(privateKeysMap));
    } catch (e) {
      throw Exception('Failed to save identity: ${e.toString()}');
    }
  }
  
  Future<void> _saveCredential(VerifiableCredential credential) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save credential data
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      Map<String, dynamic> credentialsMap = credentialsJson != null
          ? json.decode(credentialsJson)
          : {};
          
      // Remove the id from the object to use as key
      final credentialJson = credential.toJson();
      final id = credentialJson.remove('id');
      
      credentialsMap[id] = credentialJson;
      await prefs.setString(_credentialsStorageKey, json.encode(credentialsMap));
    } catch (e) {
      throw Exception('Failed to save credential: ${e.toString()}');
    }
  }
  
  Future<void> _revokeAllCredentialsForHolder(String holderDid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_credentialsStorageKey);
      
      if (credentialsJson == null) {
        return;
      }
      
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      bool updated = false;
      
      // Mark all credentials for this holder as revoked
      credentialsMap.forEach((id, data) {
        if (data['holderDid'] == holderDid && data['status'] == 'active') {
          data['status'] = 'revoked';
          updated = true;
        }
      });
      
      if (updated) {
        await prefs.setString(_credentialsStorageKey, json.encode(credentialsMap));
      }
    } catch (e) {
      throw Exception('Failed to revoke holder credentials: ${e.toString()}');
    }
  }
  
  Future<String?> _getIssuerName(String issuerDid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final issuerMapJson = prefs.getString(_issuerMapStorageKey);
      
      if (issuerMapJson == null) {
        return null;
      }
      
      final Map<String, dynamic> issuerMap = json.decode(issuerMapJson);
      return issuerMap[issuerDid];
    } catch (e) {
      return null;
    }
  }
}
