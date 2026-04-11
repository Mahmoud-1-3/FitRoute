import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/local_storage_service.dart';

/// ─── User Repository ───────────────────────────────────────────────────────
/// Abstracts Hive CRUD for the logged-in user profile.

class UserRepository {
  UserRepository(this._box);
  final Box<UserModel> _box;

  static const String _key = 'current_user';

  /// Persist the current user.
  Future<void> saveUser(UserModel user) async {
    await _box.put(_key, user);
  }

  /// Retrieve the current user (or null if not set).
  UserModel? getUser() {
    return _box.get(_key);
  }

  /// Remove the current user (logout).
  Future<void> deleteUser() async {
    await _box.delete(_key);
  }

  /// Fetch a remote user profile (used by Nutritionists to view client details).
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      // Ignore or log error
    }
    return null;
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final box = Hive.box<UserModel>(LocalStorageService.userBox);
  return UserRepository(box);
});
