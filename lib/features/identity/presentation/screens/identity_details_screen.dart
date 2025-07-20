import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/digital_identity.dart';
import '../../../../features/blockchain/presentation/providers/blockchain_provider.dart';
import '../../../../features/blockchain/presentation/screens/did_setup_screen.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/security_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/identity_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IdentityDetailsScreen extends StatefulWidget {
  static const routeName = '/identity-details';
  
  final DigitalIdentity identity;
  
  const IdentityDetailsScreen({
    Key? key,
    required this.identity,
  }) : super(key: key);

  @override
  State<IdentityDetailsScreen> createState() => _IdentityDetailsScreenState();
}

class _IdentityDetailsScreenState extends State<IdentityDetailsScreen> {
  bool _isLoading = true;
  final SecurityService _securityService = SecurityService();
  
  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity card shimmer with animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: ShimmerLoading(
              isLoading: true,
              baseColor: AppColors.primary.withOpacity(0.2),
              highlightColor: AppColors.secondary.withOpacity(0.2),
              period: const Duration(milliseconds: 1800),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.secondary.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const ShimmerIdentityCard(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // QR code shimmer with animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: ShimmerLoading(
              isLoading: true,
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerBox(
                      width: 220,
                      height: 220,
                      borderRadius: 8,
                    ),
                    SizedBox(height: 16),
                    ShimmerBox(
                      width: 180,
                      height: 20,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title shimmer with animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: ShimmerLoading(
              isLoading: true,
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const ShimmerBox(width: 150, height: 24, borderRadius: 4),
            ),
          ),
          const SizedBox(height: 16),
          // Details shimmer with animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: ShimmerLoading(
              isLoading: true,
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 120, height: 18),
                    const SizedBox(height: 12),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 16),
                    const ShimmerBox(width: 100, height: 18),
                    const SizedBox(height: 12),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 180, height: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Blockchain status shimmer with animation
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: ShimmerLoading(
              isLoading: true,
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        ShimmerBox(
                          width: 30,
                          height: 30,
                          borderRadius: 15,
                        ),
                        SizedBox(width: 12),
                        ShimmerBox(width: 150, height: 18),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 120, height: 14),
                        ShimmerBox(width: 80, height: 24, borderRadius: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Details'),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: _buildIdentityCard(context),
                    ),
                    const SizedBox(height: 24),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: _buildIdentityQrCode(context),
                    ),
                    const SizedBox(height: 24),
                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      child: _buildIdentityDetails(context),
                    ),
                    const SizedBox(height: 24),
                    FadeInDown(
                      delay: const Duration(milliseconds: 500),
                      child: _buildBlockchainStatus(context),
                    ),
                    const SizedBox(height: 32),
                    FadeInDown(
                      delay: const Duration(milliseconds: 600),
                      child: _buildActionButtons(context),
                    ),
                  ],
                ),
              ),
      ),
    );
         
  }
  
  Widget _buildIdentityCard(BuildContext context) {
    return GradientAppCard(
      gradientColors: const [AppColors.primary, AppColors.secondary],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Decentralized Identity',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.identity.isActive ? 'Active since ${_formatDate(widget.identity.created)}' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'DID',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.identity.did,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.identity.did));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DID copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildIdentityQrCode(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Identity QR Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use this to quickly share your decentralized identity',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: QrImageView(
              data: widget.identity.did,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AppButton(
              text: 'Download QR Code',
              icon: Icons.download,
              onPressed: () {
                // Implement QR code image download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code download feature coming soon')),
                );
              },
              isFullWidth: false,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIdentityDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _buildDetailRow(
                'Created On',
                _formatDateFull(widget.identity.created),
                Icons.calendar_today,
              ),
              const Divider(),
              _buildDetailRow(
                'Status',
                widget.identity.isActive ? 'Active' : 'Inactive',
                Icons.check_circle,
                valueColor: widget.identity.isActive ? AppColors.success : AppColors.error,
              ),
              const Divider(),
              _buildDetailRow(
                'Public Key Type',
                'Ed25519',  // Example key type
                Icons.key,
              ),
              const Divider(),
              _buildDetailRow(
                'Blockchain',
                'Ethereum',  // Example blockchain
                Icons.link,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String title, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportIdentityData(BuildContext context) async {
    final exportOptions = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        final selections = <String>{'identity', 'wallet', 'credentials'};
        return AlertDialog(
          title: const Text('Select Data to Export'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  value: selections.contains('identity'),
                  title: const Text('Identity'),
                  onChanged: (v) => setState(() => v! ? selections.add('identity') : selections.remove('identity')),
                ),
                CheckboxListTile(
                  value: selections.contains('wallet'),
                  title: const Text('Wallet'),
                  onChanged: (v) => setState(() => v! ? selections.add('wallet') : selections.remove('wallet')),
                ),
                CheckboxListTile(
                  value: selections.contains('credentials'),
                  title: const Text('Credentials'),
                  onChanged: (v) => setState(() => v! ? selections.add('credentials') : selections.remove('credentials')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, selections.toList()), child: const Text('Next')),
          ],
        );
      },
    );
    if (exportOptions == null || exportOptions.isEmpty) return;
    // Prompt for filename
    final filename = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: 'diden_backup.didb');
        return AlertDialog(
          title: const Text('Enter Backup Filename'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Filename'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
          ],
        );
      },
    );
    if (filename == null || filename.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      await _securityService.initialize();
      final prefs = await SharedPreferences.getInstance();
      final backupData = <String, dynamic>{};
      if (exportOptions.contains('identity')) {
        backupData['identities'] = prefs.getString('digital_identities') ?? '{}';
        backupData['identity_keys'] = prefs.getString('identity_keys') ?? '{}';
        backupData['did_document'] = prefs.getString('did_document') ?? '{}';
      }
      if (exportOptions.contains('wallet')) {
        backupData['wallets'] = prefs.getString('user_wallets') ?? '{}';
        backupData['wallet_keys'] = prefs.getString('wallet_keys') ?? '{}';
      }
      if (exportOptions.contains('credentials')) {
        backupData['credentials'] = prefs.getString('verifiable_credentials') ?? '{}';
      }
      final backupJson = jsonEncode(backupData);
      final encryptedBackup = await _securityService.encryptData(backupJson);
      // Use path_provider to get external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Unable to access storage directory.');
      }
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(encryptedBackup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup exported to: $filePath'), backgroundColor: Colors.green),
        );
      }
    } catch (e, stack) {
      print('Export failed:  {e.toString()}');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: {e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _importIdentityData(BuildContext context) async {
    // Prompt for filename
    final filename = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: 'diden_backup.didb');
        return AlertDialog(
          title: const Text('Enter Backup Filename'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Place your backup file in the app\'s storage directory.'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Filename'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Import')),
          ],
        );
      },
    );
    if (filename == null || filename.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Unable to access storage directory.');
      }
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      final encryptedBackup = await file.readAsString();
      await _securityService.initialize();
      final decryptedJson = await _securityService.decryptData(encryptedBackup);
      final Map<String, dynamic> backupData = jsonDecode(decryptedJson);
      // Ask user what to import
      final importOptions = await showDialog<List<String>>(
        context: context,
        builder: (ctx) {
          final selections = <String>{};
          return AlertDialog(
            title: const Text('Select Data to Import'),
            content: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (backupData.containsKey('identities'))
                    CheckboxListTile(
                      value: selections.contains('identity'),
                      title: const Text('Identity'),
                      onChanged: (v) => setState(() => v! ? selections.add('identity') : selections.remove('identity')),
                    ),
                  if (backupData.containsKey('wallets'))
                    CheckboxListTile(
                      value: selections.contains('wallet'),
                      title: const Text('Wallet'),
                      onChanged: (v) => setState(() => v! ? selections.add('wallet') : selections.remove('wallet')),
                    ),
                  if (backupData.containsKey('credentials'))
                    CheckboxListTile(
                      value: selections.contains('credentials'),
                      title: const Text('Credentials'),
                      onChanged: (v) => setState(() => v! ? selections.add('credentials') : selections.remove('credentials')),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, selections.toList()), child: const Text('Import')),
            ],
          );
        },
      );
      if (importOptions == null || importOptions.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      if (importOptions.contains('identity')) {
        if (backupData['identities'] != null) {
          await prefs.setString('digital_identities', backupData['identities']);
        }
        if (backupData['identity_keys'] != null) {
          await prefs.setString('identity_keys', backupData['identity_keys']);
        }
        if (backupData['did_document'] != null) {
          await prefs.setString('did_document', backupData['did_document']);
        }
      }
      if (importOptions.contains('wallet')) {
        if (backupData['wallets'] != null) {
          await prefs.setString('user_wallets', backupData['wallets']);
        }
        if (backupData['wallet_keys'] != null) {
          await prefs.setString('wallet_keys', backupData['wallet_keys']);
        }
      }
      if (importOptions.contains('credentials')) {
        if (backupData['credentials'] != null) {
          await prefs.setString('verifiable_credentials', backupData['credentials']);
        }
      }
      if (mounted) {
        // Reload providers
        if (importOptions.contains('identity')) {
          final identityProvider = Provider.of<IdentityProvider>(context, listen: false);
          // Use the current userId if available, or reload all
          await identityProvider.loadIdentity(identityProvider.identity?.controller ?? '');
        }
        if (importOptions.contains('wallet')) {
          final walletProvider = Provider.of<WalletProvider>(context, listen: false);
          // Use the current userId if available, or reload all
          await walletProvider.loadWallet(walletProvider.wallet?.userId ?? '');
        }
        // Show summary dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Import Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The following data was imported:'),
                if (importOptions.contains('identity')) const Text('• Identity'),
                if (importOptions.contains('wallet')) const Text('• Wallet'),
                if (importOptions.contains('credentials')) const Text('• Credentials'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, stack) {
      print('Import failed:  {e.toString()}');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: {e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _shareIdentityFile(BuildContext context) async {
    // Prompt for filename
    final filename = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: 'identity_share.didb');
        return AlertDialog(
          title: const Text('Enter Filename to Share'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Filename'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Share')),
          ],
        );
      },
    );
    if (filename == null || filename.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied.');
      }
      await _securityService.initialize();
      final prefs = await SharedPreferences.getInstance();
      final backupData = <String, dynamic>{
        'identities': prefs.getString('digital_identities') ?? '{}',
        'identity_keys': prefs.getString('identity_keys') ?? '{}',
        'did_document': prefs.getString('did_document') ?? '{}',
      };
      final backupJson = jsonEncode(backupData);
      final encryptedBackup = await _securityService.encryptData(backupJson);
      // Save to Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Unable to access Downloads directory.');
      }
      final filePath = '${downloadsDir.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(encryptedBackup);
      print('Sharing file at: $filePath');
      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'My D-Iden identity backup');
    } catch (e, stack) {
      print('Share failed:  {e.toString()}');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: {e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'Export Identity',
                  icon: Icons.download,
                  onPressed: () => _exportIdentityData(context),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'Share Identity',
                  icon: Icons.share,
                  onPressed: () => _shareIdentityFile(context),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: 'Import Identity',
                  icon: Icons.upload,
                  onPressed: () => _importIdentityData(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        widget.identity.isActive
            ? AppButton(
                text: 'Deactivate Identity',
                icon: Icons.block,
                onPressed: () {
                  _showDeactivateDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              )
            : AppButton(
                text: 'Activate Identity',
                icon: Icons.check_circle,
                onPressed: () {
                  // Implement identity activation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Identity activation coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
      ],
    );
  }
  
  Widget _buildBlockchainStatus(BuildContext context) {
    final blockchainProvider = Provider.of<BlockchainProvider>(context);
    
    // Check for blockchain errors
    if (blockchainProvider.error != null) {
      final errorMsg = blockchainProvider.error!.toLowerCase();
      final isNetworkError = errorMsg.contains('failed to fetch') || 
          errorMsg.contains('connection') || 
          errorMsg.contains('network') ||
          errorMsg.contains('timeout');
          
      Future.microtask(() => _showErrorSnackbar(
        'Blockchain error: ${blockchainProvider.error}',
        isNetworkError: isNetworkError
      ));
    }
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blockchain Integration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: blockchainProvider.did != null
                      ? Colors.green.withOpacity(0.1)
                      : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  blockchainProvider.did != null
                      ? Icons.check_circle
                      : Icons.pending,
                  color: blockchainProvider.did != null
                      ? Colors.green
                      : Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blockchainProvider.did != null
                          ? 'Blockchain DID Connected'
                          : 'Blockchain DID Not Connected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blockchainProvider.did != null
                          ? 'Your digital identity is linked to a blockchain-based DID'
                          : 'Your digital identity is not yet linked to a blockchain DID',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (blockchainProvider.did != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              blockchainProvider.did != null ? blockchainProvider.did!.did : 'No DID available',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          if (blockchainProvider.did != null)
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: blockchainProvider.did!.did),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('DID copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    if (blockchainProvider.did == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AppButton(
                          text: 'Create Blockchain DID',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DIDSetupScreen(),
                              ),
                            );
                          },
                          isFullWidth: false,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Identity'),
        content: const Text(
          'Are you sure you want to deactivate your digital identity? This will revoke access to all associated credentials until reactivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Implement deactivation logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Identity deactivation coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorSnackbar(String message, {bool isNetworkError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isNetworkError ? Colors.orange : Colors.red,
        duration: const Duration(seconds: 4),
        action: isNetworkError ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Retry logic here
            setState(() {
              _isLoading = true;
            });
            
            // Simulate loading data
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
          },
        ) : null,
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  String _formatDateFull(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${_formatTimeOfDay(date)}';
  }
  
  String _formatTimeOfDay(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final hourString = hour == 0 ? '12' : hour.toString();
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    
    return '$hourString:$minute $period';
  }
}
