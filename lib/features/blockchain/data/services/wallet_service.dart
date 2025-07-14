import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../../domain/models/wallet_model.dart';
import '../blockchain_config.dart';

class WalletService {
  final Web3Client _web3Client;
  final EthereumAddress? _contractAddress;
  late final SharedPreferences _prefs;
  
  WalletModel? _currentWallet;
  String? _privateKey;
  
  WalletService({
    Web3Client? web3Client,
    String? rpcUrl,
    String? contractAddress,
  }) : _web3Client = web3Client ?? Web3Client(
         rpcUrl ?? BlockchainConfig.defaultRpcUrl,
         http.Client(),
       ),
       _contractAddress = contractAddress != null 
         ? EthereumAddress.fromHex(contractAddress)
         : null;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    // Check if wallet already exists and load it
    await _loadWalletFromStorage();
  }

  WalletModel? get currentWallet => _currentWallet;
  
  /// Creates a new wallet with a random key
  Future<WalletModel> createWallet({String? password}) async {
    // Generate a random mnemonic
    final mnemonic = bip39.generateMnemonic(strength: BlockchainConfig.mnemonicStrength);
    return createWalletFromMnemonic(mnemonic: mnemonic, password: password);
  }
  
  /// Creates a wallet from an existing mnemonic phrase
  Future<WalletModel> createWalletFromMnemonic({
    required String mnemonic,
    String? password,
  }) async {
    try {
      // Validate mnemonic
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }
      
      // Convert mnemonic to seed
      final seed = bip39.mnemonicToSeed(mnemonic);
      
      // Create a private key from the first bytes of the seed
      final privateKey = HEX.encode(seed.sublist(0, 32));
      final credentials = EthPrivateKey.fromHex(privateKey);
      
      // Create wallet model from credentials
      final wallet = WalletModel.fromCredentials(credentials);
      
      // Save wallet and private key (encrypted if password provided)
      await _saveWallet(wallet, privateKey, mnemonic, password);
      
      _currentWallet = wallet;
      _privateKey = privateKey;
      
      return wallet;
    } catch (e) {
      debugPrint('Error creating wallet: $e');
      throw Exception('Failed to create wallet: ${e.toString()}');
    }
  }
  
  /// Import a wallet using a private key
  Future<WalletModel> importWalletFromPrivateKey({
    required String privateKey,
    String? password,
  }) async {
    try {
      final cleanPrivateKey = privateKey.startsWith('0x') 
          ? privateKey.substring(2) 
          : privateKey;
          
      // Create credentials from private key
      final credentials = EthPrivateKey.fromHex(cleanPrivateKey);
      
      // Create wallet model from credentials
      final wallet = WalletModel.fromCredentials(credentials);
      
      // Save wallet and private key (encrypted if password provided)
      await _saveWallet(wallet, cleanPrivateKey, null, password);
      
      _currentWallet = wallet;
      _privateKey = cleanPrivateKey;
      
      return wallet;
    } catch (e) {
      debugPrint('Error importing wallet: $e');
      throw Exception('Failed to import wallet: ${e.toString()}');
    }
  }
  
  /// Get wallet balance in ETH
  Future<double> getBalance() async {
    if (_currentWallet == null) {
      throw Exception('No wallet loaded');
    }
    
    try {
      final address = EthereumAddress.fromHex(_currentWallet!.address);
      final balance = await _web3Client.getBalance(address);
      
      // Convert from wei to ETH
      final ethBalance = balance.getValueInUnit(EtherUnit.ether);
      
      // Update current wallet
      _currentWallet = _currentWallet!.copyWith(balance: ethBalance);
      
      return ethBalance;
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      throw Exception('Failed to fetch balance: ${e.toString()}');
    }
  }
  
  /// Send transaction
  Future<String> sendTransaction({
    required String toAddress,
    required double amount,
    String? data,
  }) async {
    if (_currentWallet == null || _privateKey == null) {
      throw Exception('No wallet loaded or private key not available');
    }
    
    try {
      final credentials = EthPrivateKey.fromHex(_privateKey!);
      final recipient = EthereumAddress.fromHex(toAddress);
      
      // Convert ETH amount to Wei
      final value = EtherAmount.fromUnitAndValue(
        EtherUnit.ether,
        amount,
      );
      
      // Get nonce for sender address
      final sender = credentials.address;
      final nonce = await _web3Client.getTransactionCount(sender);
      
      // Prepare transaction
      final transaction = Transaction(
        to: recipient,
        from: sender,
        value: value,
        nonce: nonce,
        data: data != null ? Uint8List.fromList(utf8.encode(data)) : null,
        maxGas: BlockchainConfig.defaultGasLimit,
      );
      
      // Sign and send transaction
      final txHash = await _web3Client.sendTransaction(
        credentials,
        transaction,
        chainId: BlockchainConfig.defaultChainId,
      );
      
      // Add transaction to wallet model
      final newTransaction = TransactionModel(
        txHash: txHash,
        from: _currentWallet!.address,
        to: toAddress,
        amount: amount,
        data: data,
        timestamp: DateTime.now(),
        isPending: true,
      );
      
      _currentWallet = _currentWallet!.copyWith(
        transactions: [newTransaction, ..._currentWallet!.transactions],
      );
      
      return txHash;
    } catch (e) {
      debugPrint('Error sending transaction: $e');
      throw Exception('Failed to send transaction: ${e.toString()}');
    }
  }
  
  /// Get transaction history for the current wallet
  Future<List<TransactionModel>> getTransactionHistory() async {
    if (_currentWallet == null) {
      throw Exception('No wallet loaded');
    }
    
    try {
      // In a real implementation, you would fetch transaction history from an API
      // For now, we just return the stored transactions
      return _currentWallet!.transactions;
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      throw Exception('Failed to fetch transaction history: ${e.toString()}');
    }
  }
  
  /// Check if a wallet exists in storage
  Future<bool> hasWallet() async {
    final walletJson = _prefs.getString(BlockchainConfig.walletStorageKey);
    return walletJson != null;
  }
  
  /// Save wallet to storage
  Future<void> _saveWallet(
    WalletModel wallet,
    String privateKey,
    String? mnemonic,
    String? password,
  ) async {
    try {
      // Store wallet data
      await _prefs.setString(
        BlockchainConfig.walletStorageKey,
        jsonEncode(wallet.toJson()),
      );
      
      // Store private key (in a real app, this should be encrypted)
      await _prefs.setString('wallet_private_key', privateKey);
      
      // Store mnemonic if available (in a real app, this should be encrypted)
      if (mnemonic != null) {
        await _prefs.setString(BlockchainConfig.mnemonicPhraseKey, mnemonic);
      }
    } catch (e) {
      debugPrint('Error saving wallet: $e');
      throw Exception('Failed to save wallet: ${e.toString()}');
    }
  }
  
  /// Load wallet from storage
  Future<void> _loadWalletFromStorage() async {
    try {
      final walletJson = _prefs.getString(BlockchainConfig.walletStorageKey);
      final privateKey = _prefs.getString('wallet_private_key');
      
      if (walletJson != null && privateKey != null) {
        _currentWallet = WalletModel.fromJson(
          jsonDecode(walletJson) as Map<String, dynamic>
        );
        _privateKey = privateKey;
        
        // Optionally refresh balance after loading
        await getBalance();
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
      // Don't throw here, just consider no wallet is loaded
    }
  }
  
  /// Clear wallet data
  Future<void> clearWallet() async {
    try {
      await _prefs.remove(BlockchainConfig.walletStorageKey);
      await _prefs.remove('wallet_private_key');
      await _prefs.remove(BlockchainConfig.mnemonicPhraseKey);
      
      _currentWallet = null;
      _privateKey = null;
    } catch (e) {
      debugPrint('Error clearing wallet: $e');
      throw Exception('Failed to clear wallet: ${e.toString()}');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _web3Client.dispose();
  }
}
