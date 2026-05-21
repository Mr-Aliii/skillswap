import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/models/message_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:uuid/uuid.dart';

/// Chat conversations and messages (Firestore or demo).
class ChatService {
  final _uuid = const Uuid();
  final List<MessageModel> _demoMessages = [];

  FirebaseFirestore? get _firestore =>
      AppConfig.useDemoMode ? null : FirebaseFirestore.instance;

  Future<List<ChatModel>> getChats(String userId) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return DummyData.demoChats;
    }
    final snapshot = await _firestore!
        .collection(AppConfig.chatsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => ChatModel.fromMap(d.data(), d.id))
        .toList();
  }

  Stream<List<MessageModel>> watchMessages(String chatId) {
    if (AppConfig.useDemoMode) {
      return Stream.value(_demoMessagesFor(chatId));
    }
    return _firestore!
        .collection(AppConfig.chatsCollection)
        .doc(chatId)
        .collection(AppConfig.messagesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (AppConfig.useDemoMode) {
      _demoMessages.insert(
        0,
        MessageModel(
          id: _uuid.v4(),
          chatId: chatId,
          senderId: senderId,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      return;
    }
    final msgRef = _firestore!
        .collection(AppConfig.chatsCollection)
        .doc(chatId)
        .collection(AppConfig.messagesCollection)
        .doc();
    final message = MessageModel(
      id: msgRef.id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );
    await msgRef.set(message.toMap());
    await _firestore!.collection(AppConfig.chatsCollection).doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  List<MessageModel> _demoMessagesFor(String chatId) {
    if (_demoMessages.isEmpty) {
      _demoMessages.addAll([
        MessageModel(
          id: 'm1',
          chatId: chatId,
          senderId: 'user_2',
          text: 'Hey! I saw you want to learn Web Dev. I can help!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MessageModel(
          id: 'm2',
          chatId: chatId,
          senderId: DummyData.demoUserId,
          text: 'That would be amazing! I can teach you UI/UX in return.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        MessageModel(
          id: 'm3',
          chatId: chatId,
          senderId: 'user_2',
          text: 'Sounds great! See you tomorrow at 3pm.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
      ]);
    }
    return List.from(_demoMessages);
  }
}
