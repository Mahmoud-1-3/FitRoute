import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/active_clients_provider.dart';
import '../widgets/active_client_card_widget.dart';

/// ─── Nutritionist Clients Screen ───────────────────────────────────────────
/// Full-page client list with search. Accessed from the Clients tab.

class NutritionistClientsScreen extends ConsumerStatefulWidget {
  const NutritionistClientsScreen({super.key});

  @override
  ConsumerState<NutritionistClientsScreen> createState() =>
      _NutritionistClientsScreenState();
}

class _NutritionistClientsScreenState extends ConsumerState<NutritionistClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeClientsAsync = ref.watch(activeClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: activeClientsAsync.when(
          data: (clients) {
            final list = _query.isEmpty
                ? clients
                : clients.where((c) => c.fullName.toLowerCase().contains(_query)).toList();

            return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Clients',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${clients.length} active clients',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search clients by name…',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Client list ──
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No clients found',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = list[i];
                        
                        // Derive a safe target weight just for display
                        final targetWeight = c.goal.toLowerCase().contains('lose') 
                            ? c.weight - 5.0 
                            : (c.goal.toLowerCase().contains('build') ? c.weight + 5.0 : c.weight);

                        return ActiveClientCardWidget(
                          name: c.fullName,
                          goal: c.goal,
                          currentWeight: c.weight,
                          targetWeight: targetWeight,
                          weeksActive: 1, // Dummy until createdAt is tracked
                          onViewProgress: () =>
                              debugPrint('View progress: ${c.fullName}'),
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
                    ),
            ),
          ],
        );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      ),
    );
  }
}
