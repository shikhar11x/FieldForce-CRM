import '../models/customer_models.dart';
import '../models/task_enums.dart';

class MockCustomers {
  const MockCustomers._();

  static DateTime _at(int dayOffset, [int hour = 11, int minute = 0]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
  }

  static List<Customer> all() {
    return [
      Customer(
        id: 'c1',
        company: 'Metro Hardware',
        contactName: 'Vikram Malhotra',
        phone: '+91 98100 11001',
        email: 'vikram@metrohardware.in',
        address: '12, Sector 14 Market Road',
        status: CustomerStatus.active,
        assignedEmployee: 'Rohan Verma',
        lastVisit: _at(-1, 15, 30),
        nextVisit: _at(6, 10, 30),
        highPriority: true,
      ),
      Customer(
        id: 'c2',
        company: 'Sunrise Traders',
        contactName: 'Anita Desai',
        phone: '+91 98100 11002',
        email: 'anita@sunrisetraders.in',
        address: '45, Sector 9 Main Bazaar',
        status: CustomerStatus.active,
        assignedEmployee: 'Arjun Nair',
        lastVisit: _at(-3, 12),
        nextVisit: _at(4, 14),
      ),
      Customer(
        id: 'c3',
        company: 'Greenfield Foods',
        contactName: 'Sanjay Gupta',
        phone: '+91 98100 11003',
        email: 'sanjay@greenfieldfoods.in',
        address: 'Plot 8, Industrial Area Phase 2',
        status: CustomerStatus.active,
        assignedEmployee: 'Rohan Verma',
        lastVisit: _at(0, 9, 30),
        nextVisit: _at(2, 13, 30),
        highPriority: true,
      ),
      Customer(
        id: 'c4',
        company: 'Apex Pharma',
        contactName: 'Dr. Meera Joshi',
        phone: '+91 98100 11004',
        email: 'meera@apexpharma.in',
        address: '3, Civil Lines Road',
        status: CustomerStatus.active,
        assignedEmployee: 'Sneha Reddy',
        lastVisit: _at(-6, 11),
        nextVisit: _at(1, 15),
      ),
      Customer(
        id: 'c5',
        company: 'Bright Electricals',
        contactName: 'Rajesh Kumar',
        phone: '+91 98100 11005',
        email: 'rajesh@brightelectricals.in',
        address: '21, Model Town Chowk',
        status: CustomerStatus.active,
        assignedEmployee: 'Rohan Verma',
        lastVisit: _at(-9, 16),
        nextVisit: _at(5, 16, 30),
      ),
      Customer(
        id: 'c6',
        company: 'Lotus Stationers',
        contactName: 'Pooja Bansal',
        phone: '+91 98100 11006',
        email: 'pooja@lotusstationers.in',
        address: '7, Old Market Lane',
        status: CustomerStatus.inactive,
        assignedEmployee: 'Kavya Iyer',
        lastVisit: _at(-75, 11),
      ),
      Customer(
        id: 'c7',
        company: 'Kisan Agro Supplies',
        contactName: 'Harpreet Singh',
        phone: '+91 98100 11007',
        email: 'harpreet@kisanagro.in',
        address: '88, Mandi Road',
        status: CustomerStatus.newCustomer,
        assignedEmployee: 'Imran Khan',
        nextVisit: _at(1, 10),
      ),
      Customer(
        id: 'c8',
        company: 'Ocean Logistics',
        contactName: 'Farhan Sheikh',
        phone: '+91 98100 11008',
        email: 'farhan@oceanlogistics.in',
        address: 'Warehouse 4, Transport Nagar',
        status: CustomerStatus.active,
        assignedEmployee: 'Neha Kapoor',
        lastVisit: _at(-2, 14),
        nextVisit: _at(3, 11, 30),
        highPriority: true,
      ),
      Customer(
        id: 'c9',
        company: 'Silverline Textiles',
        contactName: 'Deepa Nair',
        phone: '+91 98100 11009',
        email: 'deepa@silverlinetextiles.in',
        address: '16, Weavers Colony',
        status: CustomerStatus.inactive,
        assignedEmployee: 'Arjun Nair',
        lastVisit: _at(-120, 12),
      ),
      Customer(
        id: 'c10',
        company: 'Urban Cafe Chain',
        contactName: 'Tanya Arora',
        phone: '+91 98100 11010',
        email: 'tanya@urbancafe.in',
        address: '2, City Centre Mall',
        status: CustomerStatus.newCustomer,
        assignedEmployee: 'Sneha Reddy',
        nextVisit: _at(2, 12),
        highPriority: true,
      ),
    ];
  }

