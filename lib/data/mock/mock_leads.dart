import '../models/lead_models.dart';
import '../models/task_enums.dart';

class MockLeads {
  const MockLeads._();

  static const _employees = [
    'Rohan Verma',
    'Sneha Reddy',
    'Arjun Nair',
    'Kavya Iyer',
    'Imran Khan',
    'Neha Kapoor',
  ];

  static const _sources = [
    'Referral',
    'Cold call',
    'Walk-in',
    'Website',
    'Trade show',
    'Existing customer',
  ];

  static LeadFormOptions formOptions() =>
      const LeadFormOptions(employees: _employees, sources: _sources);

  static LeadActivity _event(LeadStage stage, String contact, DateTime at) {
    final (type, title, text) = switch (stage) {
      LeadStage.newLead => (LeadActivityType.created, 'Lead created', ''),
      LeadStage.contacted => (
          LeadActivityType.call,
          'Intro call with $contact',
          'Discussed requirements and current suppliers.',
        ),
      LeadStage.qualified => (
          LeadActivityType.meeting,
          'Needs assessment',
          'Confirmed budget and decision timeline.',
        ),
      LeadStage.proposal => (
          LeadActivityType.email,
          'Proposal sent',
          'Shared the pricing proposal for review.',
        ),
      LeadStage.negotiation => (
          LeadActivityType.call,
          'Pricing negotiation',
          'Discussed volume discounts and payment terms.',
        ),
      LeadStage.won => (
          LeadActivityType.stageChange,
          'Moved to Won',
          'Deal closed. Handed over for onboarding.',
        ),
      LeadStage.lost => (
          LeadActivityType.stageChange,
          'Moved to Lost',
          'Customer chose another supplier.',
        ),
    };
    return LeadActivity(
      type: type,
      title: title,
      description: text,
      timestamp: at,
    );
  }

  /// Builds a plausible newest-first timeline for the given stage.
  static List<LeadActivity> _history({
    required String employee,
    required String contact,
    required LeadStage stage,
    required int createdDaysAgo,
  }) {
    final now = DateTime.now();

    final path = switch (stage) {
      LeadStage.newLead => const <LeadStage>[],
      LeadStage.lost => const [LeadStage.contacted, LeadStage.lost],
      LeadStage.won => const [
          LeadStage.contacted,
          LeadStage.qualified,
          LeadStage.proposal,
          LeadStage.negotiation,
          LeadStage.won,
        ],
      _ => LeadStage.values.sublist(1, stage.index + 1),
    };

    final totalHours = createdDaysAgo * 24;
    final events = <LeadActivity>[
      LeadActivity(
        type: LeadActivityType.created,
        title: 'Lead created',
        description: 'Added by $employee.',
        timestamp: now.subtract(Duration(hours: totalHours)),
      ),
      for (final (i, s) in path.indexed)
        _event(
          s,
          contact,
          now.subtract(
            Duration(
              hours:
                  (totalHours * (path.length - i) / (path.length + 1)).round(),
            ),
          ),
        ),
    ];
    return events.reversed.toList();
  }

  static LeadItem _lead({
    required String id,
    required String customer,
    required String contact,
    required int value,
    required String assignee,
    required TaskPriority priority,
    required LeadStage stage,
    required String source,
    required int createdDaysAgo,
    required int closeInDays,
    required String description,
  }) {
    final now = DateTime.now();
    return LeadItem(
      id: id,
      customer: customer,
      contactName: contact,
      value: value.toDouble(),
      assignee: assignee,
      priority: priority,
      stage: stage,
      source: source,
      expectedClose: DateTime(now.year, now.month, now.day + closeInDays),
      description: description,
      createdAt: now.subtract(Duration(days: createdDaysAgo)),
      activities: _history(
        employee: assignee,
        contact: contact,
        stage: stage,
        createdDaysAgo: createdDaysAgo,
      ),
    );
  }

