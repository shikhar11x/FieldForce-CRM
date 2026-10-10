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
  Future<CreatedUser> createUser(DirectoryUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return CreatedUser(user: user, temporaryPassword: 'Welcome123');
  }

  @override
  Future<DirectoryUser> updateUser(DirectoryUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return user;
  }
}