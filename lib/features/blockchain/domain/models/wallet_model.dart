import 'package:web3dart/web3dart.dart';

class WalletModel {
  final String address;
  final String publicKey;
  final double balance;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.address,
    required this.publicKey,
    this.balance = 0.0,
    this.transactions = const [],
  });

  WalletModel copyWith({
    String? address,
    String? publicKey,
    double? balance,
    List<TransactionModel>? transactions,
  }) {
    return WalletModel(
      address: address ?? this.address,
      publicKey: publicKey ?? this.publicKey,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }

  factory WalletModel.fromCredentials(Credentials credentials, {double balance = 0.0}) {
    return WalletModel(
      address: credentials is EthPrivateKey ? credentials.address.hex : '',
      publicKey: credentials is EthPrivateKey ? credentials.address.hexEip55 : '',
      balance: balance,
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'publicKey': publicKey,
    'balance': balance,
    'transactions': transactions.map((tx) => tx.toJson()).toList(),
  };

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'] as String,
      publicKey: json['publicKey'] as String,
      balance: (json['balance'] as num).toDouble(),
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((tx) => TransactionModel.fromJson(tx as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class TransactionModel {
  final String txHash;
  final String from;
  final String to;
  final double amount;
  final String? data;
  final DateTime timestamp;
  final bool isPending;
  final int? confirmations;
  final String? errorMessage;
  final int? gasUsed;
  final double? gasPrice;

  TransactionModel({
    required this.txHash,
    required this.from,
    required this.to,
    required this.amount,
    this.data,
    required this.timestamp,
    this.isPending = false,
    this.confirmations,
    this.errorMessage,
    this.gasUsed,
    this.gasPrice,
  });

  Map<String, dynamic> toJson() => {
    'txHash': txHash,
    'from': from,
    'to': to,
    'amount': amount,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'isPending': isPending,
    'confirmations': confirmations,
    'errorMessage': errorMessage,
    'gasUsed': gasUsed,
    'gasPrice': gasPrice,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      txHash: json['txHash'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
      data: json['data'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPending: json['isPending'] as bool? ?? false,
      confirmations: json['confirmations'] as int?,
      errorMessage: json['errorMessage'] as String?,
      gasUsed: json['gasUsed'] as int?,
      gasPrice: json['gasPrice'] != null ? (json['gasPrice'] as num).toDouble() : null,
    );
  }
}
