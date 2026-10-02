/// Compact Indian-rupee format: ₹950, ₹45K, ₹3.2L, ₹1.2Cr.
String formatInr(double value) {
  String trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (value >= 10000000) return '₹${trim(value / 10000000)}Cr';
  if (value >= 100000) return '₹${trim(value / 100000)}L';
  if (value >= 1000) return '₹${trim(value / 1000)}K';
  return '₹${value.toStringAsFixed(0)}';
}