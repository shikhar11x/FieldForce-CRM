import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/report_filters_provider.dart';
import '../widgets/attendance_report_view.dart';
import '../widgets/customer_report_view.dart';
import '../widgets/employee_report_view.dart';
import '../widgets/export_sheet.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/sales_report_view.dart';

/// Manager: the Reports tab. Admin: a full-screen page from the dashboard.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _names = [
    'Sales report',
    'Employee report',
    'Customer report',
    'Attendance report',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final filters = ref.watch(reportFiltersProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final query = filters.query;

    return DefaultTabController(
      length: _names.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Export report',
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () => showExportSheet(
                  context,
                  reportName: _names[DefaultTabController.of(context).index],
                  rangeLabel: filters.rangeLabel,
                ),
              ),
            ),
          ],
        ),
        body: ResponsiveBody(
          maxWidth: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ReportFilterBar(),
              const SizedBox(height: AppSpacing.sm),
              const TabBar(
                tabs: [
                  Tab(text: 'Sales'),
                  Tab(text: 'Employee'),
                  Tab(text: 'Customer'),
                  Tab(text: 'Attendance'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SalesReportView(query: query),
                    EmployeeReportView(query: query),
                    CustomerReportView(query: query),
                    AttendanceReportView(query: query),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}