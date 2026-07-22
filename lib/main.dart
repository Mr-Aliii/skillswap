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

  _setupNotificationHandler();

  await MessagingService.initialize();
  runApp(const ProviderScope(child: SkillSwapApp()));
}

void _setupNotificationHandler() {
  MessagingService.onNotificationTap = (type, data) {
    final nav = MessagingService.navigatorKey.currentState;
    if (nav == null) return;

    switch (type) {
      case 'chat_message':
        final chatId = data['chatId'];
        if (chatId != null) {
          nav.pushNamed(AppRoutes.chat, arguments: chatId);
        }
      case 'connection_request':
      case 'match':
        nav.pushNamed(AppRoutes.notifications);
      default:
        nav.pushNamed(AppRoutes.notifications);
    }
  };
}

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
      navigatorKey: MessagingService.navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
