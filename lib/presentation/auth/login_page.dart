import 'package:mobile_cursach/core/theme.dart';
import 'package:mobile_cursach/data/repositories/auth_repository.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';
import 'package:mobile_cursach/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscureText = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      _navigateBasedOnRole();
    }
  }

  Future<void> _navigateBasedOnRole() async {
    final isAdmin = await LocalStorage.getIsAdmin();
    if (!mounted) return;

    if (isAdmin) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
    }
  }

  Future<void> _login() async {
    setState(() => loading = true);

    try {
      await AuthRepository().login(
        username: emailController.text.trim(),
        password: passwordController.text.trim(),
        rememberMe: rememberMe,
      );

      if (!mounted) return;
      _navigateBasedOnRole();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Sport',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Life',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, champion!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),

                const SizedBox(height: 48),

                _inputField(
                  controller: emailController,
                  hint: 'Username',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                _inputField(
                  controller: passwordController,
                  hint: 'Password',
                  obscure: obscureText,
                  icon: obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onIconTap: () => setState(() => obscureText = !obscureText),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: AppColors.primary,
                        checkColor: Colors.black,
                        side: BorderSide(color: Colors.grey[600]!, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (v) =>
                            setState(() => rememberMe = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[800])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[800])),
                  ],
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    VoidCallback? onIconTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon == null
            ? null
            : GestureDetector(
                onTap: onIconTap,
                child: Icon(icon, color: Colors.grey[500]),
              ),
        prefixIcon: icon == Icons.person_outline
            ? Icon(Icons.email_outlined, color: Colors.grey[500])
            : Icon(Icons.lock_outline, color: Colors.grey[500]),
      ),
    );
  }
}
