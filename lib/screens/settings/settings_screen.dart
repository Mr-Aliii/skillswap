import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/theme_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/app_logo.dart';

/// App settings: profile, theme, logout, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Center(child: AppLogo(size: 56, showText: false)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Center(
            child: Text(
              'v${AppConfig.appVersion}',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          if (AppConfig.useDemoMode)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                color: Color(0xFFFFF7ED),
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.warning),
                  title: Text('Demo Mode'),
                  subtitle: Text(
                    'Firebase is disabled. Set useDemoMode to false after configuring Firebase.',
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle light/dark theme'),
            value: isDark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SkillSwap'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
    );
  }
}
