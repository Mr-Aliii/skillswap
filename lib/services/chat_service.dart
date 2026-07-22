import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/models/message_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:uuid/uuid.dart';

/// Chat conversations and messages (Firestore or demo).
class ChatService {
  ChatService() {
    if (AppConfig.isDemoMode) {
      _initDemoMessages();
    }
  }

  final _uuid = const Uuid();
  final List<MessageModel> _demoMessages = [];
  final StreamController<List<MessageModel>> _demoStream = StreamController<List<MessageModel>>.broadcast();

  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  void _initDemoMessages() {
    _demoMessages.addAll([
      MessageModel(
        id: 'm3',
        chatId: 'chat_2',
        senderId: 'user_3',
        text: 'Sounds great! See you tomorrow at 3pm.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      MessageModel(
        id: 'm2',
        chatId: 'chat_2',
        senderId: DummyData.demoUserId,
        text: 'That would be amazing! I can teach you UI/UX in return.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageModel(
        id: 'm1',
        chatId: 'chat_2',
        senderId: 'user_3',
        text: 'Hey! I saw you want to learn Web Dev. I can help!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }

  Future<List<ChatModel>> getChats(String userId) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return DummyData.demoChats;
    }
    // Single-field query only — sort in app (avoids composite index on first run).
    final snapshot = await _firestore!
        .collection(AppConfig.chatsCollection)
        .where('participantIds', arrayContains: userId)
        .get();
    final chats = snapshot.docs
        .map((d) => ChatModel.fromMap(d.data(), d.id, currentUserId: userId))
        .toList();
    chats.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return chats;
  }

  Future<String> createChat({
    required String user1Id,
    required String user2Id,
    required String user1Name,
    required String user2Name,
    String? user1Photo,
    String? user2Photo,
  }) async {
    final chatId = user1Id.compareTo(user2Id) < 0
        ? '${user1Id}_$user2Id'
        : '${user2Id}_$user1Id';

    if (AppConfig.isDemoMode) {
      final exists = DummyData.demoChats.any((c) => c.id == chatId);
      if (!exists) {
        DummyData.demoChats.insert(
          0,
          ChatModel(
            id: chatId,
            participantIds: [user1Id, user2Id],
            lastMessage: 'You are now connected! Start sharing your skills.',
            lastMessageAt: DateTime.now(),
            otherUserName: user1Id == DummyData.demoUserId ? user2Name : user1Name,
            otherUserId: user1Id == DummyData.demoUserId ? user2Id : user1Id,
            isOtherOnline: true,
            unreadCount: 0,
          ),
        );
      }
      return chatId;
    }

    final docRef = _firestore!.collection(AppConfig.chatsCollection).doc(chatId);
    final doc = await docRef.get();

    if (!doc.exists) {
      final chat = ChatModel(
        id: chatId,
        participantIds: [user1Id, user2Id],
        lastMessage: 'You are now connected! Start sharing your skills.',
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
        names: {
          user1Id: user1Name,
          user2Id: user2Name,
        },
        photoUrls: {
          user1Id: user1Photo ?? '',
          user2Id: user2Photo ?? '',
        },
      );
      await docRef.set(chat.toMap());

      await sendMessage(
        chatId: chatId,
        senderId: user1Id,
        text: 'You are now connected! Start sharing your skills.',
      );
    }
    return chatId;
  }

  Stream<List<MessageModel>> watchMessages(String chatId) async* {
    if (AppConfig.isDemoMode) {
      yield _demoMessages.where((m) => m.chatId == chatId).toList();
      yield* _demoStream.stream.map((_) => _demoMessages.where((m) => m.chatId == chatId).toList());
      return;
    }
    yield* _firestore!
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
    if (AppConfig.isDemoMode) {
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
      _demoStream.add(_demoMessages);

      final chatIndex = DummyData.demoChats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        final chat = DummyData.demoChats[chatIndex];
        DummyData.demoChats[chatIndex] = ChatModel(
          id: chat.id,
          participantIds: chat.participantIds,
          lastMessage: text,
          lastMessageAt: DateTime.now(),
          otherUserName: chat.otherUserName,
          otherUserId: chat.otherUserId,
          isOtherOnline: chat.isOtherOnline,
          unreadCount: chat.unreadCount,
        );
      }
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

    final chatRef =
        _firestore!.collection(AppConfig.chatsCollection).doc(chatId);

    await chatRef.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });
  }
}
