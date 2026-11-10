
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No logged-in user found.'),
        ),
      );
      return;
    }

    if (_currentPassword.text.isEmpty ||
        _newPassword.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your current password and a new password '
            'of at least 6 characters.',
          ),
        ),
      );
      return;
    }

    if (_currentPassword.text == _newPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your new password must be different from your current password.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Re-authenticate the user using their current password.
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassword.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password.
      await user.updatePassword(_newPassword.text);

      _currentPassword.clear();
      _newPassword.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Your current password is incorrect.';
          break;

        case 'weak-password':
          message = 'Your new password is too weak.';
          break;

        case 'requires-recent-login':
          message = 'Please log in again before changing your password.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Password update failed.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account Settings'),
        ),
        body: const Center(
          child: Text('No logged-in user found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle,
              size: 72,
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Email: ${user.email ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _currentPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
                helperText: 'Must contain at least 6 characters.',
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: _loading ? null : _changePassword,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Update Password'),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _loading ? null : _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
