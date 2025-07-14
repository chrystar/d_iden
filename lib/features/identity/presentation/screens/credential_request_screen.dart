import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/verifiable_credential.dart';
import '../providers/identity_provider.dart';

class CredentialRequestScreen extends StatefulWidget {
  static const routeName = '/credential-request';

  const CredentialRequestScreen({Key? key}) : super(key: key);

  @override
  State<CredentialRequestScreen> createState() => _CredentialRequestScreenState();
}

class _CredentialRequestScreenState extends State<CredentialRequestScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  CredentialType _selectedType = CredentialType.personalInfo;
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    super.dispose();
  }
  
  // Map to store the additional field values
  Map<String, String> _additionalFields = {};

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create the credential subject map based on the type and additional fields
      final Map<String, dynamic> credentialSubject = {
        'name': _nameController.text,
      };
      
      // Add additional fields based on credential type
      _additionalFields.forEach((key, value) {
        if (value.isNotEmpty) {
          credentialSubject[key] = value;
        }
      });
      
      // Generate a random issuer DID for demo purposes
      // In a real app, this would be retrieved from a directory or QR code
      final String issuerDid = 'did:ethr:${_generateRandomHexString(40)}';
      
      // Get the credential type string
      final String credentialTypeString = _getCredentialTypeString(_selectedType);
      
      // Request the credential using the identity provider
      final identityProvider = Provider.of<IdentityProvider>(context, listen: false);
      final credential = await identityProvider.requestCredential(
        issuerDid: issuerDid,
        issuerName: _issuerController.text,
        credentialType: credentialTypeString,
        credentialSubject: credentialSubject,
      );
      
      if (!mounted) return;
      
      if (credential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credential issued successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credential request submitted. Waiting for issuer approval.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  String _generateRandomHexString(int length) {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final baseHex = random.hashCode.toRadixString(16);
    if (baseHex.length >= length) {
      return baseHex.substring(0, length);
    }
    return baseHex.padRight(length, '0');
  }
  
  String _getCredentialTypeString(CredentialType type) {
    switch (type) {
      case CredentialType.personalInfo:
        return 'personalInfo';
      case CredentialType.education:
        return 'education';
      case CredentialType.employment:
        return 'employment';
      case CredentialType.certificate:
        return 'certificate';
      case CredentialType.membership:
        return 'membership';
      case CredentialType.license:
        return 'license';
      case CredentialType.identification:
        return 'identification';
      case CredentialType.custom:
        return 'custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Credential'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request a New Verifiable Credential',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill out the form below to request a new credential from an issuer. '
              'Once submitted, the issuer will review your request and issue the credential if approved.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credential Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCredentialTypeSelector(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Credential Name',
                        hintText: 'e.g., University Degree',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name for the credential';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _issuerController,
                      decoration: const InputDecoration(
                        labelText: 'Issuer Name',
                        hintText: 'e.g., University of Technology',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the issuer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildAdditionalFields(),
                    const SizedBox(height: 24),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : AppButton(
                              text: 'Submit Request',
                              onPressed: _submitRequest,
                              isFullWidth: true,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credential Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CredentialType>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          value: _selectedType,
          items: CredentialType.values.map((type) {
            String label = '';
            IconData icon = Icons.document_scanner;
            
            switch (type) {
              case CredentialType.personalInfo:
                label = 'Personal Information';
                icon = Icons.person;
                break;
              case CredentialType.education:
                label = 'Education';
                icon = Icons.school;
                break;
              case CredentialType.employment:
                label = 'Employment';
                icon = Icons.work;
                break;
              case CredentialType.certificate:
                label = 'Certificate';
                icon = Icons.card_membership;
                break;
              case CredentialType.membership:
                label = 'Membership';
                icon = Icons.group;
                break;
              case CredentialType.license:
                label = 'License';
                icon = Icons.badge;
                break;
              case CredentialType.identification:
                label = 'Identification';
                icon = Icons.perm_identity;
                break;
              case CredentialType.custom:
                label = 'Custom';
                icon = Icons.article;
                break;
            }
            
            return DropdownMenuItem<CredentialType>(
              value: type,
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(label),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    // Clear additional fields when type changes
    _additionalFields.clear();
    
    // Different fields depending on credential type
    switch (_selectedType) {
      case CredentialType.education:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Education-specific Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Degree/Qualification',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['degree'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['institution'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Graduation Year',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _additionalFields['graduationYear'] = value;
              },
            ),
          ],
        );
        
      case CredentialType.employment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employment-specific Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['jobTitle'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['company'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Start Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['startDate'] = value;
              },
            ),
          ],
        );
      
      case CredentialType.identification:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identification Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ID Type',
                hintText: 'e.g., Passport, Driver\'s License',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['idType'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ID Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['idNumber'] = value;
              },
            ),
          ],
        );
        
      case CredentialType.membership:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Membership Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Organization',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['organization'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Membership Level',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['membershipLevel'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['expirationDate'] = value;
              },
            ),
          ],
        );
        
      default:
        // For other credential types, just provide a generic form field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Key',
                hintText: 'e.g., Date, ID, Reference',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['key'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _additionalFields['value'] = value;
              },
            ),
          ],
        );
    }
  }

  Widget _buildInfoSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'About Verifiable Credentials',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Verifiable Credentials are tamper-evident credentials that have authorship '
            'that can be cryptographically verified. They can be used to build trust in '
            'interactions between parties online.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'These credentials are stored in your digital wallet and can be presented to '
            'verifiers when needed, giving you control over your identity and information.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
