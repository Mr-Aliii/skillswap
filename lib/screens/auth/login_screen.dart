import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/utils/validators.dart';
import 'package:skill_swap/widgets/common/app_logo.dart';
import 'package:skill_swap/widgets/common/app_text_field.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';

/// Email/password login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        context.showSnack(
          e is AppException ? e.message : 'Login failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const AppLogo(size: 72),
                const SizedBox(height: 32),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue exchanging skills',
                  style: TextStyle(color: context.theme.hintColor),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Sign In',
                  isLoading: isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
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
