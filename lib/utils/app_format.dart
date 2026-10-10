import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Money and date formatting in the active language.
///
/// Digits stay Western in both languages so amounts line up the same way in
/// English and Arabic; month and weekday names follow the locale.
class AppFormat {
  const AppFormat._();

  static String get _locale => Get.locale?.languageCode ?? 'en';

  static final NumberFormat _money = NumberFormat('#,##0.##', 'en');
  static final NumberFormat _compact = NumberFormat.compact(locale: 'en');

  /// `$ 1,250.5`, or `- $ 40` with [signed] set on an expense.
  static String money(double value, String symbol, {bool? income}) {
    final String body = '$symbol ${_money.format(value.abs())}';
    if (income == null) return value < 0 ? '- $body' : body;
    return income ? '+ $body' : '- $body';
  }

  /// A short axis label: 1.2K, 350, 4M.
  static String compact(double value) => _compact.format(value);

  static String dayMonth(DateTime date) =>
      DateFormat('d MMMM', _locale).format(date);

  static String dayMonthShort(DateTime date) =>
      DateFormat('d MMM', _locale).format(date);

  static String weekdayDayMonth(DateTime date) =>
      DateFormat('EEE, d MMM', _locale).format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', _locale).format(date);

  static String time(DateTime date) => DateFormat('HH:mm', _locale).format(date);

  static String weekdayShort(DateTime date) =>
      DateFormat('E', _locale).format(date);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "Today", "Yesterday", or the date.
  static String relativeDay(DateTime date) {
    final DateTime now = DateTime.now();
    if (sameDay(date, now)) return 'today'.tr;
    if (sameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'yesterday'.tr;
    }
    return date.year == now.year
        ? DateFormat('EEEE, d MMMM', _locale).format(date)
        : DateFormat('d MMMM yyyy', _locale).format(date);
  }
}
