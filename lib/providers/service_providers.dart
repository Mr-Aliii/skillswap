import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/services/auth_service.dart';
import 'package:skill_swap/services/booking_service.dart';
import 'package:skill_swap/services/chat_service.dart';
import 'package:skill_swap/services/connection_service.dart';
import 'package:skill_swap/services/notification_service.dart';
import 'package:skill_swap/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(userService: ref.watch(userServiceProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final bookingServiceProvider =
    Provider<BookingService>((ref) => BookingService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final connectionServiceProvider = Provider<ConnectionService>((ref) {
  return ConnectionService(
    userService: ref.watch(userServiceProvider),
    chatService: ref.watch(chatServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});
