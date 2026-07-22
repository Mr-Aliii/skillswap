import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/models/connection_request_model.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/services/chat_service.dart';
import 'package:skill_swap/services/notification_service.dart';
import 'package:skill_swap/services/user_service.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// Service to handle connection requests between users.
class ConnectionService {
  ConnectionService({
    required UserService userService,
    required ChatService chatService,
    required NotificationService notificationService,
  })  : _userService = userService,
        _chatService = chatService,
        _notificationService = notificationService;

  final UserService _userService;
  final ChatService _chatService;
  final NotificationService _notificationService;

  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  /// Fetch the connection request between two users, if it exists.
  Future<ConnectionRequestModel?> getConnectionRequest(
      String userId1, String userId2) async {
    if (AppConfig.isDemoMode) {
      for (final req in DummyData.demoConnectionRequests) {
        if ((req.senderId == userId1 && req.receiverId == userId2) ||
            (req.senderId == userId2 && req.receiverId == userId1)) {
          return req;
        }
      }
      return null;
    }

    // Attempt Sender = userId1, Receiver = userId2
    final doc1 = await _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc('${userId1}_$userId2')
        .get();
    if (doc1.exists) {
      return ConnectionRequestModel.fromMap(doc1.data()!, doc1.id);
    }

    // Attempt Sender = userId2, Receiver = userId1
    final doc2 = await _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc('${userId2}_$userId1')
        .get();
    if (doc2.exists) {
      return ConnectionRequestModel.fromMap(doc2.data()!, doc2.id);
    }

    return null;
  }

