import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/assignment_repository.dart';

class AssignmentController extends StateNotifier<AsyncValue<void>> {
  AssignmentController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> clearRejectedRequest(String requestId) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(assignmentRepositoryProvider);
      await repo.dismissRejection(requestId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final assignmentControllerProvider = StateNotifierProvider<AssignmentController, AsyncValue<void>>((ref) {
  return AssignmentController(ref);
});
