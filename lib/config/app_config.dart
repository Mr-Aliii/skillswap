/// Global application configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'SkillSwap';
  static const String appTagline = 'Learn by Exchanging Skills';
  static const String appVersion = '1.0.0';

  /// `false` = real Firebase Auth, Firestore, Storage.
  /// `true` = local demo data only (no Firebase calls).
  static const bool useDemoMode = false;

  /// Same as [useDemoMode] — demo auto-fallback is disabled so you can test Firebase.
  static bool get isDemoMode => useDemoMode;

  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String bookingsCollection = 'bookings';
  static const String notificationsCollection = 'notifications';
  static const String skillsCollection = 'skills';
  static const String connectionRequestsCollection = 'connection_requests';
  static const String premiumSubscriptionsCollection = 'premium_subscriptions';
}
