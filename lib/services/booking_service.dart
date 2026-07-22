import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/booking_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:uuid/uuid.dart';

/// Session booking requests with full lifecycle management.
class BookingService {
  final _uuid = const Uuid();

  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  Future<String> createBooking({
    required String requesterId,
    required String hostId,
    required String skill,
    required DateTime date,
    required String timeSlot,
    String note = '',
  }) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final booking = BookingModel(
        id: _uuid.v4(),
        requesterId: requesterId,
        hostId: hostId,
        skill: skill,
        date: date,
        timeSlot: timeSlot,
        note: note,
        createdAt: DateTime.now(),
      );
      DummyData.demoBookings.add(booking);
      return booking.id;
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

  /// Get bookings for a user (either as requester or host)
  Future<List<BookingModel>> getUserBookings(String userId) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return DummyData.demoBookings
          .where((b) => b.requesterId == userId || b.hostId == userId)
          .toList();
    }
    final snapshot = await _firestore!
        .collection(AppConfig.bookingsCollection)
        .where('requesterId', isEqualTo: userId)
        .get();
    
    final snapshot2 = await _firestore!
        .collection(AppConfig.bookingsCollection)
        .where('hostId', isEqualTo: userId)
        .get();
    
    final allDocs = [...snapshot.docs, ...snapshot2.docs];
    final seenIds = <String>{};
    final uniqueDocs = allDocs.where((doc) {
      if (seenIds.contains(doc.id)) return false;
      seenIds.add(doc.id);
      return true;
    }).toList();
    
    return uniqueDocs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Update booking status (accept, reject, cancel, complete)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    if (AppConfig.isDemoMode) {
      final index = DummyData.demoBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = DummyData.demoBookings[index];
        DummyData.demoBookings[index] = booking.copyWith(status: newStatus);
      }
      return;
    }
    await _firestore!
        .collection(AppConfig.bookingsCollection)
        .doc(bookingId)
        .update({'status': newStatus});
  }

  /// Cancel a booking (only by requester)
  Future<void> cancelBooking(String bookingId, String requesterId) async {
    if (AppConfig.isDemoMode) {
      final index = DummyData.demoBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1 && DummyData.demoBookings[index].requesterId == requesterId) {
        DummyData.demoBookings[index] = 
            DummyData.demoBookings[index].copyWith(status: 'cancelled');
      }
      return;
    }
    await updateBookingStatus(bookingId, 'cancelled');
  }

  /// Get pending bookings for a host
  Future<List<BookingModel>> getPendingBookingsForHost(String hostId) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return DummyData.demoBookings
          .where((b) => b.hostId == hostId && b.status == 'pending')
          .toList();
    }
    final snapshot = await _firestore!
        .collection(AppConfig.bookingsCollection)
        .where('hostId', isEqualTo: hostId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
