import '../models/task_enums.dart';
import '../models/task_models.dart';
import 'mock_customers.dart';

class MockTasks {
  const MockTasks._();

  static DateTime _at(int dayOffset, int hour, [int minute = 0]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
  }

  static const _employees = [
    'Rohan Verma',
    'Sneha Reddy',
    'Arjun Nair',
    'Kavya Iyer',
    'Imran Khan',
    'Neha Kapoor',
  ];

  static TaskFormOptions formOptions() {
    return TaskFormOptions(
      customers: [for (final c in MockCustomers.all()) c.company],
      employees: _employees,
    );
  }

  static List<TaskItem> all() {
    return [
      TaskItem(
        id: 't1',
        title: 'Collect signed contract',
        description:
            'Pick up the signed annual supply contract and confirm the '
            'revised payment terms with the owner.',
        customer: 'Sunrise Traders',
        assignee: 'Rohan Verma',
        due: _at(0, 14),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        location: 'Sector 9 Main Bazaar',
      ),
      TaskItem(
        id: 't2',
        title: 'Product demo for new range',
        description:
            'Demonstrate the new packaging range to the purchase team. '
            'Carry the sample kit and the printed brochure.',
        customer: 'Greenfield Foods',
        assignee: 'Rohan Verma',
        due: _at(0, 15, 30),
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        location: 'Industrial Area Phase 2',
      ),
      TaskItem(
        id: 't3',
        title: 'Payment follow-up',
        description: 'Follow up on the invoice due this week.',
        customer: 'Metro Hardware',
        assignee: 'Rohan Verma',
        due: _at(0, 17),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        location: 'Sector 14 Market Road',
      ),
      TaskItem(
        id: 't4',
        title: 'Deliver product samples',
        description: '',
        customer: 'Apex Pharma',
        assignee: 'Rohan Verma',
        due: _at(1, 11),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        location: 'Civil Lines Road',
      ),
      TaskItem(
        id: 't5',
        title: 'Share revised price list',
        description: 'Email and WhatsApp the Q4 price list to the owner.',
        customer: 'Bright Electricals',
        assignee: 'Rohan Verma',
        due: _at(-2, 17),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        location: 'Model Town Chowk',
      ),
      TaskItem(
        id: 't6',
        title: 'Quarterly stock audit',
        description: 'Verify shelf stock against the last delivery challan.',
        customer: 'Metro Hardware',
        assignee: 'Rohan Verma',
        due: _at(-3, 12),
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        location: 'Sector 14 Market Road',
      ),
      TaskItem(
        id: 't7',
        title: 'Onboarding kit handover',
        description: 'Hand over the welcome kit and walk through the app.',
        customer: 'Kisan Agro Supplies',
        assignee: 'Imran Khan',
        due: _at(1, 10, 30),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        location: 'Mandi Road',
      ),
      TaskItem(
        id: 't8',
        title: 'Renewal discussion',
        description: 'Discuss the annual contract renewal and volume pricing.',
        customer: 'Ocean Logistics',
        assignee: 'Neha Kapoor',
        due: _at(2, 13),
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        location: 'Transport Nagar',
      ),
      TaskItem(
        id: 't9',
        title: 'Menu pricing proposal',
        description: 'Prepare a bulk pricing proposal for 12 outlets.',
        customer: 'Urban Cafe Chain',
        assignee: 'Sneha Reddy',
        due: _at(2, 12),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        location: 'City Centre Mall',
      ),
      TaskItem(
        id: 't10',
        title: 'Re-activation call',
        description: 'Check why orders stopped and offer a returning discount.',
        customer: 'Lotus Stationers',
        assignee: 'Kavya Iyer',
        due: _at(-1, 16),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        location: 'Old Market Lane',
      ),
      TaskItem(
        id: 't11',
        title: 'Warranty claim inspection',
        description: 'Inspection no longer needed. Customer closed the claim.',
        customer: 'Silverline Textiles',
        assignee: 'Arjun Nair',
        due: _at(3, 11),
        priority: TaskPriority.medium,
        status: TaskStatus.cancelled,
        location: 'Weavers Colony',
      ),
      TaskItem(
        id: 't12',
        title: 'Install demo display unit',
        description: 'Set up the counter display and brief the store staff.',
        customer: 'Apex Pharma',
        assignee: 'Sneha Reddy',
        due: _at(-5, 10),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        location: 'Civil Lines Road',
      ),
      TaskItem(
        id: 't13',
        title: 'Collect feedback survey',
        description: '',
        customer: 'Sunrise Traders',
        assignee: 'Arjun Nair',
        due: _at(4, 15),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        location: 'Sector 9 Main Bazaar',
      ),
    ];
  }
}