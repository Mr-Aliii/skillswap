import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/booking_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:skill_swap/widgets/common/empty_state.dart';

/// My Bookings screen - view and manage all bookings for the current user.
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid ??
        DummyData.demoUserId;
    final bookingsAsync = ref.watch(myBookingsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyState(
              title: 'No bookings yet',
              subtitle: 'Book a session with someone to start learning!',
              icon: Icons.event_available,
            );
          }

          final allBookings = bookings;
          final pendingBookings =
              bookings.where((b) => b.status == 'pending').toList();
          final confirmedBookings =
              bookings.where((b) => b.status == 'confirmed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingsList(bookings: allBookings, currentUserId: uid),
              _BookingsList(bookings: pendingBookings, currentUserId: uid),
              _BookingsList(bookings: confirmedBookings, currentUserId: uid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          title: 'Failed to load bookings',
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final List<BookingModel> bookings;
  final String currentUserId;

  const _BookingsList({required this.bookings, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No bookings in this category'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isHost = booking.hostId == currentUserId;
        final isRequester = booking.requesterId == currentUserId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.skill,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isHost
                                ? 'Requested by: ${_getUserName(booking.requesterId)}'
                                : 'With: ${_getUserName(booking.hostId)}',
                            style: TextStyle(
                              color: context.theme.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(status: booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: context.theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: context.theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.timeSlot,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.hintColor,
                      ),
                    ),
                  ],
                ),
                if (booking.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.note,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.hintColor,
                      ),
                    ),
                  ),
                ],
                if (booking.status == 'pending' && isHost) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(
                            context,
                            ref,
                            booking.id,
                            'rejected',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _updateStatus(
                            context,
                            ref,
                            booking.id,
                            'confirmed',
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (booking.status == 'pending' && isRequester) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(
                      context,
                      ref,
                      booking.id,
                      'cancelled',
                    ),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getUserName(String userId) {
    // In a real app, this would fetch from a user cache/provider
    return userId == DummyData.demoUserId
        ? 'You'
        : 'User'; // Simplified for demo
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String bookingId, String status) {
    ref.read(bookingServiceProvider).updateBookingStatus(bookingId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${status == 'confirmed' ? 'confirmed' : status == 'rejected' ? 'rejected' : 'cancelled'}'),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'confirmed':
        color = AppColors.success;
        break;
      case 'completed':
        color = AppColors.primary;
        break;
      case 'cancelled':
      case 'rejected':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Provider for fetching user bookings
final myBookingsProvider =
    FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  return await ref.read(bookingServiceProvider).getUserBookings(userId);
});