  static List<LeadItem> all() {
    return [
      _lead(
        id: 'l1',
        customer: 'Greenfield Foods',
        contact: 'Sanjay Gupta',
        value: 320000,
        assignee: 'Sneha Reddy',
        priority: TaskPriority.high,
        stage: LeadStage.won,
        source: 'Referral',
        createdDaysAgo: 24,
        closeInDays: -2,
        description: 'Annual packaging supply contract for two plants.',
      ),
      _lead(
        id: 'l2',
        customer: 'Urban Cafe Chain',
        contact: 'Tanya Arora',
        value: 1850000,
        assignee: 'Sneha Reddy',
        priority: TaskPriority.high,
        stage: LeadStage.proposal,
        source: 'Trade show',
        createdDaysAgo: 12,
        closeInDays: 18,
        description: 'Bulk supply for 12 outlets across the city.',
      ),
      _lead(
        id: 'l3',
        customer: 'Ocean Logistics',
        contact: 'Farhan Sheikh',
        value: 2400000,
        assignee: 'Neha Kapoor',
        priority: TaskPriority.urgent,
        stage: LeadStage.negotiation,
        source: 'Existing customer',
        createdDaysAgo: 30,
        closeInDays: 7,
        description: 'Multi-year contract renewal with expanded volumes.',
      ),
      _lead(
        id: 'l4',
        customer: 'Kisan Agro Supplies',
        contact: 'Harpreet Singh',
        value: 450000,
        assignee: 'Imran Khan',
        priority: TaskPriority.medium,
        stage: LeadStage.qualified,
        source: 'Walk-in',
        createdDaysAgo: 8,
        closeInDays: 25,
        description: 'Seasonal stocking order for the rural network.',
      ),
      _lead(
        id: 'l5',
        customer: 'Metro Hardware',
        contact: 'Vikram Malhotra',
        value: 900000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.high,
        stage: LeadStage.negotiation,
        source: 'Existing customer',
        createdDaysAgo: 21,
        closeInDays: 9,
        description: 'Expansion order for the new Sector 21 showroom.',
      ),
      _lead(
        id: 'l6',
        customer: 'Sunrise Traders',
        contact: 'Anita Desai',
        value: 275000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.medium,
        stage: LeadStage.qualified,
        source: 'Referral',
        createdDaysAgo: 10,
        closeInDays: 20,
        description: 'Upsell of the premium product range.',
      ),
      _lead(
        id: 'l7',
        customer: 'Apex Pharma',
        contact: 'Dr. Meera Joshi',
        value: 1200000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.high,
        stage: LeadStage.proposal,
        source: 'Website',
        createdDaysAgo: 15,
        closeInDays: 14,
        description: 'Cold-chain packaging for the new product line.',
      ),
      _lead(
        id: 'l8',
        customer: 'Bright Electricals',
        contact: 'Rajesh Kumar',
        value: 180000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.low,
        stage: LeadStage.contacted,
        source: 'Cold call',
        createdDaysAgo: 5,
        closeInDays: 35,
        description: 'Display units for the Model Town store.',
      ),
      _lead(
        id: 'l9',
        customer: 'Horizon Retail',
        contact: 'Nikhil Rao',
        value: 600000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.medium,
        stage: LeadStage.newLead,
        source: 'Website',
        createdDaysAgo: 2,
        closeInDays: 40,
        description: '',
      ),
      _lead(
        id: 'l10',
        customer: 'Pioneer Packaging',
        contact: 'Isha Mehra',
        value: 750000,
        assignee: 'Arjun Nair',
        priority: TaskPriority.medium,
        stage: LeadStage.newLead,
        source: 'Trade show',
        createdDaysAgo: 3,
        closeInDays: 45,
        description: 'Met at the packaging expo. Interested in eco materials.',
      ),
      _lead(
        id: 'l11',
        customer: 'Lotus Stationers',
        contact: 'Pooja Bansal',
        value: 90000,
        assignee: 'Kavya Iyer',
        priority: TaskPriority.low,
        stage: LeadStage.lost,
        source: 'Existing customer',
        createdDaysAgo: 40,
        closeInDays: -10,
        description: 'Re-activation attempt for a dormant account.',
      ),
      _lead(
        id: 'l12',
        customer: 'Silverline Textiles',
        contact: 'Deepa Nair',
        value: 520000,
        assignee: 'Arjun Nair',
        priority: TaskPriority.medium,
        stage: LeadStage.contacted,
        source: 'Cold call',
        createdDaysAgo: 6,
        closeInDays: 30,
        description: 'Fabric packaging for the export line.',
      ),
      _lead(
        id: 'l13',
        customer: 'Delta Auto Parts',
        contact: 'Ravi Menon',
        value: 640000,
        assignee: 'Rohan Verma',
        priority: TaskPriority.high,
        stage: LeadStage.won,
        source: 'Referral',
        createdDaysAgo: 28,
        closeInDays: -5,
        description: 'Spare-parts packaging contract. Delivery starts next month.',
      ),
    ];
  }
}