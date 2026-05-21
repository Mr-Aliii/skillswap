import 'package:flutter/material.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/app_logo.dart';

/// About app information screen.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppLogo(size: 80),
            const SizedBox(height: 16),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              AppConfig.appTagline,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 8),
            Text('Version ${AppConfig.appVersion}'),
            const SizedBox(height: 32),
            const Text(
              'SkillSwap is a modern platform where people exchange skills instead of money. '
              'Teach what you know, learn what you need, and build meaningful learning communities.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              '© 2026 SkillSwap. All rights reserved.',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.language, color: AppColors.primary),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
