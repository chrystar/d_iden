import '../models/digital_identity.dart';
import '../models/verifiable_credential.dart';

abstract class IdentityRepository {
  // Digital Identity Management
  Future<DigitalIdentity> createIdentity(String userId);
  Future<DigitalIdentity?> getIdentity(String userId);
  Future<bool> verifyIdentity(String did, String signature, String message);
  Future<void> revokeIdentity(String did);
  
  // Credential Management
  Future<List<VerifiableCredential>> getUserCredentials(String did);
  Future<VerifiableCredential> issueCredential(
    String issuerId,
    String holderDid,
    String name,
    CredentialType type,
    Map<String, dynamic> attributes,
    DateTime? expiresAt,
  );
  Future<bool> verifyCredential(String credentialId);
  Future<void> revokeCredential(String credentialId, String issuerId);
  
  // Credential Sharing
  Future<String> generatePresentationProof(
    List<String> credentialIds,
    String holderDid,
  );
  Future<bool> verifyPresentationProof(
    String proof,
    List<String> requiredCredentialTypes,
  );
}
