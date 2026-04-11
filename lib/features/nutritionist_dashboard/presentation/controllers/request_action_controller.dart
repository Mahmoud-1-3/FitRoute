import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/assignment_request_model.dart';
import '../../../marketplace/data/assignment_repository.dart';

class RequestActionState {
  final bool isLoading;
  final String? loadingRequestId;
  final String? errorMessage;
  final String? successMessage;

  const RequestActionState({
    this.isLoading = false,
    this.loadingRequestId,
    this.errorMessage,
    this.successMessage,
  });

  RequestActionState copyWith({
    bool? isLoading,
    String? loadingRequestId,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return RequestActionState(
      isLoading: isLoading ?? this.isLoading,
      loadingRequestId: isLoading == false ? null : (loadingRequestId ?? this.loadingRequestId),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class RequestActionController extends StateNotifier<RequestActionState> {
  RequestActionController(this._repo) : super(const RequestActionState());

  final AssignmentRepository _repo;

  Future<void> acceptRequest(AssignmentRequestModel request) async {
    state = state.copyWith(isLoading: true, loadingRequestId: request.id, clearMessages: true);
    try {
      // The requirement states using a WriteBatch if possible, but AssignmentRepository 
      // is already abstracting these calls. To do a batch properly across collections, 
      // we would use FirebaseFirestore.instance.batch() directly here, or modify 
      // the repository to accept a batch. For simplicity and following the repo pattern:
      
      final batch = FirebaseFirestore.instance.batch();
      
      final requestRef = FirebaseFirestore.instance.collection('assignment_requests').doc(request.id);
      final userRef = FirebaseFirestore.instance.collection('users').doc(request.userId);
      
      batch.update(requestRef, {'status': 'accepted'});
      batch.update(userRef, {'assignedNutritionistId': request.nutritionistId});
      
      await batch.commit();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Request accepted successfully!',
      );
    } catch (e) {
      debugPrint('[RequestActionController] Error accepting request: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to accept request. Please try again.',
      );
    }
  }

  Future<void> declineRequest(AssignmentRequestModel request) async {
    state = state.copyWith(isLoading: true, loadingRequestId: request.id, clearMessages: true);
    try {
      await _repo.updateRequestStatus(request.id, 'rejected');
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Request declined.',
      );
    } catch (e) {
      debugPrint('[RequestActionController] Error declining request: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to decline request. Please try again.',
      );
    }
  }
}

final requestActionControllerProvider =
    StateNotifierProvider<RequestActionController, RequestActionState>((ref) {
  final repo = ref.watch(assignmentRepositoryProvider);
  return RequestActionController(repo);
});
