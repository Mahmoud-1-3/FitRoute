import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../nutritionist_dashboard/presentation/widgets/active_client_card_widget.dart';
import '../../../nutritionist_dashboard/presentation/controllers/active_clients_provider.dart';

/// ─── Clients Tab View ──────────────────────────────────────────────────────
/// List of active clients the nutritionist is coaching.

class ClientsTabView extends ConsumerWidget {
  const ClientsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeClientsAsync = ref.watch(activeClientsProvider);

    return activeClientsAsync.when(
      data: (clients) {
        if (clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 56,
                  color: AppColors.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No active clients yet.',
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
          itemCount: clients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final c = clients[i];
            
            // Derive a safe target weight just for display
            final targetWeight = c.goal.toLowerCase().contains('lose') 
                ? c.weight - 5.0 
                : (c.goal.toLowerCase().contains('build') ? c.weight + 5.0 : c.weight);

            return ActiveClientCardWidget(
              name: c.fullName,
              currentWeight: c.weight,
              targetWeight: targetWeight,
              goal: c.goal,
              weeksActive: 1, // Dummy weeks active since there's no createdAt
              onViewProgress: () {
                // Navigate to progress view
                debugPrint('View Progress for ${c.fullName}');
              },
              onMessage: () async {
                final url = Uri.parse('whatsapp://send?phone=0000000000');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open WhatsApp')),
                    );
                  }
                }
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, st) => Center(
        child: Text('Error: $e'),
      ),
    );
  }
}
