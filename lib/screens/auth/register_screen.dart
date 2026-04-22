import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common.dart';
import 'verify_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextGrey, fontSize: 14),
      prefixIcon: Icon(icon, color: kTextGrey, size: 20),
      filled: true,
      fillColor: kWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    width: 72,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: kTextGrey),
                ),
                const SizedBox(height: 36),

                // Name
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => authProvider.clearError(),
                  style: const TextStyle(fontSize: 14, color: kTextDark),
                  decoration: _fieldDecoration('Full Name', Icons.person_outline),
                ),
                const SizedBox(height: 14),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => authProvider.clearError(),
                  style: const TextStyle(fontSize: 14, color: kTextDark),
                  decoration: _fieldDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => authProvider.clearError(),
                  style: const TextStyle(fontSize: 14, color: kTextDark),
                  decoration: _fieldDecoration(
                    'Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: kTextGrey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: (_) => authProvider.clearError(),
                  style: const TextStyle(fontSize: 14, color: kTextDark),
                  decoration: _fieldDecoration(
                    'Confirm Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: kTextGrey,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Error
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kRedLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(color: kRed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Register Button
                PrimaryButton(
                  text: 'Create Account',
                  isLoading: authProvider.isLoading,
                  onTap: authProvider.isLoading
                      ? null
                      : () async {
                          final email = await authProvider.register(
                            _emailController.text.trim(),
                            _passwordController.text,
                            _confirmPasswordController.text,
                            _nameController.text.trim(),
                          );
                          if (email != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerifyOtpScreen(
                                  email: email,
                                  isRegistration: true,
                                ),
                              ),
                            );
                          }
                        },
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: kDivider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: kTextGrey, fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider(color: kDivider)),
                  ],
                ),

                const SizedBox(height: 24),

                // Google
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => authProvider.loginWithGoogle(),
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 20,
                      width: 20,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kWhite,
                      side: const BorderSide(color: kDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: kTextGrey, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}