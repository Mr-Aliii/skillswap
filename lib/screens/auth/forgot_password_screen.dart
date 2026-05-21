import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/utils/validators.dart';
import 'package:skill_swap/widgets/common/app_text_field.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';

/// Password reset via Firebase email link.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(_emailController.text);
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        context.showSnack(
          e is AppException ? e.message : 'Failed to send reset email',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Check your inbox',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a password reset link to ${_emailController.text}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.theme.hintColor),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter your email and we\'ll send you a reset link.',
                        style: TextStyle(color: context.theme.hintColor),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Send Reset Link',
                        isLoading: isLoading,
                        onPressed: _reset,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
