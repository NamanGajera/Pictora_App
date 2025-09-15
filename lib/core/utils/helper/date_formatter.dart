// Third-party
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  static const String defaultFormat = 'yyyy-MM-dd';
  static const String fullDateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String dayMonthYear = 'dd/MM/yyyy';
  static const String monthDayYear = 'MM/dd/yyyy';
  static const String timeOnly = 'HH:mm';
  static const String dateTimeWithAmPm = 'MMM dd, yyyy hh:mm a';
  static const String dayName = 'EEEE';
  static const String iso8601 = 'yyyy-MM-ddTHH:mm:ss';

  static String? formatDate({
    dynamic dateInput,
    String format = defaultFormat,
    String? inputFormat,
    String? locale,
  }) {
    try {
      DateTime? dateTime = _parseDate(dateInput, inputFormat);
      if (dateTime == null) return null;

      return DateFormat(format, locale).format(dateTime);
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDate(dynamic dateInput, String? inputFormat) {
    if (dateInput == null) return null;

    if (dateInput is DateTime) {
      return dateInput;
    } else if (dateInput is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateInput);
    } else if (dateInput is String) {
      try {
        if (inputFormat != null) {
          return DateFormat(inputFormat).parse(dateInput);
        } else {
          // Try common formats automatically
          return _tryParseString(dateInput);
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Tries to parse a date string with common formats
  static DateTime? _tryParseString(String dateString) {
    // Try ISO8601 first
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (_) {}

    // Try common formats
    final commonFormats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'yyyy/MM/dd',
      'MMM dd, yyyy',
      'MMMM dd, yyyy',
    ];

    for (final format in commonFormats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {}
    }

    return null;
  }

  /// Gets the relative time (e.g., "5 minutes ago")
  static String getRelativeTime(dynamic dateInput, {String? inputFormat}) {
    final dateTime = _parseDate(dateInput, inputFormat);
    if (dateTime == null) return 'Invalid date';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(dateInput: dateTime, format: monthDayYear) ?? 'Invalid date';
    }
  }

  /// Checks if a date is today
  static bool isToday(dynamic dateInput, {String? inputFormat}) {
    final dateTime = _parseDate(dateInput, inputFormat);
    if (dateTime == null) return false;

    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  /// Gets the day name (e.g., "Monday")
  static String? getDayName(dynamic dateInput, {String? inputFormat}) {
    return formatDate(
      dateInput: dateInput,
      format: dayName,
      inputFormat: inputFormat,
    );
  }

  /// Gets the time portion only (e.g., "14:30")
  static String? getTimeOnly(dynamic dateInput, {String? inputFormat}) {
    return formatDate(
      dateInput: dateInput,
      format: timeOnly,
      inputFormat: inputFormat,
    );
  }

  static String timeAgoShort(dynamic dateInput, {String? inputFormat, String locale = 'en_short_clean'}) {
    final dateTime = _parseDate(dateInput, inputFormat);
    if (dateTime == null) return 'Invalid date';

    return timeago
        .format(
          dateTime,
          locale: locale,
          allowFromNow: false,
        )
        .trim();
  }
}

class ShortEnMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => 'from now';
  @override
  String lessThanOneMinute(int seconds) => 'Just now';

  @override
  String aboutAMinute(int minutes) => '1 minute ago';
  @override
  String minutes(int minutes) => '$minutes minutes ago';

  @override
  String aboutAnHour(int minutes) => '1 hour ago';
  @override
  String hours(int hours) => '$hours hours ago';

  @override
  String aDay(int hours) => '1 day ago';
  @override
  String days(int days) => '$days days ago';

  @override
  String aboutAMonth(int days) => '1 month ago';
  @override
  String months(int months) => '$months months ago';

  @override
  String aboutAYear(int year) => '1 year ago';
  @override
  String years(int years) => '$years years ago';
  @override
  String wordSeparator() => ' ';
}
