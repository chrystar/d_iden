import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:d_iden/features/blockchain/presentation/providers/blockchain_provider.dart';

class WalletAndDIDManagementScreen extends StatefulWidget {
  const WalletAndDIDManagementScreen({Key? key}) : super(key: key);

  @override
  State<WalletAndDIDManagementScreen> createState() => _WalletAndDIDManagementScreenState();
}

class _WalletAndDIDManagementScreenState extends State<WalletAndDIDManagementScreen> {
  bool _isLoading = false;

  Future<void> _refreshWallet(BlockchainProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await provider.refreshWalletBalance();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _clearWalletAndDID(BlockchainProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wallet & DID'),
        content: const Text('Are you sure you want to clear your wallet and DID? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await provider.clearWalletAndDID();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wallet and DID cleared.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet & DID Management')),
      body: Consumer<BlockchainProvider>(
        builder: (context, provider, child) {
          final wallet = provider.wallet;
          final did = provider.did;
          final error = provider.error;
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(error, style: TextStyle(color: Colors.red[700])),
                      ),
                    Card(
                      child: ListTile(
                        title: const Text('Wallet Address'),
                        subtitle: Text(wallet?.address ?? 'No wallet'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: wallet != null
                              ? () {
                                  Clipboard.setData(ClipboardData(text: wallet.address));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Address copied!'), duration: Duration(seconds: 1)),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Wallet Balance'),
                        subtitle: Text(wallet != null ? '${wallet.balance} ETH' : '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: wallet != null && !_isLoading
                              ? () => _refreshWallet(provider)
                              : null,
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('DID'),
                        subtitle: Text(did?.did ?? 'No DID'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: did != null
                              ? () {
                                  Clipboard.setData(ClipboardData(text: did.did));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('DID copied!'), duration: Duration(seconds: 1)),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear Wallet & DID'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _isLoading ? null : () => _clearWalletAndDID(provider),
                    ),
                  ],
                );
        },
      ),
    );
  }
} 