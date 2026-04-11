import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/active_client_card_widget.dart';

/// ─── Nutritionist Clients Screen ───────────────────────────────────────────
/// Full-page client list with search. Accessed from the Clients tab.

class NutritionistClientsScreen extends StatefulWidget {
  const NutritionistClientsScreen({super.key});

  @override
  State<NutritionistClientsScreen> createState() =>
      _NutritionistClientsScreenState();
}

class _NutritionistClientsScreenState extends State<NutritionistClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // ── Mock client data ──
  static const _clients = [
    _ClientData('Mohamed Hassan', 'Lose Weight', 78.5, 72.0, 8),
    _ClientData('Nour Ahmed', 'Build Muscle', 62.0, 68.0, 12),
    _ClientData('Fatma Ali', 'Maintain', 70.2, 70.0, 4),
    _ClientData('Khaled Mostafa', 'Lose Weight', 90.0, 80.0, 16),
  ];

  List<_ClientData> get _filtered => _query.isEmpty
      ? _clients
      : _clients.where((c) => c.name.toLowerCase().contains(_query)).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
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
                '${_clients.length} active clients',
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
                        return ActiveClientCardWidget(
                          name: c.name,
                          goal: c.goal,
                          currentWeight: c.currentWeight,
                          targetWeight: c.targetWeight,
                          weeksActive: c.weeks,
                          onViewProgress: () =>
                              debugPrint('View progress: ${c.name}'),
                          onMessage: () => debugPrint('Message: ${c.name}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientData {
  const _ClientData(
    this.name,
    this.goal,
    this.currentWeight,
    this.targetWeight,
    this.weeks,
  );
  final String name, goal;
  final double currentWeight, targetWeight;
  final int weeks;
}
