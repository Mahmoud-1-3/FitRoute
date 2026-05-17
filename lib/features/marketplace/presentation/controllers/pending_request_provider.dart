import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/assignment_request_model.dart';
import '../../data/assignment_repository.dart';

/// ─── Pending Request Provider ──────────────────────────────────────────────
/// Streams whether the current user has a pending request to a specific
/// nutritionist. Keyed by "{userId}_{nutritionistId}".
///
/// Usage:
///   ref.watch(pendingRequestProvider('userId_nutritionistId'))

final pendingRequestProvider = StreamProvider.autoDispose
    .family<AssignmentRequestModel?, String>((ref, key) {
  final parts = key.split('_');
  if (parts.length < 2) return Stream.value(null);

  final userId = parts[0];
  final nutritionistId = parts.sublist(1).join('_'); // handle IDs with underscores

  final repo = ref.watch(assignmentRepositoryProvider);
  return repo.streamPendingRequestForNutritionist(userId, nutritionistId);
});
