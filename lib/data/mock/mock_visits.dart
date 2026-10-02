import '../models/task_enums.dart';
import '../models/visit_models.dart';

class MockVisits {
  const MockVisits._();

  static DateTime _at(int dayOffset, int hour, [int minute = 0]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
  }

  static List<VisitEvent> _created(DateTime visitAt) => [
        VisitEvent(
          type: VisitEventType.scheduled,
          title: 'Visit scheduled',
          timestamp: visitAt.subtract(const Duration(days: 1)),
        ),
      ];

  static List<VisitItem> all() {
    return [
      VisitItem(
        id: 'v1',
        customer: 'Metro Hardware',
        employee: 'Rohan Verma',
        scheduledAt: _at(0, 9, 30),
        location: '12, Sector 14 Market Road',
        status: VisitStatus.completed,
        type: VisitType.sales,
        purpose: 'Order follow-up and stock check',
        startedAt: _at(0, 9, 35),
        completedAt: _at(0, 10, 40),
        qrVerified: true,
        notes: [
          VisitNote(
            id: 'v1-n1',
            author: 'Rohan Verma',
            text: 'Stock levels are healthy. Owner wants revised pricing '
                'on the cement range.',
            timestamp: _at(0, 10, 20),
          ),
        ],
        attachments: [
          VisitAttachment(
            id: 'v1-a1',
            name: 'Shelf photo.jpg',
            kind: 'Photo',
            size: '2.1 MB',
            uploaded: _at(0, 10, 15),
          ),
        ],
        events: [
          ..._created(_at(0, 9, 30)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(0, 9, 35),
          ),
          VisitEvent(
            type: VisitEventType.qrVerified,
            title: 'QR code verified',
            timestamp: _at(0, 9, 36),
          ),
          VisitEvent(
            type: VisitEventType.photo,
            title: 'Photo uploaded',
            timestamp: _at(0, 10, 15),
          ),
          VisitEvent(
            type: VisitEventType.note,
            title: 'Note added',
            timestamp: _at(0, 10, 20),
          ),
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: _at(0, 10, 40),
          ),
        ],
      ),
      VisitItem(
        id: 'v2',
        customer: 'Sunrise Traders',
        employee: 'Rohan Verma',
        scheduledAt: _at(0, 11),
        location: '45, Sector 9 Main Bazaar',
        status: VisitStatus.completed,
        type: VisitType.sales,
        purpose: 'Contract renewal paperwork',
        startedAt: _at(0, 11, 5),
        completedAt: _at(0, 11, 50),
        qrVerified: true,
        notes: [
          VisitNote(
            id: 'v2-n1',
            author: 'Rohan Verma',
            text: 'Signed contract copy collected from the owner.',
            timestamp: _at(0, 11, 45),
          ),
        ],
        events: [
          ..._created(_at(0, 11)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(0, 11, 5),
          ),
          VisitEvent(
            type: VisitEventType.qrVerified,
            title: 'QR code verified',
            timestamp: _at(0, 11, 6),
          ),
          VisitEvent(
            type: VisitEventType.note,
            title: 'Note added',
            timestamp: _at(0, 11, 45),
          ),
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: _at(0, 11, 50),
          ),
        ],
      ),
      VisitItem(
        id: 'v3',
        customer: 'Greenfield Foods',
        employee: 'Rohan Verma',
        scheduledAt: _at(0, 13, 30),
        location: 'Plot 8, Industrial Area Phase 2',
        status: VisitStatus.started,
        type: VisitType.demo,
        purpose: 'Product demo for the new packaging range',
        startedAt: _at(0, 13, 35),
        qrVerified: true,
        events: [
          ..._created(_at(0, 13, 30)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(0, 13, 35),
          ),
          VisitEvent(
            type: VisitEventType.qrVerified,
            title: 'QR code verified',
            timestamp: _at(0, 13, 36),
          ),
        ],
      ),
      VisitItem(
        id: 'v4',
        customer: 'Apex Pharma',
        employee: 'Rohan Verma',
        scheduledAt: _at(0, 15),
        location: '3, Civil Lines Road',
        status: VisitStatus.scheduled,
        type: VisitType.followUp,
        purpose: 'Follow up on sample feedback',
        events: _created(_at(0, 15)),
      ),
      VisitItem(
        id: 'v5',
        customer: 'Bright Electricals',
        employee: 'Rohan Verma',
        scheduledAt: _at(0, 16, 30),
        location: '21, Model Town Chowk',
        status: VisitStatus.scheduled,
        type: VisitType.delivery,
        purpose: 'Deliver the Q4 display kit',
        events: _created(_at(0, 16, 30)),
      ),
      VisitItem(
        id: 'v6',
        customer: 'Metro Hardware',
        employee: 'Rohan Verma',
        scheduledAt: _at(-1, 15, 30),
        location: '12, Sector 14 Market Road',
        status: VisitStatus.completed,
        type: VisitType.service,
        purpose: 'Service check on the display unit',
        startedAt: _at(-1, 15, 35),
        completedAt: _at(-1, 16, 15),
        qrVerified: true,
        notes: [
          VisitNote(
            id: 'v6-n1',
            author: 'Rohan Verma',
            text: 'Replaced the faulty LED strip. Unit working normally.',
            timestamp: _at(-1, 16, 10),
          ),
        ],
        events: [
          ..._created(_at(-1, 15, 30)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(-1, 15, 35),
          ),
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: _at(-1, 16, 15),
          ),
        ],
      ),
      VisitItem(
        id: 'v7',
        customer: 'Greenfield Foods',
        employee: 'Rohan Verma',
        scheduledAt: _at(2, 10),
        location: 'Plot 8, Industrial Area Phase 2',
        status: VisitStatus.scheduled,
        type: VisitType.sales,
        purpose: 'Annual contract renewal discussion',
        events: _created(_at(2, 10)),
      ),
      VisitItem(
        id: 'v8',
        customer: 'Ocean Logistics',
        employee: 'Neha Kapoor',
        scheduledAt: _at(3, 11, 30),
        location: 'Warehouse 4, Transport Nagar',
        status: VisitStatus.scheduled,
        type: VisitType.sales,
        purpose: 'Volume pricing negotiation',
        events: _created(_at(3, 11, 30)),
      ),
      VisitItem(
        id: 'v9',
        customer: 'Kisan Agro Supplies',
        employee: 'Imran Khan',
        scheduledAt: _at(1, 10),
        location: '88, Mandi Road',
        status: VisitStatus.scheduled,
        type: VisitType.demo,
        purpose: 'Onboarding and product walkthrough',
        events: _created(_at(1, 10)),
      ),
      VisitItem(
        id: 'v10',
        customer: 'Urban Cafe Chain',
        employee: 'Sneha Reddy',
        scheduledAt: _at(2, 12),
        location: '2, City Centre Mall',
        status: VisitStatus.scheduled,
        type: VisitType.sales,
        purpose: 'Bulk pricing proposal for 12 outlets',
        events: _created(_at(2, 12)),
      ),
      VisitItem(
        id: 'v11',
        customer: 'Silverline Textiles',
        employee: 'Arjun Nair',
        scheduledAt: _at(-10, 12),
        location: '16, Weavers Colony',
        status: VisitStatus.cancelled,
        type: VisitType.followUp,
        purpose: 'Dormant account check-in',
        events: [
          ..._created(_at(-10, 12)),
          VisitEvent(
            type: VisitEventType.cancelled,
            title: 'Visit cancelled',
            timestamp: _at(-10, 8),
          ),
        ],
      ),
      VisitItem(
        id: 'v12',
        customer: 'Lotus Stationers',
        employee: 'Kavya Iyer',
        scheduledAt: _at(-75, 11),
        location: '7, Old Market Lane',
        status: VisitStatus.completed,
        type: VisitType.followUp,
        purpose: 'Check why orders have slowed',
        startedAt: _at(-75, 11, 5),
        completedAt: _at(-75, 11, 40),
        events: [
          ..._created(_at(-75, 11)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(-75, 11, 5),
          ),
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: _at(-75, 11, 40),
          ),
        ],
      ),
      VisitItem(
        id: 'v13',
        customer: 'Apex Pharma',
        employee: 'Sneha Reddy',
        scheduledAt: _at(-6, 11),
        location: '3, Civil Lines Road',
        status: VisitStatus.completed,
        type: VisitType.service,
        purpose: 'Install the counter display unit',
        startedAt: _at(-6, 11, 10),
        completedAt: _at(-6, 12, 5),
        qrVerified: true,
        events: [
          ..._created(_at(-6, 11)),
          VisitEvent(
            type: VisitEventType.started,
            title: 'Visit started',
            timestamp: _at(-6, 11, 10),
          ),
          VisitEvent(
            type: VisitEventType.completed,
            title: 'Visit completed',
            timestamp: _at(-6, 12, 5),
          ),
        ],
      ),
    ];
  }
}