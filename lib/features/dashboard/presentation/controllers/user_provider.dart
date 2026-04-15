import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../shared/data/user_repository.dart';

/// ─── User Notifier ─────────────────────────────────────────────────────────
/// Exposes the current [UserModel] from the local Hive store.
/// It actively listens to the Hive box so any updates (like login/logout)
/// instantly trigger a rebuild across the app.

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier(this.ref) : super(ref.read(userRepositoryProvider).getUser()) {
    _box = Hive.box<UserModel>(LocalStorageService.userBox);
    _listenToBox();
  }

  final Ref ref;
  late final Box<UserModel> _box;

  void _listenToBox() {
    _box.listenable(keys: ['current_user']).addListener(() {
      final updatedUser = _box.get('current_user');
      debugPrint('[UserProvider] Current user box changed: ${updatedUser?.fullName}, assigned: ${updatedUser?.assignedNutritionistId}');
      state = updatedUser;
    });
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(ref);
});
