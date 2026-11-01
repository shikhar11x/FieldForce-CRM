import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/location/device_location.dart';
import '../../core/network/api_exception.dart';
import 'providers/today_attendance_provider.dart';

/// Home ke quick action aur attendance card, dono yahin se check-in karte hain.
Future<void> performCheckIn(BuildContext context, WidgetRef ref) =>
    _perform(context, ref, checkIn: true);

Future<void> performCheckOut(BuildContext context, WidgetRef ref) =>
    _perform(context, ref, checkIn: false);

Future<void> _perform(
  BuildContext context,
  WidgetRef ref, {
  required bool checkIn,
}) async {
  if (ref.read(attendanceBusyProvider)) return;

  final busy = ref.read(attendanceBusyProvider.notifier);
  final notifier = ref.read(todayAttendanceProvider.notifier);
  busy.set(true);

  try {
    if (checkIn) {
      await notifier.checkIn();
    } else {
      await notifier.checkOut();
    }
    if (context.mounted) {
      context.showSnack(
        checkIn
            ? 'Checked in. Have a productive day!'
            : 'Checked out. See you tomorrow!',
      );
    }
  } on LocationException catch (e) {
    if (context.mounted) context.showSnack(e.message);
  } on ApiException catch (e) {
    // Server ka jawab state se alag ho sakta hai (jaise doosre phone se
    // pehle hi check-in), isliye aaj ka status dobara load karo.
    if (context.mounted) {
      ref.invalidate(todayAttendanceProvider);
      context.showSnack(e.message);
    }
  } catch (_) {
    if (context.mounted) {
      context.showSnack('Something went wrong. Please try again.');
    }
  } finally {
    busy.set(false);
  }
}