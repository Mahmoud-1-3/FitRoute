import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';
import '../controllers/assignment_controller.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/nutritionist_card_widget.dart';

/// ─── Nutritionist Marketplace Screen ───────────────────────────────────────
/// Search bar + filterable list of nutritionists for the User role.

class NutritionistMarketplaceScreen extends ConsumerStatefulWidget {
  const NutritionistMarketplaceScreen({super.key});

  @override
  ConsumerState<NutritionistMarketplaceScreen> createState() =>
      _NutritionistMarketplaceScreenState();
}

class _NutritionistMarketplaceScreenState
    extends ConsumerState<NutritionistMarketplaceScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Find a Nutritionist',
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
                'Browse verified professionals',
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
                    hintText: 'Search by name or specialty…',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      onPressed: () => debugPrint('Open filters'),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── List ──
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(userProvider);
                  final latestReqAsync = ref.watch(userRequestStatusProvider);
                  
                  if (user != null && user.assignedNutritionistId != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'You Have a Nutritionist!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You are already working with a nutritionist. Go to your Profile to manage your assignment or send a message.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Go to Profile'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final request = latestReqAsync.valueOrNull;
                  final isPending = request?.status == 'pending';
                  final isRejected = request?.status == 'rejected';

                  return Column(
                    children: [
                      // ── Rejected Banner ──
                      if (isRejected)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your previous request to hire a nutritionist was declined.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(assignmentControllerProvider.notifier).clearRejectedRequest(request!.id);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                child: const Text('Dismiss'),
                              ),
                            ],
                          ),
                        ),

                      // ── Pending Banner ──
                      if (isPending)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hourglass_empty_rounded, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You have a pending request with a nutritionist.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Expanded(
                        child: ref.watch(nutritionistsListProvider).when(
                          data: (nutritionists) {
                            final list = _query.isEmpty
                                ? nutritionists
                                : nutritionists
                                    .where((n) =>
                                        n.fullName.toLowerCase().contains(_query) ||
                                        n.specialties.any((s) => s.toLowerCase().contains(_query)))
                                    .toList();

                            if (list.isEmpty) {
                              return Center(
                                child: Text(
                                  'No nutritionists found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              itemCount: list.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final n = list[i];
                                return NutritionistCardWidget(
                                  name: n.fullName,
                                  specialty: n.specialties.isNotEmpty ? n.specialties.first : 'Nutritionist',
                                  rating: n.rating,
                                  clients: n.clientCount,
                                  pricePerMonth: n.price.toInt(),
                                  onViewProfile: () {
                                    if (isPending) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('You cannot send a new request while one is pending')),
                                      );
                                      return;
                                    }
                                    context.push(
                                      '/nutritionist-profile',
                                      extra: {
                                        'id': n.id,
                                        'name': n.fullName,
                                        'specialty': n.specialties.isNotEmpty ? n.specialties.first : 'Nutritionist',
                                        'specialties': n.specialties,
                                        'rating': n.rating,
                                        'clients': n.clientCount,
                                        'price': n.price.toInt(),
                                        'bio': n.bio,
                                        'whatsappNumber': n.whatsappNumber,
                                        'email': n.email,
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator(color: AppColors.primary)),
                          error: (error, _) => Center(
                            child: Text('Error loading marketplace: $error'),
                          ),
                        ),
                      ),
                    ],
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
