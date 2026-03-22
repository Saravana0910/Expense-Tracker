import '../../../core/constants/app_constants.dart';
import '../../../core/models/user.dart';
import '../../../core/services/database_service.dart';

class UserService {
  final DatabaseService _db = DatabaseService();

  Future<User?> getCurrentUser() async {
    final box = _db.usersBox;
    final users = box.values.where((u) => u.id == AppConstants.defaultUserId);
    return users.isNotEmpty ? users.first : null;
  }

  Future<void> createOrUpdateUser({
    required String name,
    String? avatarPath,
  }) async {
    final existingUser = await getCurrentUser();
    final user = User(
      id: AppConstants.defaultUserId,
      name: name,
      avatarPath: avatarPath,
    );

    final box = _db.usersBox;
    await box.put(user.id, user);
  }

  Future<void> updateUser(User user) async {
    final box = _db.usersBox;
    await box.put(user.id, user);
  }
}