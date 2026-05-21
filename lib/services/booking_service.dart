import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/booking_model.dart';
import 'package:uuid/uuid.dart';

/// Session booking requests.
class BookingService {
  final _uuid = const Uuid();

  FirebaseFirestore? get _firestore =>
      AppConfig.useDemoMode ? null : FirebaseFirestore.instance;

  Future<String> createBooking({
    required String requesterId,
    required String hostId,
    required String skill,
    required DateTime date,
    required String timeSlot,
    String note = '',
  }) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return _uuid.v4();
    }
    final ref = _firestore!.collection(AppConfig.bookingsCollection).doc();
    final booking = BookingModel(
      id: ref.id,
      requesterId: requesterId,
      hostId: hostId,
      skill: skill,
      date: date,
      timeSlot: timeSlot,
      note: note,
      createdAt: DateTime.now(),
    );
    await ref.set(booking.toMap());
    return ref.id;
  }
}
