import '../models/directory_models.dart';

abstract class UserRepository {
  Future<List<DirectoryUser>> getUsers();
  Future<CreatedUser> createUser(DirectoryUser user);
  Future<DirectoryUser> updateUser(DirectoryUser user);
}