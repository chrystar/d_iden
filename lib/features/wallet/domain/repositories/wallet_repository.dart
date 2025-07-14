import '../models/wallet.dart';
import '../models/wallet_transaction.dart';

abstract class WalletRepository {
  // Wallet Management
  Future<Wallet> createWallet(String userId, String pin);
  Future<Wallet?> getWallet(String userId);
  Future<double> getWalletBalance(String walletId);
  Future<bool> unlockWallet(String walletId, String pin);
  Future<void> lockWallet(String walletId);
  Future<String> exportPrivateKey(String walletId, String pin);
  Future<Wallet> importWallet(String userId, String privateKey, String pin);
  
  // Transaction Management
  Future<WalletTransaction> sendTransaction(
    String walletId,
    String pin,
    String toAddress,
    double amount,
    String currency,
    {String? data, String? note}
  );
  Future<List<WalletTransaction>> getTransactions(String walletId);
  Future<WalletTransaction> getTransactionDetails(
    String walletId,
    String transactionId
  );
  
  // Signing and Verification
  Future<String> signMessage(
    String walletId,
    String pin,
    String message
  );
  Future<bool> verifySignature(
    String address,
    String signature,
    String message
  );
  
  /// Checks if the RPC connection is available
  Future<bool> checkRpcConnection();
}
