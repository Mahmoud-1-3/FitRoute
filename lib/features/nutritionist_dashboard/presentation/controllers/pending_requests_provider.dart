import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/assignment_request_model.dart';
import '../../../shared/data/nutritionist_repository.dart';
import '../../../marketplace/data/assignment_repository.dart';

final pendingRequestsProvider = StreamProvider.autoDispose<List<AssignmentRequestModel>>((ref) {
  final nutritionistRepository = ref.watch(nutritionistRepositoryProvider);
  final nutritionist = nutritionistRepository.getNutritionist();

  if (nutritionist == null) {
    return Stream.value([]);
  }

  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.streamPendingRequests(nutritionist.id);
});
