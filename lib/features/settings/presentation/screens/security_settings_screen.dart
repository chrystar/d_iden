import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/settings_provider.dart';
import '../../../../core/providers/security_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        elevation: 0,
      ),
      body: settingsProvider.isLoaded 
        ? FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader(context, 'Authentication'),
                _buildPinRequirementSetting(context, settingsProvider),
                _buildBiometricSetting(context, settingsProvider),
                const SizedBox(height: 24),
                
                _buildSectionHeader(context, 'Privacy'),
                _buildPrivacySetting(context),
                const SizedBox(height: 24),
                
                _buildSectionHeader(context, 'Advanced Security'),
                _buildBackupSetting(context),
                _buildRecoverySetting(context),
                const SizedBox(height: 32),
                
                _buildResetButton(context, settingsProvider),
                const SizedBox(height: 16),
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

  Widget _buildPinRequirementSetting(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Always Require PIN'),
            subtitle: const Text('PIN required for all app access'),
            value: 'always',
            groupValue: settingsProvider.pinRequirement,
            onChanged: (String? value) {
              if (value != null) {
                settingsProvider.setPinRequirement(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Transactions Only'),
            subtitle: const Text('PIN required only for transactions'),
            value: 'transactions',
            groupValue: settingsProvider.pinRequirement,
            onChanged: (String? value) {
              if (value != null) {
                settingsProvider.setPinRequirement(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Disabled'),
            subtitle: const Text('WARNING: Not recommended'),
            value: 'disabled',
            groupValue: settingsProvider.pinRequirement,
            onChanged: (String? value) {
              if (value != null) {
                // Show warning dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Security Warning'),
                    content: const Text(
                      'Disabling PIN protection significantly reduces security. Are you sure you want to continue?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          settingsProvider.setPinRequirement(value);
                        },
                        child: const Text('Disable PIN'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSetting(BuildContext context, SettingsProvider settingsProvider) {
    final securityProvider = Provider.of<SecurityProvider>(context);
    
    if (!securityProvider.biometricsAvailable) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const ListTile(
          title: Text('Biometric Authentication'),
          subtitle: Text('Not available on this device'),
          enabled: false,
          leading: Icon(Icons.fingerprint),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text('Biometric Authentication'),
        subtitle: const Text('Use fingerprint or face recognition'),
        value: securityProvider.biometricsEnabled,
        onChanged: (bool value) async {
          await securityProvider.setBiometricsEnabled(value);
          
          // Also update settings provider for backwards compatibility
          settingsProvider.setBiometricStatus(
            value ? BiometricStatus.enabled : BiometricStatus.disabled
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value 
                    ? 'Biometric authentication enabled' 
                    : 'Biometric authentication disabled'
              ),
              backgroundColor: value ? Colors.green : Colors.orange,
            ),
          );
        },
        secondary: const Icon(Icons.fingerprint),
      ),
    );
  }

  Widget _buildPrivacySetting(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Privacy Policy'),
        subtitle: const Text('Review our privacy policy'),
        trailing: const Icon(Icons.chevron_right),
        leading: const Icon(Icons.privacy_tip_outlined),
        onTap: () {
          // Navigate to privacy policy screen or open web view
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Privacy Policy'),
              content: const SingleChildScrollView(
                child: Text(
                  'This would typically contain the full privacy policy text or link to an external policy page. For this example, this is a placeholder for the privacy policy content.',
                ),
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

  Widget _buildBackupSetting(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Backup Wallet & Credentials'),
        subtitle: const Text('Create an encrypted backup of your data'),
        trailing: const Icon(Icons.chevron_right),
        leading: const Icon(Icons.backup),
        onTap: () {
          // Navigate to backup screen or show backup options
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup feature will be available in future updates'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecoverySetting(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Recovery Options'),
        subtitle: const Text('Set up or manage recovery methods'),
        trailing: const Icon(Icons.chevron_right),
        leading: const Icon(Icons.restore),
        onTap: () {
          // Navigate to recovery screen or show recovery options
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recovery options will be available in future updates'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, SettingsProvider settingsProvider) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Reset All Security Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          // Show warning dialog before resetting
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Security Settings'),
              content: const Text(
                'This will reset all security settings to their default values. This action cannot be undone.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Reset security settings
                    settingsProvider.setPinRequirement('always');
                    settingsProvider.setBiometricStatus(BiometricStatus.disabled);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Security settings have been reset'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
