import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/firebase/firebase_initializer.dart';
import 'package:skill_swap/firebase/messaging_service.dart';
import 'package:skill_swap/providers/theme_provider.dart';
import 'package:skill_swap/routes/app_router.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  await MessagingService.initialize();
  runApp(const ProviderScope(child: SkillSwapApp()));
}

/// Root application widget.
class SkillSwapApp extends ConsumerWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
