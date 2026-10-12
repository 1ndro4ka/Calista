import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Russian month names in genitive case for dates like "15 декабря 2026"
  static const List<String> _monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Formats date as: "15 декабря 2026"
  String toRussianFormattedString() {
    final monthName = _monthsGenitive[month - 1];
    return '$day $monthName $year';
  }

  /// Formats date and time: "15 декабря 2026, 14:30"
  String toRussianDateTimeString() {
    final monthName = _monthsGenitive[month - 1];
    final timeStr = DateFormat('HH:mm').format(this);
    return '$day $monthName $year, $timeStr';
  }

  /// Returns true if date is before today
  bool isExpired() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final thisDateStart = DateTime(year, month, day);
    return thisDateStart.isBefore(todayStart);
  }
}
