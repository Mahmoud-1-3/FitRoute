import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/data/user_repository.dart';
import '../../../nutritionist_dashboard/presentation/controllers/pending_requests_provider.dart';
import '../../../nutritionist_dashboard/presentation/controllers/request_action_controller.dart';
import '../widgets/request_card_widget.dart';
import '../widgets/user_overview_bottom_sheet.dart';

/// ─── Requests Tab View ─────────────────────────────────────────────────────
/// List of incoming user requests with Accept / Decline.

class RequestsTabView extends ConsumerWidget {
  const RequestsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);

    // Listen to action state to show snackbars
    ref.listen<RequestActionState>(requestActionControllerProvider,
        (previous, current) {
      if (current.errorMessage != null &&
          (previous?.errorMessage != current.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (current.successMessage != null &&
          (previous?.successMessage != current.successMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.successMessage!),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });

    return pendingRequestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 56,
                  color: AppColors.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No pending requests at the moment.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final request = requests[i];
            final userRepo = ref.read(userRepositoryProvider);

            return FutureBuilder(
              future: userRepo.getUserById(request.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return const SizedBox.shrink(); // hide if user vanished
                }

                return RequestCardWidget(
                  userName: user.fullName,
                  goal: user.goal,
                  age: user.age,
                  weight: user.weight,
                  profileImageUrl: user.profileImageUrl,
                  onViewDetails: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) {
                        return Consumer(
                          builder: (context, ref, _) {
                            final state = ref.watch(requestActionControllerProvider);
                            final processingCard = state.isLoading && state.loadingRequestId == request.id;

                            // Auto-close if success happens while open
                            ref.listen<RequestActionState>(
                              requestActionControllerProvider,
                              (previous, current) {
                                if (current.successMessage != null && 
                                    previous?.successMessage != current.successMessage) {
                                  if (Navigator.canPop(ctx)) {
                                    Navigator.pop(ctx);
                                  }
                                }
                              },
                            );

                            return UserOverviewBottomSheet(
                              user: user,
                              request: request,
                              isProcessing: processingCard,
                              onAccept: () => ref
                                  .read(requestActionControllerProvider.notifier)
                                  .acceptRequest(request),
                              onDecline: () => ref
                                  .read(requestActionControllerProvider.notifier)
                                  .declineRequest(request),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, stack) => Center(
        child: Text('Error loading requests: $error'),
      ),
    );
  }
}
