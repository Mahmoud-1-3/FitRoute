import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/assignment_request_model.dart';
import '../../../../core/models/nutritionist_model.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';
import '../../data/assignment_repository.dart';

/// ─── Marketplace Providers ────────────────────────────────────────────────
/// Fetches and streams data strictly for the user-facing marketplace.

final nutritionistsListProvider = StreamProvider.autoDispose<List<NutritionistModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('nutritionists')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => NutritionistModel.fromJson(doc.data())).toList();
  });
});

final userRequestStatusProvider = StreamProvider.autoDispose<AssignmentRequestModel?>((ref) {
  final user = ref.watch(userProvider);
  if (user == null || user.role != 'user') {
    return Stream.value(null);
  }

  return ref.watch(assignmentRepositoryProvider).streamUserLatestRequest(user.id);
});
