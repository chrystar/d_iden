import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/verifiable_credential.dart';

class CredentialDetailsScreen extends StatelessWidget {
  static const routeName = '/credential-details';
  
  final VerifiableCredential credential;
  
  const CredentialDetailsScreen({
    Key? key,
    required this.credential,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(credential.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: _buildCredentialHeader(context),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: _buildCredentialQrCode(context),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: _buildCredentialDetails(context),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: _buildCredentialAttributes(context),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                delay: const Duration(milliseconds: 800),
                child: _buildActionButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCredentialHeader(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (credential.status) {
      case CredentialStatus.active:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Valid';
        break;
      case CredentialStatus.expired:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        statusText = 'Expired';
        break;
      case CredentialStatus.revoked:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Revoked';
        break;
      default:
        statusColor = AppColors.info;
        statusIcon = Icons.info;
        statusText = 'Unknown';
    }
    
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
                child: Icon(
                  _getCredentialTypeIcon(credential.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credential.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Issued by ${credential.issuerName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Credential ID',
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
                  _shortenString(credential.id, 30),
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
                  Clipboard.setData(ClipboardData(text: credential.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credential ID copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCredentialQrCode(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credential QR Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use this to quickly share your credential',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: QrImageView(
              data: credential.id,
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
  
  Widget _buildCredentialDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credential Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _buildDetailRow(
                'Issued On',
                _formatDate(credential.issuedAt),
                Icons.calendar_today,
              ),
              const Divider(),
              if (credential.expiresAt != null) ...[
                _buildDetailRow(
                  'Expires On',
                  _formatDate(credential.expiresAt!),
                  Icons.event,
                  valueColor: credential.status == CredentialStatus.expired
                      ? AppColors.error
                      : null,
                ),
                const Divider(),
              ],
              _buildDetailRow(
                'Issuer',
                credential.issuerName,
                Icons.business,
              ),
              const Divider(),
              _buildDetailRow(
                'Type',
                _credentialTypeToString(credential.type),
                Icons.category,
              ),
              const Divider(),
              _buildDetailRow(
                'Status',
                _credentialStatusToString(credential.status),
                _getStatusIcon(credential.status),
                valueColor: _getStatusColor(credential.status),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCredentialAttributes(BuildContext context) {
    final attributes = credential.attributes;
    if (attributes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credential Attributes',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: attributes.entries.map((entry) {
              return Column(
                children: [
                  _buildAttributeRow(entry.key, entry.value),
                  if (entry != attributes.entries.last) const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAttributeRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Share',
                icon: Icons.share,
                onPressed: () {
                  // Implement credential sharing functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: 'Verify',
                icon: Icons.verified,
                onPressed: () {
                  // Implement verification functionality
                  _showVerificationDialog(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifying Credential'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Verifying credential authenticity...'),
          ],
        ),
      ),
    );
    
    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                credential.status == CredentialStatus.active
                    ? Icons.check_circle
                    : Icons.cancel,
                color: credential.status == CredentialStatus.active
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                credential.status == CredentialStatus.active
                    ? 'Credential Verified'
                    : 'Verification Failed',
              ),
            ],
          ),
          content: Text(
            credential.status == CredentialStatus.active
                ? 'This credential has been verified as authentic and valid.'
                : credential.status == CredentialStatus.expired
                    ? 'This credential has expired on ${_formatDate(credential.expiresAt!)}.'
                    : 'This credential has been revoked by the issuer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    });
  }
  
  IconData _getCredentialTypeIcon(CredentialType type) {
    switch (type) {
      case CredentialType.personalInfo:
        return Icons.person;
      case CredentialType.education:
        return Icons.school;
      case CredentialType.employment:
        return Icons.work;
      case CredentialType.certificate:
        return Icons.card_membership;
      case CredentialType.membership:
        return Icons.group;
      case CredentialType.license:
        return Icons.badge;
      case CredentialType.identification:
        return Icons.perm_identity;
      case CredentialType.custom:
        return Icons.article;
      default:
        return Icons.description;
    }
  }
  
  String _credentialTypeToString(CredentialType type) {
    switch (type) {
      case CredentialType.personalInfo:
        return 'Personal Information';
      case CredentialType.education:
        return 'Education';
      case CredentialType.employment:
        return 'Employment';
      case CredentialType.certificate:
        return 'Certificate';
      case CredentialType.membership:
        return 'Membership';
      case CredentialType.license:
        return 'License';
      case CredentialType.identification:
        return 'Identification';
      case CredentialType.custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }
  
  String _credentialStatusToString(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.active:
        return 'Active';
      case CredentialStatus.expired:
        return 'Expired';
      case CredentialStatus.revoked:
        return 'Revoked';
      default:
        return 'Unknown';
    }
  }
  
  IconData _getStatusIcon(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.active:
        return Icons.check_circle;
      case CredentialStatus.expired:
        return Icons.access_time;
      case CredentialStatus.revoked:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
  
  Color _getStatusColor(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.active:
        return AppColors.success;
      case CredentialStatus.expired:
        return AppColors.warning;
      case CredentialStatus.revoked:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
  
  String _shortenString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }
}
