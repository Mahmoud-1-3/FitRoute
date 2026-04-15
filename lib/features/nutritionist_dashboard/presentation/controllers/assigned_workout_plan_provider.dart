import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/workout_model.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';

/// ─── Assigned Workout Plan Provider ────────────────────────────────────────
/// Real-time stream of the user's assigned workout plan from Firestore.
/// Automatically updates whenever the nutritionist regenerates the plan.

final assignedWorkoutPlanProvider =
    StreamProvider.autoDispose<List<WorkoutModel>>((ref) {
  final user = ref.watch(userProvider);
  
  if (user == null) {
    return Stream.value([]);
  }

  // Listen to the user's workout plan collection in Firestore
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('workoutPlans')
      .orderBy('updatedAt', descending: true)
      .limit(1)
      .snapshots()
      .asyncMap((snapshot) async {
    if (snapshot.docs.isEmpty) {
      return [];
    }

    final doc = snapshot.docs.first;
    final data = doc.data();
    
    // The plan document contains a 'workouts' array field
    final workoutsData = (data['workouts'] as List<dynamic>?) ?? [];
    
    return workoutsData.map((workoutJson) {
      // Ensure workout has required id field
      final workoutMap = Map<String, dynamic>.from(workoutJson as Map<String, dynamic>);
      workoutMap['id'] = workoutMap['id'] ?? doc.id + '_${workoutsData.indexOf(workoutJson)}';
      return WorkoutModel.fromJson(workoutMap);
    }).toList();
  });
});
