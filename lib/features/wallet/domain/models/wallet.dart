enum WalletType {
  ethereum,
  polygon,
  custom
}

class Wallet {
  final String id;
  final String address;
  final String userId;
  final WalletType type;
  final String network;
  final double balance;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isActive;

  Wallet({
    required this.id,
    required this.address,
    required this.userId,
    required this.type,
    required this.network,
    required this.balance,
    required this.createdAt,
    this.lastUpdated,
    required this.isActive,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      address: json['address'] as String,
      userId: json['userId'] as String,
      type: WalletType.values.firstWhere(
        (e) => e.toString() == 'WalletType.${json['type']}',
        orElse: () => WalletType.custom,
      ),
      network: json['network'] as String,
      balance: json['balance'] as double,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'userId': userId,
      'type': type.toString().split('.').last,
      'network': network,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Wallet copyWith({
    String? id,
    String? address,
    String? userId,
    WalletType? type,
    String? network,
    double? balance,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return Wallet(
      id: id ?? this.id,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      network: network ?? this.network,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }
}
