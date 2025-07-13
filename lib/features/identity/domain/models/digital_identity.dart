class DigitalIdentity {
  final String did;
  final String publicKey;
  final String controller;
  final DateTime created;
  final DateTime? updated;
  final bool isActive;

  DigitalIdentity({
    required this.did,
    required this.publicKey,
    required this.controller,
    required this.created,
    this.updated,
    required this.isActive,
  });

  factory DigitalIdentity.fromJson(Map<String, dynamic> json) {
    return DigitalIdentity(
      did: json['did'] as String,
      publicKey: json['publicKey'] as String,
      controller: json['controller'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'publicKey': publicKey,
      'controller': controller,
      'created': created.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'isActive': isActive,
    };
  }

  DigitalIdentity copyWith({
    String? did,
    String? publicKey,
    String? controller,
    DateTime? created,
    DateTime? updated,
    bool? isActive,
  }) {
    return DigitalIdentity(
      did: did ?? this.did,
      publicKey: publicKey ?? this.publicKey,
      controller: controller ?? this.controller,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      isActive: isActive ?? this.isActive,
    );
  }
}
