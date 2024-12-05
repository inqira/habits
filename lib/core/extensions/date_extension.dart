extension DateTimeExtension on DateTime {
  /// Returns date in ISO format (YYYY-MM-DD)
  String toFormattedDateString() {
    return '${year.toString()}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Returns normalized DateTime (start of day)
  DateTime toNormalizedDate() {
    return DateTime(year, month, day);
  }

  /// Returns date in short format (YYYYMMDD)
  String toShortDateString() {
    return '${year.toString()}'
        '${month.toString().padLeft(2, '0')}'
        '${day.toString().padLeft(2, '0')}';
  }
}
