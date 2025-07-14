import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/widgets/shimmer_loading.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/security_provider.dart';
import '../../domain/models/digital_identity.dart';
import '../../domain/models/verifiable_credential.dart';
import '../providers/identity_provider.dart';
import 'identity_details_screen.dart';
import 'credential_details_screen.dart';
import '../../../../features/blockchain/presentation/providers/blockchain_provider.dart';
import '../../../../features/blockchain/presentation/screens/did_setup_screen.dart';

class IdentityDashboardScreen extends StatefulWidget {
  static const routeName = '/identity-dashboard';
  
  const IdentityDashboardScreen({Key? key}) : super(key: key);

  @override
  State<IdentityDashboardScreen> createState() => _IdentityDashboardScreenState();
}

class _IdentityDashboardScreenState extends State<IdentityDashboardScreen> {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  
  @override
  void initState() {
    super.initState();
    _authenticateUser();
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
      final errorMsg = e.toString().toLowerCase();
      final isNetworkError = errorMsg.contains('failed to fetch') || 
          errorMsg.contains('connection') || 
          errorMsg.contains('network') ||
          errorMsg.contains('timeout');
      
      _showErrorSnackbar(
        'Failed to load identity data: ${e.toString()}',
        isNetworkError: isNetworkError
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _checkBlockchainDID() async {
    try {
      final blockchainProvider = Provider.of<BlockchainProvider>(context, listen: false);
      final didExists = await blockchainProvider.hasExistingDID();
      
      if (!didExists && mounted) {
        // Wait a bit to avoid showing dialog during loading state
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Blockchain Identity'),
            content: const Text(
              'You don\'t have a blockchain-based decentralized identifier (DID) yet. '
              'A DID will allow you to verify your identity on the blockchain and '
              'interact with decentralized applications securely.'
            ),
            actions: [
              TextButton(
                child: const Text('Later'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text('Create DID'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DIDSetupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().toLowerCase();
        final isNetworkError = errorMsg.contains('failed to fetch') || 
            errorMsg.contains('connection') || 
            errorMsg.contains('network') ||
            errorMsg.contains('timeout');
            
        _showErrorSnackbar(
          'Failed to check blockchain DID: ${e.toString()}',
          isNetworkError: isNetworkError
        );
      }
    }
  }
  
  Future<void> _authenticateUser() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
      
      // Authenticate with biometrics if available and enabled
      _isAuthenticated = await securityProvider.authenticateWithBiometrics(
        reason: 'Authenticate to access your identity dashboard'
      );
      
      if (_isAuthenticated) {
        // Load data after successful authentication
        await _loadIdentityData();
        await _checkBlockchainDID();
      } else {
        // Handle failed authentication
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Some features may be restricted.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Authentication error: ${e.toString()}');
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
    final securityProvider = Provider.of<SecurityProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Identity'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isAuthenticated ? _loadIdentityData : _authenticateUser,
          ),
          if (securityProvider.biometricsAvailable)
            IconButton(
              icon: Icon(
                securityProvider.biometricsEnabled 
                    ? Icons.fingerprint 
                    : Icons.fingerprint_outlined,
                color: securityProvider.biometricsEnabled
                    ? Colors.green
                    : null,
              ),
              tooltip: securityProvider.biometricsEnabled 
                  ? 'Biometric authentication enabled' 
                  : 'Enable biometric authentication',
              onPressed: () async {
                final newValue = !securityProvider.biometricsEnabled;
                await securityProvider.setBiometricsEnabled(newValue);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newValue
                          ? 'Biometric authentication enabled'
                          : 'Biometric authentication disabled'
                    ),
                    backgroundColor: newValue ? Colors.green : Colors.orange,
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
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
                  // Authenticate user first
                  final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
                  
                  // If biometrics is enabled, require authentication before creating identity
                  if (securityProvider.biometricsEnabled) {
                    final authenticated = await securityProvider.authenticateWithBiometrics(
                      reason: 'Authenticate to create your digital identity'
                    );
                    
                    if (!authenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Authentication failed. Identity creation cancelled.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      return;
                    }
                  }
                  
                  // Get user ID from authentication system
                  final userId = "current_user_id"; // Use the same ID as in loadIdentityData
                  
                  // Create identity
                  await identityProvider.createIdentity(userId);
                  
                  // Set authentication status to true after successful creation
                  _isAuthenticated = true;
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Digital identity created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Reload identity data
                  await _loadIdentityData();
                } catch (e) {
                  final errorMsg = e.toString().toLowerCase();
                  final isNetworkError = errorMsg.contains('failed to fetch') || 
                      errorMsg.contains('connection') || 
                      errorMsg.contains('network') ||
                      errorMsg.contains('timeout');
                      
                  _showErrorSnackbar(
                    'Failed to create identity: ${e.toString()}',
                    isNetworkError: isNetworkError
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
              delay: const Duration(milliseconds: 200),
              child: _buildBlockchainDIDCard(),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
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
  
  Widget _buildBlockchainDIDCard() {
    final blockchainProvider = Provider.of<BlockchainProvider>(context);
    
    if (blockchainProvider.did == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.link_off,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Blockchain Identity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Not Linked',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'You haven\'t created a blockchain DID yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
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
          ],
        ),
      );
    }
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Blockchain Identity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _shortenDid(blockchainProvider.did!.did),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.verified,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              const Text(
                'Ethereum blockchain verified',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
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
  
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity card shimmer
          ShimmerLoading(
            isLoading: true,
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const ShimmerIdentityCard(),
          ),
          const SizedBox(height: 24),
          // Blockchain DID card shimmer
          ShimmerLoading(
            isLoading: true,
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const ShimmerIdentityCard(),
          ),
          const SizedBox(height: 24),
          // Stats shimmer
          ShimmerLoading(
            isLoading: true,
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const ShimmerStats(),
          ),
          const SizedBox(height: 24),
          // Credentials title shimmer
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(
                  isLoading: true,
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const ShimmerBox(height: 30),
                ),
              ),
              const SizedBox(width: 50),
              ShimmerLoading(
                isLoading: true,
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const ShimmerBox(width: 80, height: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Credentials grid shimmer
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: List.generate(
              4,
              (_) => ShimmerLoading(
                isLoading: true,
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const ShimmerCredentialCard(),
              ),
            ),
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
          onPressed: _authenticateUser,
        ) : null,
      ),
    );
  }
}
