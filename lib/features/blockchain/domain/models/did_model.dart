class DIDModel {
  final String did;
  final String controller;
  final List<VerificationMethod> verificationMethods;
  final List<String> authenticationKeys;
  final Map<String, dynamic>? service;
  
  DIDModel({
    required this.did,
    required this.controller,
    this.verificationMethods = const [],
    this.authenticationKeys = const [],
    this.service,
  });
  
  factory DIDModel.create(String address) {
    final did = 'did:ethr:$address';
    return DIDModel(
      did: did,
      controller: address,
      authenticationKeys: [address],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '@context': 'https://www.w3.org/ns/did/v1',
      'id': did,
      'controller': controller,
      'verificationMethod': verificationMethods.map((vm) => vm.toJson()).toList(),
      'authentication': authenticationKeys,
      'service': service,
    };
  }
  
  factory DIDModel.fromJson(Map<String, dynamic> json) {
    return DIDModel(
      did: json['id'] as String,
      controller: json['controller'] as String,
      verificationMethods: (json['verificationMethod'] as List<dynamic>?)
          ?.map((e) => VerificationMethod.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      authenticationKeys: (json['authentication'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      service: json['service'] as Map<String, dynamic>?,
    );
  }
}

class VerificationMethod {
  final String id;
  final String type;
  final String controller;
  final String publicKeyMultibase;
  
  VerificationMethod({
    required this.id,
    required this.type,
    required this.controller,
    required this.publicKeyMultibase,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'controller': controller,
      'publicKeyMultibase': publicKeyMultibase,
    };
  }
  
  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    return VerificationMethod(
      id: json['id'] as String,
      type: json['type'] as String,
      controller: json['controller'] as String,
      publicKeyMultibase: json['publicKeyMultibase'] as String,
    );
  }
}

class VerifiableCredential {
  final String id;
  final String type;
  final String issuer;
  final DateTime issuanceDate;
  final Map<String, dynamic> credentialSubject;
  final String proof;
  
  VerifiableCredential({
    required this.id,
    required this.type,
    required this.issuer,
    required this.issuanceDate,
    required this.credentialSubject,
    required this.proof,
  });
  
  Map<String, dynamic> toJson() {
    return {
      '@context': [
        'https://www.w3.org/2018/credentials/v1',
      ],
      'id': id,
      'type': ['VerifiableCredential', type],
      'issuer': issuer,
      'issuanceDate': issuanceDate.toIso8601String(),
      'credentialSubject': credentialSubject,
      'proof': proof,
    };
  }
  
  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'] as String,
      type: (json['type'] as List<dynamic>).last as String,
      issuer: json['issuer'] as String,
      issuanceDate: DateTime.parse(json['issuanceDate'] as String),
      credentialSubject: json['credentialSubject'] as Map<String, dynamic>,
      proof: json['proof'] as String,
    );
  }
}