  static CustomerDetail detail(Customer c) {
    final now = DateTime.now();
    final emp = c.assignedEmployee;
    final hasHistory = c.status != CustomerStatus.newCustomer;
    final last = c.lastVisit;
    final next = c.nextVisit;

    final activities = <CustomerActivity>[
      if (next != null)
        CustomerActivity(
          type: CustomerActivityType.visit,
          title: 'Visit scheduled',
          description: '$emp scheduled a visit for ${_label(next)}.',
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
      if (last != null)
        CustomerActivity(
          type: CustomerActivityType.visit,
          title: 'Visit completed',
          description: '$emp met ${c.contactName} and reviewed open orders.',
          timestamp: last,
        ),
      if (hasHistory) ...[
        CustomerActivity(
          type: CustomerActivityType.call,
          title: 'Call with ${c.contactName}',
          description: 'Discussed delivery timelines. Duration 8 min.',
          timestamp: _at(-5, 10, 15),
        ),
        CustomerActivity(
          type: CustomerActivityType.note,
          title: 'Note added',
          description: 'Prefers morning visits and WhatsApp updates.',
          timestamp: _at(-8, 12),
        ),
        CustomerActivity(
          type: CustomerActivityType.task,
          title: 'Task completed',
          description: 'Product catalogue shared with ${c.contactName}.',
          timestamp: _at(-6, 17),
        ),
      ],
      CustomerActivity(
        type: CustomerActivityType.statusUpdate,
        title: 'Customer created',
        description: 'Added to the CRM and assigned to $emp.',
        timestamp: now.subtract(Duration(days: hasHistory ? 90 : 1)),
      ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return CustomerDetail(
      customer: c,
      activities: activities,
      visits: [
        if (next != null)
          CustomerVisit(
            id: '${c.id}-v3',
            date: next,
            employee: emp,
            purpose: 'Quarterly business review',
            status: VisitStatus.scheduled,
          ),
        if (last != null)
          CustomerVisit(
            id: '${c.id}-v2',
            date: last,
            employee: emp,
            purpose: 'Order follow-up and stock check',
            status: VisitStatus.completed,
          ),
        if (hasHistory)
          CustomerVisit(
            id: '${c.id}-v1',
            date: _at(-30, 11),
            employee: emp,
            purpose: 'Product demo',
            status: VisitStatus.completed,
          ),
      ],
      tasks: c.status == CustomerStatus.inactive
          ? const <CustomerTask>[]
          : [
              CustomerTask(
                id: '${c.id}-t1',
                title: 'Share revised price list',
                due: _at(2, 17),
                priority: TaskPriority.high,
                status: TaskStatus.inProgress,
              ),
              CustomerTask(
                id: '${c.id}-t2',
                title: 'Collect pending payment',
                due: _at(5, 12),
                priority: TaskPriority.medium,
                status: TaskStatus.pending,
              ),
              if (hasHistory)
                CustomerTask(
                  id: '${c.id}-t3',
                  title: 'Send product catalogue',
                  due: _at(-6, 17),
                  priority: TaskPriority.low,
                  status: TaskStatus.completed,
                ),
            ],
      notes: [
        if (c.highPriority)
          CustomerNote(
            id: '${c.id}-n2',
            author: 'Priya Sharma',
            text: 'Priority account this quarter. Keep pricing '
                'discussions with the manager.',
            timestamp: _at(-3, 9, 30),
          ),
        if (hasHistory)
          CustomerNote(
            id: '${c.id}-n1',
            author: emp,
            text: 'Prefers morning visits. Decision maker is '
                '${c.contactName}.',
            timestamp: _at(-8, 12),
          ),
      ],
      documents: hasHistory
          ? [
              CustomerDocument(
                id: '${c.id}-d1',
                name: 'Master Service Agreement.pdf',
                kind: 'PDF',
                size: '1.2 MB',
                uploaded: _at(-80),
              ),
              CustomerDocument(
                id: '${c.id}-d2',
                name: 'GST Certificate.pdf',
                kind: 'PDF',
                size: '480 KB',
                uploaded: _at(-80),
              ),
              CustomerDocument(
                id: '${c.id}-d3',
                name: 'Price List Q3.xlsx',
                kind: 'XLS',
                size: '96 KB',
                uploaded: _at(-14),
              ),
            ]
          : const <CustomerDocument>[],
    );
  }

  static String _label(DateTime d) => '${d.day}/${d.month}/${d.year}';
}