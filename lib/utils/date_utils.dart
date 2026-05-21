import 'package:intl/intl.dart';

/// Date/time formatting utilities.
class AppDateUtils {
  AppDateUtils._();

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static String chatDivider(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return formatDate(date);
  }
}
