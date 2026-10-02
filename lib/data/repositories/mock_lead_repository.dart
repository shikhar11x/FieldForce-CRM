import '../mock/mock_leads.dart';
import '../models/lead_models.dart';
import 'lead_repository.dart';

class MockLeadRepository implements LeadRepository {
  @override
  Future<List<LeadItem>> getLeads() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return MockLeads.all();
  }

  @override
  Future<LeadFormOptions> getFormOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockLeads.formOptions();
  }

  @override
  Future<LeadItem> createLead(LeadItem lead) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return lead;
  }

  @override
  Future<LeadItem> updateLead(LeadItem lead) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return lead;
  }
}