/// A calendar day in the user's local time zone.
///
/// The value deliberately stores date components instead of an instant. This
/// means moving to the next day remains correct across daylight-saving changes.
class LocalDay {
  LocalDay(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Invalid local calendar day.');
    }
  }

  factory LocalDay.fromDateTime(DateTime value) =>
      LocalDay(value.year, value.month, value.day);

  final int year;
  final int month;
  final int day;

  /// A date-only local [DateTime] for repository ports that use date fields.
  DateTime get date => DateTime(year, month, day);

  LocalDay previous() {
    final value = DateTime.utc(year, month, day - 1);
    return LocalDay.fromDateTime(value);
  }

  LocalDay next() {
    final value = DateTime.utc(year, month, day + 1);
    return LocalDay.fromDateTime(value);
  }

  bool contains(DateTime value) =>
      value.year == year && value.month == month && value.day == day;

  @override
  bool operator ==(Object other) =>
      other is LocalDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
