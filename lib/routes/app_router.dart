import 'package:flutter/material.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/screens/auth/forgot_password_screen.dart';
import 'package:skill_swap/screens/auth/login_screen.dart';
import 'package:skill_swap/screens/auth/register_screen.dart';
import 'package:skill_swap/screens/booking/book_session_screen.dart';
import 'package:skill_swap/screens/chat/chat_screen.dart';
import 'package:skill_swap/screens/main/main_shell_screen.dart';
import 'package:skill_swap/screens/notifications/notifications_screen.dart';
import 'package:skill_swap/screens/onboarding/onboarding_screen.dart';
import 'package:skill_swap/screens/profile/edit_profile_screen.dart';
import 'package:skill_swap/screens/profile/user_profile_screen.dart';
import 'package:skill_swap/screens/settings/about_screen.dart';
import 'package:skill_swap/screens/splash/splash_screen.dart';

/// Central navigation and route generation.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());
      case AppRoutes.onboarding:
        return _slide(const OnboardingScreen());
      case AppRoutes.login:
        return _slide(const LoginScreen());
      case AppRoutes.register:
        return _slide(const RegisterScreen());
      case AppRoutes.forgotPassword:
        return _slide(const ForgotPasswordScreen());
      case AppRoutes.main:
        return _fade(const MainShellScreen());
      case AppRoutes.editProfile:
        return _slide(const EditProfileScreen());
      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(ChatScreen(
          chatId: args?['chatId'] as String? ?? '',
          otherUserName: args?['otherUserName'] as String? ?? 'Chat',
          otherUserId: args?['otherUserId'] as String? ?? '',
        ));
      case AppRoutes.bookSession:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(BookSessionScreen(
          targetUserId: args?['targetUserId'] as String? ?? '',
          targetUserName: args?['targetUserName'] as String? ?? 'User',
        ));
      case AppRoutes.notifications:
        return _slide(const NotificationsScreen());
      case AppRoutes.about:
        return _slide(const AboutScreen());
      case AppRoutes.userProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(UserProfileScreen(
          userId: args?['userId'] as String? ?? '',
        ));
      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static PageRouteBuilder<dynamic> _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.05, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
