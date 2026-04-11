import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Data class for a single onboarding page ────────────────────────────────

class OnboardingPageData {
  const OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.titleAccent,
    required this.subtitle,
    this.chips = const [],
  });

  final String imagePath;
  final String title; // e.g. "Personalized "
  final String titleAccent; // e.g. "Diet Plans"  (shown in primary colour)
  final String subtitle;
  final List<String> chips; // optional tag chips below subtitle
}

/// ─── Onboarding Page Widget ────────────────────────────────────────────────

class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({super.key, required this.data});
  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Image ──
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                ),
                child: _buildImage(),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Title ──
          Expanded(
            flex: 4,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: data.title,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      TextSpan(
                        text: data.titleAccent,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Subtitle ──
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                // ── Chips (if any) ──
                if (data.chips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: data.chips.map((label) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tries to load the asset image; falls back to a coloured placeholder
  /// with an icon so the app doesn't crash before real images are added.
  Widget _buildImage() {
    return Image.asset(
      data.imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _placeholderIcon,
                size: 64,
                color: AppColors.primary.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                data.titleAccent,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData get _placeholderIcon {
    if (data.titleAccent.contains('Diet')) return Icons.restaurant_menu_rounded;
    if (data.titleAccent.contains('Nutrition')) return Icons.people_rounded;
    return Icons.fitness_center_rounded;
  }
}
