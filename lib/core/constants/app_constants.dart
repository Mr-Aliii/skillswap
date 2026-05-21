/// UI and app-wide constants.
class AppConstants {
  AppConstants._();

  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';

  static const List<String> experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  static const List<String> skillCategories = [
    'Design',
    'Development',
    'Marketing',
    'Music',
    'Language',
    'Business',
    'Photography',
    'Writing',
    'Fitness',
    'Other',
  ];
}
