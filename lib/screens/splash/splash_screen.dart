import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/app_logo.dart';

/// Animated splash – routes to onboarding, auth, or main.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;
    final authUser = ref.read(authStateProvider).valueOrNull;

    String route;
    if (!onboardingDone) {
      route = AppRoutes.onboarding;
    } else if (authUser != null) {
      route = AppRoutes.main;
    } else {
      route = AppRoutes.login;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: FadeTransition(
          opacity: _fade,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(size: 100),
              SizedBox(height: 16),
              Text(
                'Learn by Exchanging Skills',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
