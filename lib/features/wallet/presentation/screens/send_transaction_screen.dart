import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';

class SendTransactionScreen extends StatefulWidget {
  static const routeName = '/send-transaction';
  
  const SendTransactionScreen({Key? key}) : super(key: key);

  @override
  State<SendTransactionScreen> createState() => _SendTransactionScreenState();
}

class _SendTransactionScreenState extends State<SendTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _pinController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPinEntry = false;
  
  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    super.dispose();
  }
  
  void _processTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _showPinEntry = true;
      });
    }
  }
  
  Future<void> _confirmTransaction() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your PIN')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    try {
      final toAddress = _addressController.text.trim();
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null;
      
      final transaction = await walletProvider.sendTransaction(
        pin,
        toAddress,
        amount,
        note: note,
      );
      
      if (transaction != null) {
        setState(() {
          _isLoading = false;
          _showPinEntry = false;
        });
        
        // Clear form and show success message
        _addressController.clear();
        _amountController.clear();
        _noteController.clear();
        _pinController.clear();
        
        if (!mounted) return;
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Transaction Sent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your transaction has been sent successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ${transaction.amount} ${transaction.currency}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Transaction ID: ${_shortenHash(transaction.hash)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        
        // Show error message
        final error = walletProvider.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Transaction failed')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  String _shortenHash(String? hash) {
    if (hash == null || hash.length < 20) return hash ?? 'N/A';
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 10)}';
  }
  
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
      ),
      body: _showPinEntry ? _buildPinEntryUI() : _buildTransactionFormUI(),
    );
  }
  
  Widget _buildTransactionFormUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Recipient Address',
              hint: '0x...',
              controller: _addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a recipient address';
                }
                
                if (!value.startsWith('0x') || value.length < 40) {
                  return 'Please enter a valid Ethereum address';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Amount',
              hint: '0.0',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                
                try {
                  final amount = double.parse(value);
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  
                  final wallet = Provider.of<WalletProvider>(context, listen: false).wallet;
                  if (wallet != null && amount > wallet.balance) {
                    return 'Amount exceeds available balance';
                  }
                } catch (e) {
                  return 'Please enter a valid number';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Note (optional)',
              hint: 'Add a note to this transaction',
              controller: _noteController,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            Consumer<WalletProvider>(
              builder: (context, walletProvider, child) {
                final wallet = walletProvider.wallet;
                return wallet != null
                    ? Text(
                        'Available Balance: ${wallet.balance.toStringAsFixed(6)} ETH',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      )
                    : const SizedBox();
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Review Transaction',
              onPressed: _isLoading ? null : _processTransaction,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPinEntryUI() {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallet = walletProvider.wallet;
    final amount = _amountController.text.trim();
    final address = _addressController.text.trim();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm Transaction',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTransactionSummaryCard(address, amount),
          const SizedBox(height: 32),
          const Text(
            'Enter your PIN to confirm this transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'PIN',
            hint: '******',
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  onPressed: () {
                    setState(() {
                      _showPinEntry = false;
                      _pinController.clear();
                    });
                  },
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Confirm',
                  onPressed: _isLoading ? null : _confirmTransaction,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionSummaryCard(String address, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransactionDetail('From', _shortenAddress(Provider.of<WalletProvider>(context).wallet?.address ?? '')),
          const Divider(),
          _buildTransactionDetail('To', _shortenAddress(address)),
          const Divider(),
          _buildTransactionDetail('Amount', '$amount ETH'),
          if (_noteController.text.isNotEmpty) ...[
            const Divider(),
            _buildTransactionDetail('Note', _noteController.text),
          ],
          const Divider(),
          _buildTransactionDetail('Network', 'Polygon Mumbai'),
          const Divider(),
          _buildTransactionDetail('Fee', '~0.001 ETH'),
        ],
      ),
    );
  }
  
  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  String _shortenAddress(String address) {
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}
