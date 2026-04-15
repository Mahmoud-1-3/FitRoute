import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/local_storage_service.dart';
import './user_provider.dart';

/// ─── User Assignment Stream Provider ───────────────────────────────────────
/// Real-time stream that listens to the user's Firestore document for changes
/// to the assignedNutritionistId field. When the nutritionist accepts the
/// assignment, this stream updates and syncs to Hive, triggering UI rebuilds.

final userAssignmentStreamProvider =
    StreamProvider.autoDispose<UserModel?>((ref) {
  final user = ref.watch(userProvider);
  
  if (user == null) {
    return Stream.value(null);
  }

  // Listen to the user's document in Firestore
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    
    final data = snapshot.data();
    if (data == null) return null;
    
    // Ensure the document has an id field
    data['id'] = snapshot.id;
    
    final firestoreUser = UserModel.fromJson(data);
    
    // Sync to Hive if there are changes (especially assignedNutritionistId)
    try {
      final box = Hive.box<UserModel>(LocalStorageService.userBox);
      final localUser = box.get('current_user');
      
      // If assignedNutritionistId changed (or any field changed), update Hive
      if (localUser != null && 
          localUser.assignedNutritionistId != firestoreUser.assignedNutritionistId) {
        debugPrint(
          '[UserAssignmentStream] 📡 Assignment change detected! '
          'Old: ${localUser.assignedNutritionistId}, New: ${firestoreUser.assignedNutritionistId}',
        );
        box.put('current_user', firestoreUser);
        debugPrint('[UserAssignmentStream] ✅ Synced to Hive - UI will update!');
      }
    } catch (e) {
      debugPrint('[UserAssignmentStream] ⚠️ Hive sync failed: $e');
    }
    
    return firestoreUser;
  });
});
