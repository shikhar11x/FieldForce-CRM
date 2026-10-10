import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/customer_models.dart';
import '../models/task_enums.dart';
import 'customer_repository.dart';

class ApiCustomerRepository implements CustomerRepository {
  ApiCustomerRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Customer>> getCustomers() async {
    final response = await _api.dio.get<List<dynamic>>('/customers');
    return [
      for (final item in response.data!)
        Customer.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<CustomerDetail> getCustomerDetail(String id) async {
    final response = await _api.dio.get<Map<String, dynamic>>('/customers/$id');
    final data = response.data!;

    final customer = Customer.fromJson(
      data['customer'] as Map<String, dynamic>,
    );
    final notes = [
      for (final item in data['notes'] as List<dynamic>)
        CustomerNote.fromJson(item as Map<String, dynamic>),
    ];
    final visits = [
      for (final item in (data['visits'] as List<dynamic>? ?? const []))
        _visitFromJson(item as Map<String, dynamic>),
    ];

    final activities = <CustomerActivity>[
      for (final n in notes)
        CustomerActivity(
          type: CustomerActivityType.note,
          title: 'Note by ${n.author}',
          description: n.text,
          timestamp: n.timestamp,
        ),
      for (final v in visits)
        CustomerActivity(
          type: CustomerActivityType.visit,
          title: switch (v.status) {
            VisitStatus.completed => 'Visit completed',
            VisitStatus.scheduled => 'Visit scheduled',
            VisitStatus.started => 'Visit in progress',
            VisitStatus.cancelled => 'Visit cancelled',
          },
          description: '${v.employee}: ${v.purpose}',
          timestamp: v.date,
        ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Documents ka API abhi nahi bana.
    return CustomerDetail(
      customer: customer,
      activities: activities,
      visits: visits,
      notes: notes,
      documents: const <CustomerDocument>[],
    );
  }

  CustomerVisit _visitFromJson(Map<String, dynamic> json) {
    return CustomerVisit(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String).toLocal(),
      employee: json['employee'] as String,
      purpose: json['purpose'] as String,
      status: VisitStatus.fromApi(json['status'] as String),
    );
  }

  @override
  Future<Customer> createCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  }) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/customers',
        data: customer.toRequestJson(includeManaged: includeManagedFields),
      );
      return Customer.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<Customer> updateCustomer(
    Customer customer, {
    bool includeManagedFields = true,
  }) async {
    try {
      final response = await _api.dio.patch<Map<String, dynamic>>(
        '/customers/${customer.id}',
        data: customer.toRequestJson(includeManaged: includeManagedFields),
      );
      return Customer.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<CustomerNote> addNote(String customerId, String text) async {
    try {
      final response = await _api.dio.post<Map<String, dynamic>>(
        '/customers/$customerId/notes',
        data: {'text': text},
      );
      return CustomerNote.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}
