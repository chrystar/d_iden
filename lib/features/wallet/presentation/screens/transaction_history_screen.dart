import 'package:d_iden/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/wallet_transaction.dart';
import '../providers/wallet_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static const routeName = '/transaction-history';
  
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<WalletTransaction> _filteredTransactions = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _filterTransactions();
    });
    
    // Initialize filtered transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterTransactions();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterTransactions() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final allTransactions = walletProvider.transactions;
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      switch (_tabController.index) {
        case 0: // All
          _filteredTransactions = allTransactions.where((tx) {
            return searchQuery.isEmpty || 
                (tx.toAddress != null && tx.toAddress!.toLowerCase().contains(searchQuery)) ||
                (tx.fromAddress != null && tx.fromAddress!.toLowerCase().contains(searchQuery)) ||
                (tx.hash?.toLowerCase().contains(searchQuery) ?? false) ||
                (tx.note != null ? tx.note!.toLowerCase().contains(searchQuery) : false);
          }).toList();
          break;
        case 1: // Sent
          _filteredTransactions = allTransactions.where((tx) {
            return tx.type == TransactionType.send && 
                (searchQuery.isEmpty || 
                (tx.toAddress != null && tx.toAddress!.toLowerCase().contains(searchQuery)) ||
                (tx.hash?.toLowerCase().contains(searchQuery) ?? false) ||
                (tx.note != null ? tx.note!.toLowerCase().contains(searchQuery) : false));
          }).toList();
          break;
        case 2: // Received
          _filteredTransactions = allTransactions.where((tx) {
            return tx.type == TransactionType.receive && 
                (searchQuery.isEmpty || 
                (tx.fromAddress != null && tx.fromAddress!.toLowerCase().contains(searchQuery)) ||
                (tx.hash?.toLowerCase().contains(searchQuery) ?? false) ||
                (tx.note != null ? tx.note!.toLowerCase().contains(searchQuery) : false));
          }).toList();
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchField(
              controller: _searchController,
              hintText: 'Search by address, hash, or note',
              onChanged: (value) {
                _filterTransactions();
              },
              onClear: _filterTransactions,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_filteredTransactions),
                _buildTransactionList(_filteredTransactions),
                _buildTransactionList(_filteredTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionList(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }
  
  Widget _buildTransactionCard(WalletTransaction transaction) {
    final isSend = transaction.type == TransactionType.send;
    final amountText = '${isSend ? '-' : '+'} ${transaction.amount.toStringAsFixed(6)} ${transaction.currency}';
    final amountColor = isSend ? AppColors.error : AppColors.success;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    return GestureDetector(
      onTap: () {
        _showTransactionDetailsDialog(transaction);
      },
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSend ? Icons.arrow_upward : Icons.arrow_downward,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSend 
                        ? 'Sent to ${transaction.toAddress != null ? _shortenAddress(transaction.toAddress!) : 'Unknown'}'
                        : 'Received',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${transaction.note}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTransactionDetailsDialog(WalletTransaction transaction) {
    final isSend = transaction.type == TransactionType.send;
    final amountText = '${isSend ? '-' : '+'} ${transaction.amount.toStringAsFixed(6)} ${transaction.currency}';
    final amountColor = isSend ? AppColors.error : AppColors.success;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSend ? Icons.arrow_upward : Icons.arrow_downward,
                      color: amountColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amountText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Status', transaction.status.toString().split('.').last.toUpperCase()),
              _buildDetailRow('Date', dateFormat.format(transaction.timestamp)),
              _buildDetailRow('Type', isSend ? 'Sent' : 'Received'),
              _buildAddressDetailRow(context, 'From', transaction.fromAddress),
              _buildAddressDetailRow(context, 'To', transaction.toAddress),
              if (transaction.hash != null)
                _buildAddressDetailRow(context, 'Hash', transaction.hash!),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _buildDetailRow('Note', transaction.note!),
              _buildDetailRow('Network Fee', '0.001 ETH'),
              const SizedBox(height: 24),
              AppButton(
                text: 'View on Block Explorer',
                onPressed: () {
                  // Open in browser
                },
                isOutlined: true,
                icon: Icons.open_in_new,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
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
  
  Widget _buildAddressDetailRow(BuildContext context, String label, String? value) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value != null ? _shortenAddress(value) : 'N/A',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy,
              size: 16,
              color: AppColors.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (value != null) {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
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
