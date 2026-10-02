extension DurationLabels on Duration {
  /// e.g. "7h 45m".
  String get hoursMinutes => '${inHours}h ${inMinutes.remainder(60)}m';
}