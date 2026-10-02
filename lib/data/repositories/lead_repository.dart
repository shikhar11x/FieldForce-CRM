import '../models/lead_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class LeadRepository {
  Future<List<LeadItem>> getLeads();
  Future<LeadFormOptions> getFormOptions();
  Future<LeadItem> createLead(LeadItem lead);
  Future<LeadItem> updateLead(LeadItem lead);
}