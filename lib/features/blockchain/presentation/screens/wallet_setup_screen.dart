import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/blockchain_provider.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:d_iden/features/auth/presentation/providers/auth_provider.dart';
import 'package:d_iden/features/wallet/presentation/providers/wallet_provider.dart';

class WalletSetupScreen extends StatefulWidget {
  const WalletSetupScreen({Key? key}) : super(key: key);

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  final _mnemonicController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _pinController = TextEditingController();
  String _selectedTab = 'create';
  bool _isLoading = false;

  @override
  void dispose() {
    _mnemonicController.dispose();
    _privateKeyController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Setup'),
        elevation: 0,
      ),
      body: Consumer<BlockchainProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTabSelector(),
                const SizedBox(height: 24),
                
                // Error message
                if (provider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                
                // Content based on selected tab
                if (_selectedTab == 'create')
                  _buildCreateWalletTab(provider),
                if (_selectedTab == 'recover')
                  _buildRecoverWalletTab(provider),
                if (_selectedTab == 'import')
                  _buildImportWalletTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabSelector() {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabButton('Create New', 'create'),
            _buildTabButton('Recover', 'recover'),
            _buildTabButton('Import', 'import'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String value) {
    final isSelected = _selectedTab == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateWalletTab(BlockchainProvider provider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create a new wallet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This will generate a new wallet with a secure recovery phrase. Make sure to back up your recovery phrase in a safe place.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(
              labelText: 'Set a 6-digit PIN',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _createWallet(provider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Create New Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoverWalletTab(BlockchainProvider provider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recover with Mnemonic Phrase',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your 12-word recovery phrase to restore your wallet.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mnemonicController,
            decoration: InputDecoration(
              hintText: 'Enter 12-word mnemonic phrase',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _recoverWallet(provider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Recover Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportWalletTab(BlockchainProvider provider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Import with Private Key',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your private key to import your existing wallet.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _privateKeyController,
            decoration: InputDecoration(
              hintText: 'Enter private key (hex format)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _importWallet(provider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Import Wallet'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWallet(BlockchainProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    final pin = _pinController.text.trim();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit PIN.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<WalletProvider>(context, listen: false).createWallet(userId, pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating wallet:  e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _recoverWallet(BlockchainProvider provider) async {
    if (_mnemonicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mnemonic phrase'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await provider.importWalletFromMnemonic(
        mnemonic: _mnemonicController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet recovered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recovering wallet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importWallet(BlockchainProvider provider) async {
    if (_privateKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your private key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await provider.importWalletFromPrivateKey(
        privateKey: _privateKeyController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing wallet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
