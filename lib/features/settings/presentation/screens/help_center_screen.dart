import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFaq(
            'How do I create a digital identity?',
            'Go to the Identity section and tap "Create Digital Identity". Follow the prompts to set up your DID.',
          ),
          _buildFaq(
            'How do I back up my wallet?',
            'Go to the Identity Details screen and use the Export Identity feature to save an encrypted backup file.',
          ),
          _buildFaq(
            'How do I recover my data?',
            'Use the Import Identity feature and select your backup file from storage.',
          ),
          _buildFaq(
            'Is my data secure?',
            'Yes. All sensitive data is encrypted and can be protected with biometrics and PIN.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Guides',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGuide(
            'Getting Started',
            '1. Register or log in.\n2. Set up your wallet and digital identity.\n3. Explore credentials and settings.',
          ),
          _buildGuide(
            'Security Tips',
            '• Always back up your wallet and credentials.\n• Enable biometrics and PIN for extra protection.\n• Never share your private key or recovery phrase.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Contact Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: const Text('support@d-iden.app'),
            onTap: () {
              // You can implement email launch here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email: support@d-iden.app')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFaq(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(answer),
        ],
      ),
    );
  }

  Widget _buildGuide(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
} 