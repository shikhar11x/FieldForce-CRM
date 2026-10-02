import '../models/map_models.dart';
import '../models/task_enums.dart';

class MockMap {
  const MockMap._();

  static MapData data() {
    return const MapData(
      route: ['r1', 'r2', 'r3', 'r4', 'r5'],
      markers: [
        MapMarkerData(
          id: 'me',
          kind: MapMarkerKind.me,
          title: 'Your location',
          subtitle: 'Placeholder. Live GPS arrives in Phase 2.',
          x: 0.46,
          y: 0.76,
        ),
        // Today's visit stops (same route as the Employee home screen).
        MapMarkerData(
          id: 'r1',
          kind: MapMarkerKind.visit,
          title: 'Metro Hardware',
          subtitle: 'Sector 14 Market Road · 9:30 AM',
          x: 0.08,
          y: 0.72,
          stopNumber: 1,
          visitStatus: VisitStatus.completed,
        ),
        MapMarkerData(
          id: 'r2',
          kind: MapMarkerKind.visit,
          title: 'Sunrise Traders',
          subtitle: 'Sector 9 Main Bazaar · 11:00 AM',
          x: 0.27,
          y: 0.30,
          stopNumber: 2,
          visitStatus: VisitStatus.completed,
        ),
        MapMarkerData(
          id: 'r3',
          kind: MapMarkerKind.visit,
          title: 'Greenfield Foods',
          subtitle: 'Industrial Area Phase 2 · 1:30 PM',
          x: 0.50,
          y: 0.58,
          stopNumber: 3,
          visitStatus: VisitStatus.started,
        ),
        MapMarkerData(
          id: 'r4',
          kind: MapMarkerKind.visit,
          title: 'Apex Pharma',
          subtitle: 'Civil Lines Road · 3:00 PM',
          x: 0.74,
          y: 0.24,
          stopNumber: 4,
          visitStatus: VisitStatus.scheduled,
        ),
        MapMarkerData(
          id: 'r5',
          kind: MapMarkerKind.visit,
          title: 'Bright Electricals',
          subtitle: 'Model Town Chowk · 4:30 PM',
          x: 0.92,
          y: 0.64,
          stopNumber: 5,
          visitStatus: VisitStatus.scheduled,
        ),
        // Team members.
        MapMarkerData(
          id: 'e2',
          kind: MapMarkerKind.employee,
          title: 'Sneha Reddy',
          subtitle: 'Visiting Urban Cafe Chain',
          x: 0.17,
          y: 0.16,
        ),
        MapMarkerData(
          id: 'e3',
          kind: MapMarkerKind.employee,
          title: 'Arjun Nair',
          subtitle: 'In transit · last seen 4 min ago',
          x: 0.62,
          y: 0.86,
        ),
        MapMarkerData(
          id: 'e4',
          kind: MapMarkerKind.employee,
          title: 'Kavya Iyer',
          subtitle: 'At Lotus Stationers',
          x: 0.86,
          y: 0.42,
        ),
        MapMarkerData(
          id: 'e5',
          kind: MapMarkerKind.employee,
          title: 'Imran Khan',
          subtitle: 'Idle · last seen 18 min ago',
          x: 0.12,
          y: 0.48,
        ),
        MapMarkerData(
          id: 'e6',
          kind: MapMarkerKind.employee,
          title: 'Neha Kapoor',
          subtitle: 'Heading to Ocean Logistics',
          x: 0.68,
          y: 0.54,
        ),
        // Other customers.
        MapMarkerData(
          id: 'c8',
          kind: MapMarkerKind.customer,
          title: 'Ocean Logistics',
          subtitle: 'Warehouse 4, Transport Nagar',
          x: 0.33,
          y: 0.90,
        ),
        MapMarkerData(
          id: 'c7',
          kind: MapMarkerKind.customer,
          title: 'Kisan Agro Supplies',
          subtitle: '88, Mandi Road',
          x: 0.58,
          y: 0.10,
        ),
        MapMarkerData(
          id: 'c6',
          kind: MapMarkerKind.customer,
          title: 'Lotus Stationers',
          subtitle: '7, Old Market Lane',
          x: 0.93,
          y: 0.16,
        ),
        MapMarkerData(
          id: 'c10',
          kind: MapMarkerKind.customer,
          title: 'Urban Cafe Chain',
          subtitle: '2, City Centre Mall',
          x: 0.38,
          y: 0.12,
        ),
      ],
    );
  }
}