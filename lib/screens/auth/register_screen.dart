import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/utils/validators.dart';
import 'package:skill_swap/widgets/common/app_text_field.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';

/// User registration with email/password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).register(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        context.showSnack(
          e is AppException ? e.message : 'Registration failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the skill exchange community',
                  style: TextStyle(color: context.theme.hintColor),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
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
                  hint: 'Min 6 characters',
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
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
