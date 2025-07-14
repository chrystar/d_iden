import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/security_provider.dart';
import '../../domain/models/wallet.dart';
import '../../domain/models/wallet_transaction.dart';
import '../providers/wallet_provider.dart';
import 'transaction_history_screen.dart';
import 'send_transaction_screen.dart';
import 'receive_screen.dart';
import '../../../../../features/blockchain/presentation/screens/wallet_setup_screen.dart';
import 'package:d_iden/features/auth/presentation/providers/auth_provider.dart';

class WalletDashboardScreen extends StatefulWidget {
  static const routeName = '/wallet-dashboard';
  
  const WalletDashboardScreen({Key? key}) : super(key: key);

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  bool _isLoading = false;
  
  bool _authenticated = false;
  
  @override
  void initState() {
    super.initState();
    _authenticateAndLoadWallet();
  }
  
  Future<void> _authenticateAndLoadWallet() async {
    final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
    
    // Authenticate user with biometrics
    final authenticated = await securityProvider.authenticateWithBiometrics(
      reason: 'Authenticate to access your wallet'
    );
    
    if (authenticated) {
      setState(() {
        _authenticated = true;
      });
      _loadWalletData();
    } else {
      // If authentication fails, we'll show a message and not load the wallet data
      setState(() {
        _authenticated = false;
        _isLoading = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _loadWalletData() async {
    if (!_authenticated) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId == null) {
        throw Exception('No authenticated user found');
      }
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      
      // Check RPC connection first
      final isConnected = await walletProvider.checkConnection();
      if (!isConnected) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showNetworkErrorDialog();
          return;
        }
      }
      
      // Load wallet data
      await walletProvider.loadWallet(userId);
      await walletProvider.loadTransactions();
      
      // Make sure we've got the wallet data
      if (walletProvider.wallet == null) {
        // If wallet is still null after loading, something went wrong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load wallet data. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Wallet loaded successfully
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if this is a connection error
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('failed to fetch') || 
            errorMsg.contains('connection') || 
            errorMsg.contains('network') ||
            errorMsg.contains('project id')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network connection error. Please check your internet connection.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load wallet: ${e.toString()}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Force provider refresh by listening to wallet provider here
    Provider.of<WalletProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _authenticateAndLoadWallet,
          ),
          IconButton(
            icon: const Icon(Icons.fingerprint),
            onPressed: () => _authenticateAndLoadWallet(),
            tooltip: 'Authenticate again',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading wallet data...'),
                ],
              ),
            )
          : _authenticated
              ? _buildWalletContent()
              : _buildAuthenticationRequired(),
    );
  }
  
  Widget _buildAuthenticationRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Authentication Required',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'Please authenticate to access your wallet',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Authenticate',
            onPressed: _authenticateAndLoadWallet,
            isFullWidth: false,
            icon: Icons.fingerprint,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Network Connection Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We\'re having trouble connecting to the blockchain network. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Try Again',
            onPressed: _authenticateAndLoadWallet,
            isFullWidth: false,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWalletContent() {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallet = walletProvider.wallet;
    final transactions = walletProvider.transactions;
    final walletStatus = walletProvider.status;
    
    if (walletStatus == WalletStatus.networkError) {
      return _buildNetworkErrorView();
    } else if (wallet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You don\'t have a wallet yet'),
            const SizedBox(height: 16),
            AppButton(
              text: 'Create Wallet',
              onPressed: () async {
                final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No authenticated user found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WalletSetupScreen(),
                  ),
                );
                if (result == true) {
                  await _loadWalletData();
                }
              },
              isFullWidth: false,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadWalletData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(wallet),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildActivityChart(transactions),
            const SizedBox(height: 24),
            _buildRecentTransactions(transactions),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBalanceCard(Wallet wallet) {
    final currencyFormat = NumberFormat.currency(symbol: 'ETH ', decimalDigits: 4);
    
    return GradientAppCard(
      gradientColors: const [AppColors.primary, AppColors.secondary],
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                wallet.type.toString().split('.').last,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  wallet.network,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Balance',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(wallet.balance),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Address: ${_shortenAddress(wallet.address)}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  String _shortenAddress(String? address) {
    if (address == null) return 'Unknown Address';
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.arrow_upward,
          label: 'Send',
          color: AppColors.primary,
          onTap: () async {
            // Require authentication again for sending money (additional security)
            final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
            final authenticated = await securityProvider.authenticateWithBiometrics(
              reason: 'Authenticate to send funds'
            );
            
            if (authenticated && mounted) {
              Navigator.of(context).pushNamed(SendTransactionScreen.routeName);
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication required to send funds'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        _buildActionButton(
          icon: Icons.arrow_downward,
          label: 'Receive',
          color: AppColors.secondary,
          onTap: () async {
            // Authentication for receiving might not be as critical as sending,
            // but still adding it for consistency in security
            final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
            final authenticated = await securityProvider.authenticateWithBiometrics(
              reason: 'Authenticate to view receive address'
            );
            
            if (authenticated && mounted) {
              Navigator.of(context).pushNamed(ReceiveScreen.routeName);
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication required to view receive address'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        _buildActionButton(
          icon: Icons.history,
          label: 'History',
          color: AppColors.accent,
          onTap: () async {
            // For viewing transaction history, we still require authentication
            // since transaction history contains sensitive financial information
            final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
            final authenticated = await securityProvider.authenticateWithBiometrics(
              reason: 'Authenticate to view transaction history'
            );
            
            if (authenticated && mounted) {
              Navigator.of(context).pushNamed(TransactionHistoryScreen.routeName);
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication required to view transaction history'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityChart(List<WalletTransaction> transactions) {
    // Process transaction data for chart
    final transactionData = _processTransactionDataForChart(transactions);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: transactionData.isEmpty
                ? const Center(
                    child: Text('No transaction data to display'),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < transactionData.length) {
                                final date = DateFormat('dd/MM').format(transactionData[value.toInt()].date);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    date,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 0.5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: AppColors.divider, width: 1),
                          left: BorderSide(color: AppColors.divider, width: 1),
                        ),
                      ),
                      minX: 0,
                      maxX: transactionData.length.toDouble() - 1,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            transactionData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              transactionData[index].amount,
                            ),
                          ),
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.secondary.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  List<TransactionChartData> _processTransactionDataForChart(List<WalletTransaction> transactions) {
    if (transactions.isEmpty) {
      return [];
    }
    
    // Sort transactions by date
    final sortedTransactions = List<WalletTransaction>.from(transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Group by date and calculate daily amounts
    final Map<String, double> dailyAmounts = {};
    
    for (final tx in sortedTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.timestamp);
      
      if (!dailyAmounts.containsKey(dateKey)) {
        dailyAmounts[dateKey] = 0;
      }
      
      if (tx.type == TransactionType.receive) {
        dailyAmounts[dateKey] = (dailyAmounts[dateKey]! + tx.amount);
      } else {
        dailyAmounts[dateKey] = (dailyAmounts[dateKey]! - tx.amount);
      }
    }
    
    // Convert to list of chart data
    final chartData = dailyAmounts.entries.map((entry) {
      return TransactionChartData(
        date: DateFormat('yyyy-MM-dd').parse(entry.key),
        amount: entry.value,
      );
    }).toList();
    
    // Sort by date
    chartData.sort((a, b) => a.date.compareTo(b.date));
    
    // Limit to last 7 days
    if (chartData.length > 7) {
      return chartData.sublist(chartData.length - 7);
    }
    
    return chartData;
  }
  
  Widget _buildRecentTransactions(List<WalletTransaction> transactions) {
    final recentTransactions = transactions.length > 5
        ? transactions.sublist(0, 5)
        : transactions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () async {
                final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
                final authenticated = await securityProvider.authenticateWithBiometrics(
                  reason: 'Authenticate to view all transactions'
                );
                
                if (authenticated && mounted) {
                  Navigator.of(context).pushNamed(TransactionHistoryScreen.routeName);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentication required to view transactions'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recentTransactions.isEmpty
            ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.hourglass_empty,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
      ],
    );
  }
  
  Widget _buildTransactionItem(WalletTransaction transaction) {
    final isSend = transaction.type == TransactionType.send;
    final amountText = '${isSend ? '-' : '+'} ${transaction.amount.toStringAsFixed(4)} ${transaction.currency}';
    final amountColor = isSend ? AppColors.error : AppColors.success;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
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
      title: Text(
        isSend ? 'Sent to ${_shortenAddress(transaction.toAddress)}' : 'Received',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        DateFormat('MMM d, yyyy • h:mm a').format(transaction.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        amountText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
      ),
      onTap: () {
        // Navigate to transaction details
      },
    );
  }
  
  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Network Connection Error'),
          content: const Text(
            'Unable to connect to the blockchain network. Please check your internet connection and try again later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class TransactionChartData {
  final DateTime date;
  final double amount;
  
  TransactionChartData({
    required this.date,
    required this.amount,
  });
}
