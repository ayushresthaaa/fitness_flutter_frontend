import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/user/user.provider.dart';
import '../../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<UserProvider>().updateAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOAuth = context.read<AuthProvider>().user?.isOAuth ?? false;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _nameController,
              hint: 'e.g. Aayush Shrestha',
            ),

            const SizedBox(height: 16),

            // Email
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _emailController,
              hint: 'e.g. ayush@gmail.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !isOAuth,
            ),

            if (isOAuth) ...[
              const SizedBox(height: 6),
              const Text(
                'Email is managed by Google and cannot be changed',
                style: TextStyle(fontSize: 11, color: kTextHint),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        child: PrimaryButton(
          text: 'Save Changes',
          isLoading: _isSaving,
          onTap: _save,
        ),
      ),
    );
  }
}