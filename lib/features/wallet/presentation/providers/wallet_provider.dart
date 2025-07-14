import 'package:flutter/material.dart';
import '../../domain/models/wallet.dart';
import '../../domain/models/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

enum WalletStatus {
  initial,
  loading,
  loaded,
  unlocked,
  locked,
  error,
  networkError,
}

class WalletProvider extends ChangeNotifier {
  final WalletRepository? _walletRepository;
  
  WalletStatus _status = WalletStatus.initial;
  Wallet? _wallet;
  List<WalletTransaction> _transactions = [];
  String? _error;
  bool _isUnlocked = false;
  
  WalletProvider({WalletRepository? walletRepository})
      : _walletRepository = walletRepository;
  
  // Getters
  WalletStatus get status => _status;
  Wallet? get wallet => _wallet;
  List<WalletTransaction> get transactions => _transactions;
  String? get error => _error;
  bool get isUnlocked => _isUnlocked;
  
  // Will implement actual methods when we implement the repository
  // For now, we'll just have placeholder methods
  
  Future<void> loadWallet(String userId) async {
    _status = WalletStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_walletRepository != null) {
        _wallet = await _walletRepository.getWallet(userId);
        
        if (_wallet != null) {
          try {
            await refreshWalletBalance();
          } catch (e) {
            // Handle balance refresh errors separately
            if (e.toString().toLowerCase().contains('network connection error')) {
              _error = 'Network connection error. Please check your internet connection.';
              _status = WalletStatus.networkError;
            }
          }
          
          try {
            await loadTransactions();
          } catch (e) {
            // Handle transaction loading errors separately
            if (_status != WalletStatus.networkError) {
              _error = e.toString();
              _status = WalletStatus.error;
            }
          }
        }
      }
      
      if (_status != WalletStatus.networkError && _status != WalletStatus.error) {
        _status = WalletStatus.loaded;
      }
    } catch (e) {
      _error = e.toString();
      if (_error!.toLowerCase().contains('network connection error')) {
        _status = WalletStatus.networkError;
      } else {
        _status = WalletStatus.error;
      }
    }
    
    notifyListeners();
  }
  
  Future<void> createWallet(String userId, String pin) async {
    _status = WalletStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_walletRepository != null) {
        _wallet = await _walletRepository.createWallet(userId, pin);
        _transactions = [];
        _isUnlocked = true;
        _status = WalletStatus.unlocked;
      }
    } catch (e) {
      _error = e.toString();
      _status = WalletStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> unlockWallet(String pin) async {
    if (_wallet == null) return;
    
    _status = WalletStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_walletRepository != null) {
        _isUnlocked = await _walletRepository.unlockWallet(_wallet!.id, pin);
        _status = _isUnlocked ? WalletStatus.unlocked : WalletStatus.locked;
      }
    } catch (e) {
      _error = e.toString();
      _status = WalletStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> lockWallet() async {
    if (_wallet == null) return;
    
    _status = WalletStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_walletRepository != null) {
        await _walletRepository.lockWallet(_wallet!.id);
        _isUnlocked = false;
        _status = WalletStatus.locked;
      }
    } catch (e) {
      _error = e.toString();
      _status = WalletStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> refreshWalletBalance() async {
    if (_wallet == null) return;
    
    try {
      if (_walletRepository != null) {
        final balance = await _walletRepository.getWalletBalance(_wallet!.id);
        _wallet = _wallet!.copyWith(balance: balance);
      }
    } catch (e) {
      _error = e.toString();
      if (_error!.toLowerCase().contains('network connection error')) {
        _status = WalletStatus.networkError;
      }
    }
    
    notifyListeners();
  }
  
  Future<void> loadTransactions() async {
    if (_wallet == null) return;
    
    try {
      if (_walletRepository != null) {
        _transactions = await _walletRepository.getTransactions(_wallet!.id);
      }
    } catch (e) {
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<WalletTransaction?> sendTransaction(
    String pin,
    String toAddress,
    double amount,
    {String? note}
  ) async {
    if (_wallet == null || !_isUnlocked) return null;
    
    _status = WalletStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      if (_walletRepository != null) {
        final transaction = await _walletRepository.sendTransaction(
          _wallet!.id,
          pin,
          toAddress,
          amount,
          'ETH', // Default currency
          note: note,
        );
        
        _transactions.insert(0, transaction);
        await refreshWalletBalance();
        
        _status = WalletStatus.unlocked;
        return transaction;
      }
    } catch (e) {
      _error = e.toString();
      _status = WalletStatus.error;
    }
    
    notifyListeners();
    return null;
  }
  
  /// Check if the RPC connection is available
  Future<bool> checkConnection() async {
    try {
      if (_walletRepository != null) {
        return await _walletRepository.checkRpcConnection();
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
  
  // Reset error state
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
