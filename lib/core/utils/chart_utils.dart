import 'dart:math' as math;

class ChartScale {
  const ChartScale(this.max, this.interval);

  final double max;
  final double interval;
}

/// Picks a readable axis maximum and grid interval for [dataMax].
ChartScale niceScale(double dataMax, {int ticks = 4}) {
  if (dataMax <= 0) return const ChartScale(10, 2.5);

  final rough = dataMax / ticks;
  final magnitude =
      math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final normalized = rough / magnitude;
  const steps = [1.0, 2.0, 2.5, 5.0, 10.0];
  final interval = steps.firstWhere((s) => normalized <= s) * magnitude;

  return ChartScale((dataMax / interval).ceil() * interval, interval);
}

String formatAxisValue(double v) {
  if (v >= 1000) {
    final k = v / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
  }
  return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}