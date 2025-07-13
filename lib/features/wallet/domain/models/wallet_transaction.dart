enum TransactionType {
  send,
  receive,
  contractCall,
  identityIssuance,
  identityVerification,
  other
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  rejected
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String? fromAddress;
  final String? toAddress;
  final double amount;
  final String currency;
  final double gasFee;
  final TransactionType type;
  final TransactionStatus status;
  final String? hash;
  final int? confirmations;
  final DateTime timestamp;
  final String? data;
  final String? note;

  WalletTransaction({
    required this.id,
    required this.walletId,
    this.fromAddress,
    this.toAddress,
    required this.amount,
    required this.currency,
    required this.gasFee,
    required this.type,
    required this.status,
    this.hash,
    this.confirmations,
    required this.timestamp,
    this.data,
    this.note,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      fromAddress: json['fromAddress'] as String?,
      toAddress: json['toAddress'] as String?,
      amount: json['amount'] as double,
      currency: json['currency'] as String,
      gasFee: json['gasFee'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.other,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      hash: json['hash'] as String?,
      confirmations: json['confirmations'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount,
      'currency': currency,
      'gasFee': gasFee,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'hash': hash,
      'confirmations': confirmations,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'note': note,
    };
  }

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    String? fromAddress,
    String? toAddress,
    double? amount,
    String? currency,
    double? gasFee,
    TransactionType? type,
    TransactionStatus? status,
    String? hash,
    int? confirmations,
    DateTime? timestamp,
    String? data,
    String? note,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      gasFee: gasFee ?? this.gasFee,
      type: type ?? this.type,
      status: status ?? this.status,
      hash: hash ?? this.hash,
      confirmations: confirmations ?? this.confirmations,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      note: note ?? this.note,
    );
  }
}
