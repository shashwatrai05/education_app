import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../service/firestore_service.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, AppUser?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<AppUser?> {
  // Hardcoding userId for simplicity, you can fetch it dynamically or pass it from UI.
  final String userId = 'user123';

  @override
  Future<AppUser?> build() async {
    return await FirestoreService().getUser(userId);  // Pass userId to getUser
  }

  Future<void> updateUser(String name) async {
    await FirestoreService().updateUserName(userId, name); // Pass userId and name to updateUserName
    state = AsyncData(await FirestoreService().getUser(userId));  // Refresh user data
  }
}
