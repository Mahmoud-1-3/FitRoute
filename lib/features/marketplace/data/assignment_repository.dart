import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/assignment_request_model.dart';

class AssignmentRepository {
  final FirebaseFirestore _firestore;

  AssignmentRepository(this._firestore);

  Future<void> createRequest(AssignmentRequestModel request) async {
    await _firestore
        .collection('assignment_requests')
        .doc(request.id) // use the pre-generated ID
        .set(request.toJson());
  }

  Stream<List<AssignmentRequestModel>> streamPendingRequests(String nutritionistId) {
    return _firestore
        .collection('assignment_requests')
        .where('nutritionistId', isEqualTo: nutritionistId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              // Ensure doc ID is included if missing
              data['id'] = doc.id;
              return AssignmentRequestModel.fromJson(data);
            }).toList());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore
        .collection('assignment_requests')
        .doc(requestId)
        .update({'status': status});
  }

  Future<void> assignNutritionistToUser(String userId, String nutritionistId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'assignedNutritionistId': nutritionistId});
  }

  Stream<AssignmentRequestModel?> streamUserLatestRequest(String userId) {
    return _firestore
        .collection('assignment_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      
      final reqs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AssignmentRequestModel.fromJson(data);
      }).toList();
      
      reqs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reqs.first;
    });
  }

  Future<void> dismissRejection(String requestId) async {
    // Delete the document so the user can start fresh
    await _firestore
        .collection('assignment_requests')
        .doc(requestId)
        .delete();
  }
}

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(FirebaseFirestore.instance);
});
