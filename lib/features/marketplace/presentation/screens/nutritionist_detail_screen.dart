import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/assignment_request_model.dart';
import '../../../shared/data/user_repository.dart';
import '../../data/assignment_repository.dart';

/// ─── Nutritionist Detail Screen ────────────────────────────────────────────
/// Full profile: avatar, stats, bio, services, and "Send Request" bottom bar.

class NutritionistDetailScreen extends ConsumerStatefulWidget {
  const NutritionistDetailScreen({
    super.key,
    required this.nutritionistId,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.clients,
    required this.price,
    required this.bio,
  });

  final String nutritionistId;
  final String name;
  final String specialty;
  final double rating;
  final int clients;
  final int price;
  final String bio;

  @override
  ConsumerState<NutritionistDetailScreen> createState() => _NutritionistDetailScreenState();
}

class _NutritionistDetailScreenState extends ConsumerState<NutritionistDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header with gradient ──
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            // Back button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Avatar
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  widget.name.isNotEmpty ? widget.name[0] : 'N',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Certified Nutritionist',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Stats row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBadge(
                            icon: Icons.people_rounded,
                            value: '${widget.clients}',
                            label: 'Clients',
                            color: const Color(0xFF6366F1),
                          ),
                          _vertDivider(),
                          _StatBadge(
                            icon: Icons.star_rounded,
                            value: widget.rating.toStringAsFixed(1),
                            label: 'Rating',
                            color: const Color(0xFFF59E0B),
                          ),
                          _vertDivider(),
                          _StatBadge(
                            icon: Icons.workspace_premium_rounded,
                            value: '5+ yrs',
                            label: 'Experience',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── About ──
                  _Section(
                    title: 'About',
                    child: Text(
                      widget.bio,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Specialty ──
                  _Section(
                    title: 'Specialties',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(widget.specialty),
                        _chip('Meal Planning'),
                        _chip('Body Composition'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Services & Pricing ──
                  _Section(
                    title: 'Services & Pricing',
                    child: Column(
                      children: [
                        _ServiceRow(
                          title: 'Monthly Coaching',
                          desc: 'Custom meal plans + weekly check-ins',
                          price: '\$${widget.price}/mo',
                        ),
                        const SizedBox(height: 10),
                        _ServiceRow(
                          title: 'Single Consultation',
                          desc: '60 min video call + written plan',
                          price: '\$${(widget.price * 0.5).toInt()}',
                        ),
                        const SizedBox(height: 10),
                        _ServiceRow(
                          title: 'Diet Analysis',
                          desc: 'Review current diet + recommendations',
                          price: '\$${(widget.price * 0.3).toInt()}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // space for bottom button
                ],
              ),
            ),
          ),

          // ── Fixed bottom action bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final user = ref.read(userRepositoryProvider).getUser();
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Not logged in as a user.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final requestRepo = ref.read(assignmentRepositoryProvider);
                            final reqId = FirebaseFirestore.instance.collection('assignment_requests').doc().id;

                            final newRequest = AssignmentRequestModel(
                              id: reqId,
                              userId: user.id,
                              nutritionistId: widget.nutritionistId,
                              status: 'pending',
                              createdAt: DateTime.now(),
                            );

                            await requestRepo.createRequest(newRequest);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Request sent to ${widget.name}!'),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              // Pop back to marketplace
                              context.pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send request: $e'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)
                        )
                      : Text(
                          'Send Request (\$${widget.price}/mo)',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vertDivider() =>
      Container(width: 1, height: 40, color: AppColors.divider);

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
    ),
  );
}

// ─── Stat Badge ─────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ─── Section wrapper ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Service Row ────────────────────────────────────────────────────────────

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.title,
    required this.desc,
    required this.price,
  });

  final String title, desc, price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
