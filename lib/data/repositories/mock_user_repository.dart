import '../mock/mock_directory.dart';
import '../models/directory_models.dart';
import 'user_repository.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<List<DirectoryUser>> getUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return MockDirectory.all();
  }

  @override
  Future<DirectoryUser> createUser(DirectoryUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return user;
  }

  @override
  Future<DirectoryUser> updateUser(DirectoryUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return user;
  }
}