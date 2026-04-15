import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/meal_model.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';

/// ─── Assigned Diet Plan Provider ───────────────────────────────────────────
/// Real-time stream of the user's assigned diet plan from Firestore.
/// Automatically updates whenever the nutritionist regenerates the plan.

final assignedDietPlanProvider =
    StreamProvider.autoDispose<List<MealModel>>((ref) {
  final user = ref.watch(userProvider);
  
  if (user == null) {
    return Stream.value([]);
  }

  // Listen to the user's diet plan collection in Firestore
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('dietPlans')
      .orderBy('updatedAt', descending: true)
      .limit(1)
      .snapshots()
      .asyncMap((snapshot) async {
    if (snapshot.docs.isEmpty) {
      return [];
    }

    final doc = snapshot.docs.first;
    final data = doc.data();
    
    // The plan document contains a 'meals' array field
    final mealsData = (data['meals'] as List<dynamic>?) ?? [];
    
    return mealsData.map((mealJson) {
      // Ensure meal has required id field
      final mealMap = Map<String, dynamic>.from(mealJson as Map<String, dynamic>);
      mealMap['id'] = mealMap['id'] ?? doc.id + '_${mealsData.indexOf(mealJson)}';
      return MealModel.fromJson(mealMap);
    }).toList();
  });
});
