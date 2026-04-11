import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nutritionist_model.dart';
import '../models/user_model.dart';

/// ─── Firestore Sync Service ────────────────────────────────────────────────
/// Handles cloud persistence for user and nutritionist profiles.
/// Called *after* the local Hive save so that the UI is never blocked
/// by network latency (Offline-First).

class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  // ── Collection references ──
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _nutritionistsCol =>
      _db.collection('nutritionists');

  /// Write or overwrite a user document at `users/{user.id}`.
  Future<void> saveUserToCloud(UserModel user) async {
    await _usersCol.doc(user.id).set(user.toJson());
  }

  /// Write or overwrite a nutritionist document at `nutritionists/{id}`.
  Future<void> saveNutritionistToCloud(NutritionistModel nutritionist) async {
    await _nutritionistsCol.doc(nutritionist.id).set(nutritionist.toJson());
  }

  /// Fetch a user document by ID (useful for login sync).
  Future<UserModel?> getUserFromCloud(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Fetch a nutritionist document by ID.
  Future<NutritionistModel?> getNutritionistFromCloud(String uid) async {
    final doc = await _nutritionistsCol.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return NutritionistModel.fromJson(doc.data()!);
    }
    return null;
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});
