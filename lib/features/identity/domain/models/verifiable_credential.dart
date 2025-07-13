enum CredentialType {
  personalInfo,
  education,
  employment,
  certificate,
  membership,
  license,
  identification,
  custom
}

enum CredentialStatus {
  active,
  expired,
  revoked,
  pending
}

class VerifiableCredential {
  final String id;
  final String name;
  final CredentialType type;
  final Map<String, dynamic> attributes;
  final String issuerId;
  final String issuerName;
  final String holderDid;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final CredentialStatus status;
  final String? signature;
  final bool isVerified;

  VerifiableCredential({
    required this.id,
    required this.name,
    required this.type,
    required this.attributes,
    required this.issuerId,
    required this.issuerName,
    required this.holderDid,
    required this.issuedAt,
    this.expiresAt,
    required this.status,
    this.signature,
    required this.isVerified,
  });

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CredentialType.values.firstWhere(
        (e) => e.toString() == 'CredentialType.${json['type']}',
        orElse: () => CredentialType.custom,
      ),
      attributes: json['attributes'] as Map<String, dynamic>,
      issuerId: json['issuerId'] as String,
      issuerName: json['issuerName'] as String,
      holderDid: json['holderDid'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      status: CredentialStatus.values.firstWhere(
        (e) => e.toString() == 'CredentialStatus.${json['status']}',
      ),
      signature: json['signature'] as String?,
      isVerified: json['isVerified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'attributes': attributes,
      'issuerId': issuerId,
      'issuerName': issuerName,
      'holderDid': holderDid,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'signature': signature,
      'isVerified': isVerified,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  VerifiableCredential copyWith({
    String? id,
    String? name,
    CredentialType? type,
    Map<String, dynamic>? attributes,
    String? issuerId,
    String? issuerName,
    String? holderDid,
    DateTime? issuedAt,
    DateTime? expiresAt,
    CredentialStatus? status,
    String? signature,
    bool? isVerified,
  }) {
    return VerifiableCredential(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      attributes: attributes ?? this.attributes,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      holderDid: holderDid ?? this.holderDid,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      signature: signature ?? this.signature,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
