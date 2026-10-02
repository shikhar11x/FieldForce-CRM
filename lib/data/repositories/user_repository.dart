import '../models/directory_models.dart';

/// Phase 2 swaps the mock implementation for an API-backed one.
abstract class UserRepository {
  Future<List<DirectoryUser>> getUsers();
  Future<DirectoryUser> createUser(DirectoryUser user);
  Future<DirectoryUser> updateUser(DirectoryUser user);
}