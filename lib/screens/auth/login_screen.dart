import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/user/user.provider.dart';
import '../../widgets/common.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: kTextGrey),
                ),
                const SizedBox(height: 40),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => authProvider.clearError(),
                    style: const TextStyle(fontSize: 14, color: kTextDark),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: kTextGrey, fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: kTextGrey, size: 20),
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
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => authProvider.clearError(),
                    style: const TextStyle(fontSize: 14, color: kTextDark),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: kTextGrey, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: kTextGrey, size: 20),
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

                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Button
                PrimaryButton(
                  text: 'Sign In',
                  isLoading: authProvider.isLoading,
                  onTap: authProvider.isLoading
                      ? null
                      : () async {
                          await authProvider.login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                          if (authProvider.isAuthenticated && mounted) {
                            final userProvider = context.read<UserProvider>();
                            userProvider.setUser(authProvider.user!);
                            Navigator.pushReplacementNamed(
                              context,
                              HomeScreen.routeName,
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

                // Google Sign In
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            await authProvider.loginWithGoogle();
                            if (authProvider.isAuthenticated && mounted) {
                              final userProvider = context.read<UserProvider>();
                              userProvider.setUser(authProvider.user!);
                              Navigator.pushReplacementNamed(
                                context,
                                HomeScreen.routeName,
                              );
                            }
                          },
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

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: kTextGrey, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, RegisterScreen.routeName),
                      child: const Text(
                        'Register',
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