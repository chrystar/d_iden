import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/digital_identity.dart';
import '../../domain/models/verifiable_credential.dart';
import '../providers/identity_provider.dart';
import 'identity_details_screen.dart';
import 'credential_details_screen.dart';

class IdentityDashboardScreen extends StatefulWidget {
  static const routeName = '/identity-dashboard';
  
  const IdentityDashboardScreen({Key? key}) : super(key: key);

  @override
  State<IdentityDashboardScreen> createState() => _IdentityDashboardScreenState();
}

class _IdentityDashboardScreenState extends State<IdentityDashboardScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadIdentityData();
  }
  
  Future<void> _loadIdentityData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final identityProvider = Provider.of<IdentityProvider>(context, listen: false);
      
      // Use a mock user ID for now - in a real app, this would come from your authentication system
      const String userId = 'current_user_id';
      
      await identityProvider.loadIdentity(userId);
      // The loadIdentity method already loads credentials
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load identity data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Identity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIdentityData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildIdentityContent(),
    );
  }
  
  Widget _buildIdentityContent() {
    final identityProvider = Provider.of<IdentityProvider>(context);
    final identity = identityProvider.identity;
    final credentials = identityProvider.credentials;
    
    if (identity == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You don\'t have a digital identity yet'),
            const SizedBox(height: 16),
            AppButton(
              text: 'Create Digital Identity',
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  // Get user ID from authentication system
                  final userId = "currentUserId"; // Placeholder - replace with actual user ID
                  await identityProvider.createIdentity(userId);
                  _loadIdentityData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create identity: ${e.toString()}')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              isFullWidth: false,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadIdentityData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildIdentityCard(identity),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: _buildCredentialStats(credentials),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              child: _buildCredentialsList(credentials),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIdentityCard(DigitalIdentity identity) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          IdentityDetailsScreen.routeName,
          arguments: identity,
        );
      },
      child: GradientAppCard(
        gradientColors: const [AppColors.primary, AppColors.secondary],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Decentralized Identity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: identity.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    identity.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _shortenDid(identity.did),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap for details',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCredentialStats(List<VerifiableCredential> credentials) {
    final activeCount = credentials.where((c) => c.status == CredentialStatus.active).length;
    final revokedCount = credentials.where((c) => c.status == CredentialStatus.revoked).length;
    final expiredCount = credentials.where((c) => c.status == CredentialStatus.expired).length;
    
    return Row(
      children: [
        _buildStatCard(
          'Active',
          activeCount.toString(),
          AppColors.success,
          Icons.check_circle,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Expired',
          expiredCount.toString(),
          AppColors.warning,
          Icons.access_time,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Revoked',
          revokedCount.toString(),
          AppColors.error,
          Icons.cancel,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCredentialsList(List<VerifiableCredential> credentials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Credentials',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to full credentials list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        credentials.isEmpty
            ? _buildEmptyCredentialsState()
            : _buildCredentialsGrid(credentials),
      ],
    );
  }
  
  Widget _buildEmptyCredentialsState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge,
              color: AppColors.textSecondary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Credentials Yet',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any verifiable credentials yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Request Credential',
            onPressed: () {
              // Navigate to credential request flow
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCredentialsGrid(List<VerifiableCredential> credentials) {
    // Take only up to 4 credentials for preview
    final previewCredentials = credentials.length > 4
        ? credentials.sublist(0, 4)
        : credentials;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: previewCredentials.map((credential) {
        return _buildCredentialCard(credential);
      }).toList(),
    );
  }
  
  Widget _buildCredentialCard(VerifiableCredential credential) {
    final isExpired = credential.status == CredentialStatus.expired;
    final isRevoked = credential.status == CredentialStatus.revoked;
    
    // Determine badge color based on status
    Color statusColor;
    IconData statusIcon;
    
    switch (credential.status) {
      case CredentialStatus.active:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case CredentialStatus.expired:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        break;
      case CredentialStatus.revoked:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.info;
        statusIcon = Icons.info;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          CredentialDetailsScreen.routeName,
          arguments: credential,
        );
      },
      child: AppCard(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _getCredentialTypeIcon(credential.type),
                ),
                const SizedBox(height: 12),
                Text(
                  credential.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  credential.issuerName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (credential.expiresAt != null)
                  Text(
                    'Expires: ${_formatDate(credential.expiresAt!)}',
                    style: TextStyle(
                      color: isExpired ? AppColors.error : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 16,
                ),
              ),
            ),
            if (isExpired || isRevoked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      isExpired ? 'EXPIRED' : 'REVOKED',
                      style: TextStyle(
                        color: isExpired ? AppColors.warning : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Icon _getCredentialTypeIcon(CredentialType type) {
    switch (type) {
      case CredentialType.personalInfo:
        return const Icon(Icons.person, color: AppColors.primary);
      case CredentialType.education:
        return const Icon(Icons.school, color: AppColors.primary);
      case CredentialType.employment:
        return const Icon(Icons.work, color: AppColors.primary);
      case CredentialType.certificate:
        return const Icon(Icons.card_membership, color: AppColors.primary);
      case CredentialType.membership:
        return const Icon(Icons.group, color: AppColors.primary);
      case CredentialType.license:
        return const Icon(Icons.badge, color: AppColors.primary);
      case CredentialType.identification:
        return const Icon(Icons.perm_identity, color: AppColors.primary);
      case CredentialType.custom:
        return const Icon(Icons.article, color: AppColors.primary);
      // No default needed as all cases are covered
    }
  }
  
  String _shortenDid(String did) {
    if (did.length > 24) {
      return '${did.substring(0, 12)}...${did.substring(did.length - 8)}';
    }
    return did;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else {
      return 'Today';
    }
  }
}
