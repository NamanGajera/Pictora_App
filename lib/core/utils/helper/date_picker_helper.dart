// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:intl/intl.dart';

class DatePickerHelper {
  /// Shows a date picker dialog and returns the selected date
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
  }) async {
    final DateTime now = DateTime.now();

    // Fix: Use the Material library's showDatePicker explicitly
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialEntryMode: initialEntryMode,
      locale: locale,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      textDirection: textDirection,
      builder: builder,
      initialDatePickerMode: initialDatePickerMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
    );
  }

  /// Shows a date range picker dialog and returns the selected date range
  static Future<DateTimeRange?> showDateRangePicker({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    String? errorFormatText,
    String? errorInvalidText,
    String? errorInvalidRangeText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  }) async {
    // Fix: Use the Material library's showDateRangePicker explicitly
    return await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      saveText: saveText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      errorInvalidRangeText: errorInvalidRangeText,
      fieldStartHintText: fieldStartHintText,
      fieldEndHintText: fieldEndHintText,
      fieldStartLabelText: fieldStartLabelText,
      fieldEndLabelText: fieldEndLabelText,
      locale: locale,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      textDirection: textDirection,
      builder: builder,
      initialEntryMode: initialEntryMode,
    );
  }

  /// Shows a time picker dialog and returns the selected time
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    TransitionBuilder? builder,
    bool useRootNavigator = true,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? hourLabelText,
    String? minuteLabelText,
    RouteSettings? routeSettings,
    EntryModeChangeCallback? onEntryModeChanged,
  }) async {
    // Fix: Use the Material library's showTimePicker explicitly
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: builder,
      useRootNavigator: useRootNavigator,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      hourLabelText: hourLabelText,
      minuteLabelText: minuteLabelText,
      routeSettings: routeSettings,
      onEntryModeChanged: onEntryModeChanged,
    );
  }

  /// Shows a combined date and time picker
  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateHelpText,
    String? timeHelpText,
    DatePickerEntryMode datePickerMode = DatePickerEntryMode.calendar,
    TimePickerEntryMode timePickerMode = TimePickerEntryMode.dial,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime initial = initialDateTime ?? now;

    // First pick the date
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: dateHelpText,
      initialEntryMode: datePickerMode,
    );

    if (selectedDate == null) return null;

    // Then pick the time
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: timeHelpText,
      initialEntryMode: timePickerMode,
    );

    if (selectedTime == null) return null;

    // Combine date and time
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  /// Format date to string with various predefined formats
  static String formatDate(DateTime date, {DateFormat? customFormat}) {
    if (customFormat != null) {
      return customFormat.format(date);
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format time to string
  static String formatTime(TimeOfDay time, {bool use24HourFormat = false}) {
    final hour = use24HourFormat ? time.hour : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');

    if (use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:$minute';
    } else {
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : hour;
      return '$displayHour:$minute $period';
    }
  }

  /// Format datetime to string
  static String formatDateTime(
    DateTime dateTime, {
    String dateFormat = 'dd/MM/yyyy',
    bool use24HourFormat = false,
  }) {
    final date = DateFormat(dateFormat).format(dateTime);
    final time = formatTime(TimeOfDay.fromDateTime(dateTime), use24HourFormat: use24HourFormat);
    return '$date $time';
  }

  /// Format date range to string
  static String formatDateRange(DateTimeRange range, {String format = 'dd/MM/yyyy'}) {
    final startDate = DateFormat(format).format(range.start);
    final endDate = DateFormat(format).format(range.end);
    return '$startDate - $endDate';
  }

  /// Predefined date formats
  static const Map<String, String> dateFormats = {
    'dd/MM/yyyy': 'dd/MM/yyyy',
    'MM/dd/yyyy': 'MM/dd/yyyy',
    'yyyy-MM-dd': 'yyyy-MM-dd',
    'dd-MM-yyyy': 'dd-MM-yyyy',
    'MMM dd, yyyy': 'MMM dd, yyyy',
    'MMMM dd, yyyy': 'MMMM dd, yyyy',
    'EEEE, MMMM dd, yyyy': 'EEEE, MMMM dd, yyyy',
    'dd MMM yyyy': 'dd MMM yyyy',
    'dd MMMM yyyy': 'dd MMMM yyyy',
  };

  /// Get formatted date with predefined format
  static String getFormattedDate(DateTime date, String formatKey) {
    final format = dateFormats[formatKey] ?? 'dd/MM/yyyy';
    return DateFormat(format).format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Get relative date string (Today, Yesterday, Tomorrow, or formatted date)
  static String getRelativeDateString(DateTime date, {String format = 'dd/MM/yyyy'}) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isTomorrow(date)) return 'Tomorrow';
    return DateFormat(format).format(date);
  }

  /// Calculate age from birthdate
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Get difference between two dates in days
  static int getDaysDifference(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  /// Validate date range
  static bool isValidDateRange(DateTime startDate, DateTime endDate) {
    return startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  }
}

/// Extension methods for DateTime for additional convenience
extension DateTimeExtension on DateTime {
  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  /// Check if date is weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if date is weekday
  bool get isWeekday => !isWeekend;
}

/// Reusable Date Picker Widget
class DatePickerField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onDateSelected;
  final String dateFormat;
  final bool enabled;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final bool showClearButton;

  const DatePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.dateFormat = 'dd/MM/yyyy',
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.textStyle,
    this.showClearButton = true,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _selectDate : null,
      child: InputDecorator(
        decoration: widget.decoration ??
            InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon ?? const Icon(Icons.calendar_today),
              suffixIcon: _buildSuffixIcon(),
              border: const OutlineInputBorder(),
            ),
        child: Text(
          _selectedDate != null ? DateFormat(widget.dateFormat).format(_selectedDate!) : (widget.hintText ?? 'Select Date'),
          style: widget.textStyle ??
              (_selectedDate != null
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      )),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!widget.showClearButton || _selectedDate == null) {
      return widget.suffixIcon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.suffixIcon != null) widget.suffixIcon!,
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearDate,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await DatePickerHelper.showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected?.call(picked);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    widget.onDateSelected?.call(null);
  }
}
