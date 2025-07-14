import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../domain/models/wallet_model.dart';
import '../../domain/models/did_model.dart';
import '../../data/services/wallet_service.dart';
import '../../data/services/did_service.dart';
import '../../data/repositories/blockchain_repository.dart';
import '../../data/blockchain_config.dart';

enum BlockchainStatus {
  uninitialized,
  initializing,
  ready,
  error,
}

class BlockchainProvider extends ChangeNotifier {
  late final BlockchainRepository _repository;
  BlockchainStatus _status = BlockchainStatus.uninitialized;
  String? _error;
  
  // Constructor
  BlockchainProvider() {
    _initialize();
  }
  
  // Getters
  BlockchainStatus get status => _status;
  String? get error => _error;
  WalletModel? get wallet => _repository.currentWallet;
  DIDModel? get did => _repository.currentDID;
  
  bool get isWalletCreated => wallet != null;
  bool get isDIDCreated => did != null;
  
  // Initialize blockchain services
  Future<void> _initialize() async {
    _status = BlockchainStatus.initializing;
    _error = null;
    notifyListeners();
    
    try {
      // Create web3 client
      final web3Client = Web3Client(
        BlockchainConfig.defaultRpcUrl,
        http.Client(),
      );
      
      // Create services
      final walletService = WalletService(web3Client: web3Client);
      final didService = DIDService(
        walletService: walletService,
        web3Client: web3Client,
      );
      
      // Create repository
      _repository = BlockchainRepository(
        walletService: walletService,
        didService: didService,
      );
      
      // Initialize repository
      await _repository.initialize();
      
      _status = BlockchainStatus.ready;
    } catch (e) {
      _status = BlockchainStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Wallet methods
  Future<WalletModel> createWallet({String? password}) async {
    _error = null;
    try {
      final wallet = await _repository.createWallet(password: password);
      notifyListeners();
      return wallet;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<WalletModel> importWalletFromMnemonic({
    required String mnemonic,
    String? password,
  }) async {
    _error = null;
    try {
      final wallet = await _repository.importWalletFromMnemonic(
        mnemonic: mnemonic,
        password: password,
      );
      notifyListeners();
      return wallet;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<WalletModel> importWalletFromPrivateKey({
    required String privateKey,
    String? password,
  }) async {
    _error = null;
    try {
      final wallet = await _repository.importWalletFromPrivateKey(
        privateKey: privateKey,
        password: password,
      );
      notifyListeners();
      return wallet;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<double> refreshWalletBalance() async {
    _error = null;
    try {
      final balance = await _repository.getWalletBalance();
      notifyListeners();
      return balance;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<String> sendTransaction({
    required String toAddress,
    required double amount,
    String? data,
  }) async {
    _error = null;
    try {
      final txHash = await _repository.sendTransaction(
        toAddress: toAddress,
        amount: amount,
        data: data,
      );
      // Refresh balance after transaction
      refreshWalletBalance();
      return txHash;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<List<TransactionModel>> getTransactionHistory() async {
    _error = null;
    try {
      return await _repository.getTransactionHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // DID methods
  Future<DIDModel> createDID() async {
    _error = null;
    try {
      final did = await _repository.createDID();
      notifyListeners();
      return did;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<DIDModel> addVerificationMethod({
    required String type,
    required String publicKey,
  }) async {
    _error = null;
    try {
      final did = await _repository.addVerificationMethod(
        type: type,
        publicKey: publicKey,
      );
      notifyListeners();
      return did;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<VerifiableCredential> createVerifiableCredential({
    required String type,
    required Map<String, dynamic> claims,
    String? subjectDid,
  }) async {
    _error = null;
    try {
      return await _repository.createVerifiableCredential(
        type: type,
        claims: claims,
        subjectDid: subjectDid,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  bool verifyCredential(VerifiableCredential credential) {
    try {
      return _repository.verifyCredential(credential);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Clear wallet and DID
  Future<void> clearWalletAndDID() async {
    _error = null;
    try {
      await _repository.clearWallet();
      await _repository.clearDID();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Check if a DID exists
  Future<bool> hasExistingDID() async {
    _error = null;
    try {
      return await _repository.hasDID();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
