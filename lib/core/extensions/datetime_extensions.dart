const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

extension TimeAgo on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }
}

extension DateLabels on DateTime {
  String get shortDate => '$day ${_months[month - 1]} $year';

  /// "Today", "Tomorrow", "Yesterday", otherwise a short date.
  String get dayLabel {
    final now = DateTime.now();
    final diff = DateTime.utc(year, month, day)
        .difference(DateTime.utc(now.year, now.month, now.day))
        .inDays;
    return switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => shortDate,
    };
  }
}