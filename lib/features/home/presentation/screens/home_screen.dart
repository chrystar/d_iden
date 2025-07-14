import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:d_iden/features/identity/presentation/screens/identity_dashboard_screen.dart';
import 'package:d_iden/features/wallet/presentation/screens/wallet_dashboard_screen.dart';
import 'package:d_iden/features/settings/presentation/screens/app_settings_screen.dart';
import 'package:d_iden/features/settings/presentation/screens/security_settings_screen.dart';
import 'package:d_iden/features/settings/presentation/providers/settings_provider.dart';
import 'package:d_iden/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:d_iden/features/blockchain/presentation/screens/wallet_setup_screen.dart';
import 'package:d_iden/features/blockchain/presentation/screens/did_setup_screen.dart';
import 'package:d_iden/features/account/presentation/screens/account_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const IdentityDashboardScreen(),
    const WalletDashboardScreen(),
    const _SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load settings when home screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
      
      // Check if blockchain wallet is set up
      final blockchainProvider = Provider.of<BlockchainProvider>(context, listen: false);
      if (blockchainProvider.wallet == null) {
        // Show wallet setup dialog
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showWalletSetupDialog();
          }
        });
      }
    });
  }
  
  void _showWalletSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Blockchain Wallet Setup'),
        content: const Text(
          'To use decentralized identity features, you need to set up a blockchain wallet. Would you like to set it up now?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WalletSetupScreen(),
                ),
              ).then((walletCreated) {
                if (walletCreated == true) {
                  // If wallet was created, show DID setup
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DIDSetupScreen(),
                    ),
                  );
                }
              });
            },
            child: const Text('Set Up Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Identity',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSettingCard(
              context,
              'App Settings',
              'Theme, notifications, and display preferences',
              Icons.palette_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              context,
              'Security & Privacy',
              'PIN, biometrics, and privacy settings',
              Icons.security_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
              ),
            ),
            const SizedBox(height: 16),              _buildSettingCard(
                context,
                'Blockchain Wallet',
                'Connect or manage your blockchain wallet',
                Icons.account_balance_wallet_outlined,
                () {
                  final blockchainProvider = Provider.of<BlockchainProvider>(context, listen: false);
                  if (blockchainProvider.wallet == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WalletSetupScreen()),
                    ).then((walletCreated) {
                      if (walletCreated == true && blockchainProvider.did == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DIDSetupScreen()),
                        );
                      }
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DIDSetupScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                'Account',
                'View and manage your account details',
                Icons.account_circle_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountManagementScreen()),
                  );
                },
              ),
            const SizedBox(height: 16),
            _buildSettingCard(
              context,
              'Help & Support',
              'Get help with using the app',
              Icons.help_outline,
              () {
                // This would navigate to a help page in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help center will be available in future updates'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
