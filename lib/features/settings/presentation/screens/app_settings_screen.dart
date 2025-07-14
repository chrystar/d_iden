import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/settings_provider.dart';
import 'package:d_iden/features/wallet_and_did/presentation/wallet_and_did_management_screen.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        elevation: 0,
      ),
      body: settingsProvider.isLoaded 
        ? FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader(context, 'Appearance'),
                _buildThemeSetting(context, settingsProvider),
                const SizedBox(height: 24),
                
                _buildSectionHeader(context, 'Notifications'),
                _buildNotificationsSetting(context, settingsProvider),
                const SizedBox(height: 24),
                
                _buildSectionHeader(context, 'About'),
                _buildAboutTile(context),
                _buildVersionTile(context),
                _buildSettingCard(
                  context,
                  'Wallet & DID Management',
                  'View and manage your blockchain wallet and DID',
                  Icons.account_balance_wallet,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WalletAndDIDManagementScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System Theme'),
            subtitle: const Text('Follow system settings'),
            value: ThemeMode.system,
            groupValue: settingsProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                settingsProvider.setThemeMode(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: const Text('Light Theme'),
            value: ThemeMode.light,
            groupValue: settingsProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                settingsProvider.setThemeMode(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Theme'),
            value: ThemeMode.dark,
            groupValue: settingsProvider.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                settingsProvider.setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSetting(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text('Push Notifications'),
        subtitle: const Text('Receive updates about transactions and credentials'),
        value: settingsProvider.notificationsEnabled,
        onChanged: (bool value) {
          settingsProvider.setNotificationsEnabled(value);
        },
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('About D-Iden'),
        leading: const Icon(Icons.info_outline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to About page or show dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('About D-Iden'),
              content: const Text(
                'D-Iden is a digital identity wallet that helps you securely manage your digital identities and credentials.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const ListTile(
        title: Text('App Version'),
        subtitle: Text('1.0.0'),
        leading: Icon(Icons.engineering),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon),
        onTap: onTap,
      ),
    );
  }
}