  /// Send a connection request.
  Future<void> sendConnectionRequest({
    required String senderId,
    required String receiverId,
    required String senderName,
  }) async {
    final docId = '${senderId}_$receiverId';

    if (AppConfig.isDemoMode) {
      // Check if already exists
      final exists = DummyData.demoConnectionRequests.any((r) => r.id == docId);
      if (exists) return;

      final req = ConnectionRequestModel(
        id: docId,
        senderId: senderId,
        receiverId: receiverId,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      DummyData.demoConnectionRequests.add(req);

      final notif = NotificationModel(
        id: 'n_conn_${DateTime.now().millisecondsSinceEpoch}',
        userId: receiverId,
        title: 'Connection Request',
        body: '$senderName wants to connect with you.',
        type: 'connection_request',
        createdAt: DateTime.now(),
        data: {
          'connectionRequestId': docId,
          'senderId': senderId,
          'senderName': senderName,
        },
      );
      DummyData.demoNotifications.insert(0, notif);
      return;
    }

    final docRef = _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc(docId);

    final doc = await docRef.get();
    if (doc.exists) {
      final currentStatus = doc.data()?['status'] as String?;
      if (currentStatus == 'pending' || currentStatus == 'accepted') {
        return; // Already exists and is active
      }
    }

    final req = ConnectionRequestModel(
      id: docId,
      senderId: senderId,
      receiverId: receiverId,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await docRef.set(req.toMap());

    // Create recipient notification document
    final notifRef = _firestore!
        .collection(AppConfig.notificationsCollection)
        .doc();
    final notif = NotificationModel(
      id: notifRef.id,
      userId: receiverId,
      title: 'Connection Request',
      body: '$senderName wants to connect with you.',
      type: 'connection_request',
      createdAt: DateTime.now(),
      data: {
        'connectionRequestId': docId,
        'senderId': senderId,
        'senderName': senderName,
      },
    );
    await notifRef.set(notif.toMap());
  }

  /// Accept a connection request.
  Future<void> acceptConnectionRequest({
    required String requestId,
    required String currentUserId,
    required String currentUserName,
  }) async {
    if (AppConfig.isDemoMode) {
      final reqIndex = DummyData.demoConnectionRequests
          .indexWhere((r) => r.id == requestId);
      if (reqIndex == -1) return;

      final req = DummyData.demoConnectionRequests[reqIndex];
      DummyData.demoConnectionRequests[reqIndex] =
          req.copyWith(status: 'accepted');

      final sender = DummyData.recommendedUsers.firstWhere(
        (u) => u.id == req.senderId,
        orElse: () => DummyData.demoUser,
      );

      // Create a chat room in demo data
      final chatRoomId = 'chat_${req.senderId}_${req.receiverId}';
      final chatExists = DummyData.demoChats.any((c) => c.id == chatRoomId);
      if (!chatExists) {
        DummyData.demoChats.insert(
          0,
          ChatModel(
            id: chatRoomId,
            participantIds: [req.senderId, req.receiverId],
            lastMessage: 'You are now connected! Start sharing your skills.',
            lastMessageAt: DateTime.now(),
            otherUserName: sender.name,
            otherUserId: sender.id,
            isOtherOnline: sender.isOnline,
            unreadCount: 0,
          ),
        );
      }

      // Add connection accepted notification for the sender
      DummyData.demoNotifications.insert(
        0,
        NotificationModel(
          id: 'n_acc_${DateTime.now().millisecondsSinceEpoch}',
          userId: req.senderId,
          title: 'Connection Accepted',
          body: '$currentUserName accepted your connection request. Start chatting!',
          type: 'match',
          createdAt: DateTime.now(),
        ),
      );

      // Find and delete/mark read the incoming request notification
      final notifIndex = DummyData.demoNotifications.indexWhere((n) =>
          n.type == 'connection_request' &&
          n.data?['connectionRequestId'] == requestId);
      if (notifIndex != -1) {
        // Mark as read or remove. Let's update it to a simple read "match" notification
        final oldN = DummyData.demoNotifications[notifIndex];
        DummyData.demoNotifications[notifIndex] = NotificationModel(
          id: oldN.id,
          userId: oldN.userId,
          title: 'Connected',
          body: 'You connected with ${sender.name}.',
          type: 'match',
          isRead: true,
          createdAt: oldN.createdAt,
        );
      }
      return;
    }

    final docRef = _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc(requestId);

    await docRef.update({'status': 'accepted'});

    final doc = await docRef.get();
    if (!doc.exists) return;
    final req = ConnectionRequestModel.fromMap(doc.data()!, doc.id);

    // Fetch sender and receiver profiles to create chat
    final userSender = await _userService.getUser(req.senderId);
    final userReceiver = await _userService.getUser(req.receiverId);

    if (userSender != null && userReceiver != null) {
      // Create chat room
      await _chatService.createChat(
        user1Id: req.senderId,
        user2Id: req.receiverId,
        user1Name: userSender.name,
        user2Name: userReceiver.name,
        user1Photo: userSender.photoUrl,
        user2Photo: userReceiver.photoUrl,
      );

      // Notify the sender that the request was accepted
      final notifRef = _firestore!
          .collection(AppConfig.notificationsCollection)
          .doc();
      final notif = NotificationModel(
        id: notifRef.id,
        userId: req.senderId,
        title: 'Connection Accepted',
        body: '$currentUserName accepted your connection request. Start chatting!',
        type: 'match',
        createdAt: DateTime.now(),
      );
      await notifRef.set(notif.toMap());

      // Mark the original connection request notifications as read
      final notifSnapshot = await _firestore!
          .collection(AppConfig.notificationsCollection)
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'connection_request')
          .get();

      for (final nDoc in notifSnapshot.docs) {
        final data = nDoc.data();
        if (data['data']?['connectionRequestId'] == requestId) {
          await nDoc.reference.update({
            'isRead': true,
            'title': 'Connected',
            'body': 'You connected with ${userSender.name}.',
            'type': 'match',
          });
        }
      }
    }
  }

  /// Decline a connection request.
  Future<void> declineConnectionRequest({
    required String requestId,
    required String currentUserId,
  }) async {
    if (AppConfig.isDemoMode) {
      final reqIndex = DummyData.demoConnectionRequests
          .indexWhere((r) => r.id == requestId);
      if (reqIndex != -1) {
        DummyData.demoConnectionRequests.removeAt(reqIndex);
      }

      // Mark notification as read
      final notifIndex = DummyData.demoNotifications.indexWhere((n) =>
          n.type == 'connection_request' &&
          n.data?['connectionRequestId'] == requestId);
      if (notifIndex != -1) {
        DummyData.demoNotifications.removeAt(notifIndex);
      }
      return;
    }

    // Set connection status to declined or delete it
    final docRef = _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc(requestId);
    await docRef.delete();

    // Mark notifications as read or delete
    final notifSnapshot = await _firestore!
        .collection(AppConfig.notificationsCollection)
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'connection_request')
        .get();

    for (final nDoc in notifSnapshot.docs) {
      final data = nDoc.data();
      if (data['data']?['connectionRequestId'] == requestId) {
        await nDoc.reference.delete();
      }
    }
  }

  /// Cancel a pending request sent by current user.
  Future<void> cancelConnectionRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final docId = '${senderId}_$receiverId';

    if (AppConfig.isDemoMode) {
      DummyData.demoConnectionRequests.removeWhere((r) => r.id == docId);

      // Remove the notification from receiver's inbox
      DummyData.demoNotifications.removeWhere((n) =>
          n.userId == receiverId &&
          n.type == 'connection_request' &&
          n.data?['connectionRequestId'] == docId);
      return;
    }

    await _firestore!
        .collection(AppConfig.connectionRequestsCollection)
        .doc(docId)
        .delete();

    // Query and delete the notification sent to receiver
    final notifSnapshot = await _firestore!
        .collection(AppConfig.notificationsCollection)
        .where('userId', isEqualTo: receiverId)
        .where('type', isEqualTo: 'connection_request')
        .get();

    for (final nDoc in notifSnapshot.docs) {
      final data = nDoc.data();
      if (data['data']?['connectionRequestId'] == docId) {
        await nDoc.reference.delete();
      }
    }
  }
}
