import '../services/wallet_service.dart';
import '../services/did_service.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/models/did_model.dart';

class BlockchainRepository {
  final WalletService _walletService;
  final DIDService _didService;
  
  BlockchainRepository({
    required WalletService walletService,
    required DIDService didService,
  }) : _walletService = walletService,
      _didService = didService;
      
  Future<void> initialize() async {
    await _walletService.initialize();
    await _didService.initialize();
  }
  
  // Wallet methods
  Future<WalletModel> createWallet({String? password}) async {
    return _walletService.createWallet(password: password);
  }
  
  Future<WalletModel> importWalletFromMnemonic({
    required String mnemonic,
    String? password,
  }) async {
    return _walletService.createWalletFromMnemonic(
      mnemonic: mnemonic,
      password: password,
    );
  }
  
  Future<WalletModel> importWalletFromPrivateKey({
    required String privateKey,
    String? password,
  }) async {
    return _walletService.importWalletFromPrivateKey(
      privateKey: privateKey,
      password: password,
    );
  }
  
  Future<double> getWalletBalance() async {
    return _walletService.getBalance();
  }
  
  Future<String> sendTransaction({
    required String toAddress,
    required double amount,
    String? data,
  }) async {
    return _walletService.sendTransaction(
      toAddress: toAddress,
      amount: amount,
      data: data,
    );
  }
  
  Future<List<TransactionModel>> getTransactionHistory() async {
    return _walletService.getTransactionHistory();
  }
  
  WalletModel? get currentWallet => _walletService.currentWallet;
  
  Future<bool> hasWallet() async {
    return _walletService.hasWallet();
  }
  
  Future<void> clearWallet() async {
    return _walletService.clearWallet();
  }
  
  // DID methods
  Future<DIDModel> createDID() async {
    return _didService.createDID();
  }
  
  Future<DIDModel> addVerificationMethod({
    required String type,
    required String publicKey,
  }) async {
    return _didService.addVerificationMethod(
      type: type,
      publicKey: publicKey,
    );
  }
  
  Future<VerifiableCredential> createVerifiableCredential({
    required String type,
    required Map<String, dynamic> claims,
    String? subjectDid,
  }) async {
    return _didService.createVerifiableCredential(
      type: type,
      claims: claims,
      subjectDid: subjectDid,
    );
  }
  
  bool verifyCredential(VerifiableCredential credential) {
    return _didService.verifyCredential(credential);
  }
  
  DIDModel? get currentDID => _didService.currentDID;
  
  Future<bool> hasDID() async {
    return _didService.hasDID();
  }
  
  Future<void> clearDID() async {
    return _didService.clearDID();
  }
  
  void dispose() {
    _walletService.dispose();
    _didService.dispose();
  }
}
