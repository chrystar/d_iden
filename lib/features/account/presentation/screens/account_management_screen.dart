import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_iden/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({Key? key}) : super(key: key);

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _displayNameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  bool _editing = false;
  bool _changingPassword = false;
  bool _changingEmail = false;
  File? _pickedImage;

  @override
  void dispose() {
    _displayNameController.dispose();
    _photoUrlController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _emailPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _editing = true;
      });
      // In a real app, upload the image and get a URL, then set _photoUrlController.text
      // For now, just show the local image
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (authProvider.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user == null) {
            return const Center(child: Text('No user information available.'));
          }
          if (!_editing) {
            _displayNameController.text = user.displayName ?? '';
            _photoUrlController.text = user.photoUrl ?? '';
            _emailController.text = user.email;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (user.photoUrl != null && user.photoUrl!.isNotEmpty
                                ? NetworkImage(user.photoUrl!)
                                : null) as ImageProvider<Object>?,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty) && _pickedImage == null
                            ? const Icon(Icons.account_circle, size: 64)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _editing = true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _editing = true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => _editing = true),
                  enabled: !_changingEmail,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _editing
                      ? () async {
                          if (_displayNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Display name cannot be empty'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a valid email'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          final confirmed = await _showConfirmDialog('Save Changes', 'Are you sure you want to update your profile?');
                          if (confirmed != true) return;
                          await authProvider.updateProfile(
                            displayName: _displayNameController.text.trim(),
                            photoUrl: _photoUrlController.text.trim(),
                          );
                          setState(() => _editing = false);
                          if (authProvider.error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
                            );
                          }
                        }
                      : null,
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _editing && _emailController.text.trim() != user.email && !_changingEmail
                      ? () => setState(() => _changingEmail = true)
                      : null,
                  child: const Text('Change Email'),
                ),
                if (_changingEmail) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (_emailPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your current password'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final confirmed = await _showConfirmDialog('Change Email', 'Are you sure you want to change your email?');
                      if (confirmed != true) return;
                      // You need to implement updateEmail in AuthProvider and backend
                      try {
                        await authProvider.updateEmail(
                          newEmail: _emailController.text.trim(),
                          currentPassword: _emailPasswordController.text.trim(),
                        );
                        if (authProvider.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email updated successfully!'), backgroundColor: Colors.green),
                          );
                          setState(() {
                            _changingEmail = false;
                            _editing = false;
                            _emailPasswordController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Confirm Email Change'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _changingEmail = false),
                    child: const Text('Cancel'),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                if (!_changingPassword)
                  ElevatedButton(
                    onPressed: () => setState(() => _changingPassword = true),
                    child: const Text('Change Password'),
                  ),
                if (_changingPassword) ...[
                  TextField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentPasswordController.text.trim().isEmpty || _newPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all password fields'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final confirmed = await _showConfirmDialog('Change Password', 'Are you sure you want to change your password?');
                      if (confirmed != true) return;
                      await authProvider.updatePassword(
                        _currentPasswordController.text.trim(),
                        _newPasswordController.text.trim(),
                      );
                      if (authProvider.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
                        );
                        setState(() {
                          _changingPassword = false;
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Update Password'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _changingPassword = false),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
} 