/// Global application configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'SkillSwap';
  static const String appTagline = 'Learn by Exchanging Skills';
  static const String appVersion = '1.0.0';

  /// Set to `false` after running `flutterfire configure` and adding real credentials.
  /// Use `true` for local UI testing without Firebase (recommended for `flutter run -d chrome`).
  static const bool useDemoMode = false;

  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String bookingsCollection = 'bookings';
  static const String notificationsCollection = 'notifications';
  static const String skillsCollection = 'skills';
}
