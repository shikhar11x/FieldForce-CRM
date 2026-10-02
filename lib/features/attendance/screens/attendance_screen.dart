import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/my_attendance_view.dart';
import '../widgets/team_attendance_view.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final isEmployee = user.role == UserRole.employee;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEmployee ? 'My attendance' : 'Attendance'),
      ),
      body: isEmployee
          ? MyAttendanceView(employee: user.name)
          : TeamAttendanceView(basePath: user.role.basePath),
    );
  }
}