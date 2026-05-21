import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';

/// Book a learning session with date/time picker.
class BookSessionScreen extends ConsumerStatefulWidget {
  const BookSessionScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  final String targetUserId;
  final String targetUserName;

  @override
  ConsumerState<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends ConsumerState<BookSessionScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  String _selectedSkill = 'Skill Exchange';
  bool _requestSent = false;
  bool _isLoading = false;

  static const _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  Future<void> _book() async {
    setState(() => _isLoading = true);
    final uid = ref.read(authStateProvider).valueOrNull?.uid ??
        DummyData.demoUserId;
    try {
      await ref.read(bookingServiceProvider).createBooking(
            requesterId: uid,
            hostId: widget.targetUserId,
            skill: _selectedSkill,
            date: _selectedDate,
            timeSlot: _selectedTime,
          );
      setState(() {
        _requestSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) context.showSnack('Booking failed', isError: true);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    if (_requestSent) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Request Sent!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your session request has been sent to ${widget.targetUserName}. You\'ll be notified when they respond.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.theme.hintColor),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Book with ${widget.targetUserName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schedule a skill exchange session',
              style: TextStyle(color: context.theme.hintColor),
            ),
            const SizedBox(height: 24),
            const Text('Skill', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSkill,
              items: const [
                DropdownMenuItem(value: 'Skill Exchange', child: Text('Skill Exchange')),
                DropdownMenuItem(value: 'Graphic Design', child: Text('Graphic Design')),
                DropdownMenuItem(value: 'Web Development', child: Text('Web Development')),
                DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
              ],
              onChanged: (v) => setState(() => _selectedSkill = v!),
            ),
            const SizedBox(height: 24),
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: context.theme.dividerColor),
              ),
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: Text(
                '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            const Text('Time', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final selected = _selectedTime == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedTime = slot),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            GradientButton(
              label: 'Send Request',
              icon: Icons.send,
              isLoading: _isLoading,
              onPressed: _book,
            ),
          ],
        ),
      ),
    );
  }
}
