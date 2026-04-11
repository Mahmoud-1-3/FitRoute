import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';

final activeClientsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null || user.role != 'nutritionist') {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .where('assignedNutritionistId', isEqualTo: user.id)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // explicitly ensure id is set
      return UserModel.fromJson(data);
    }).toList();
  });
});
