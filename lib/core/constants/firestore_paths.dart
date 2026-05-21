/// Firestore collection and subcollection path helpers.
class FirestorePaths {
  FirestorePaths._();

  static String user(String uid) => 'users/$uid';
  static String chat(String chatId) => 'chats/$chatId';
  static String messages(String chatId) => 'chats/$chatId/messages';
  static String booking(String id) => 'bookings/$id';
  static String notification(String id) => 'notifications/$id';
  static String skill(String id) => 'skills/$id';
}
