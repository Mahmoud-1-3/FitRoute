import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Nutritionist Card Widget ──────────────────────────────────────────────
/// Marketplace card: avatar, name, rating, specialty, "View Profile" button.

class NutritionistCardWidget extends StatelessWidget {
  const NutritionistCardWidget({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.clients,
    required this.pricePerMonth,
    this.profileImageUrl,
    this.onViewProfile,
  });

  final String name;
  final String specialty;
  final double rating;
  final int clients;
  final int pricePerMonth;
  final String? profileImageUrl;
  final VoidCallback? onViewProfile;

  /// Builds the appropriate image widget for handling both Base64 and network URLs
  Widget _buildAvatarImage() {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      // No image - show initials
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0] : 'N',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    // Check if it's a Base64 string or a URL
    bool isBase64 = !profileImageUrl!.startsWith('http');

    if (isBase64) {
      // It's Base64 - decode and display using MemoryImage
      try {
        final imageBytes = base64Decode(profileImageUrl!);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 56,
              height: 56,
              color: AppColors.primaryLight,
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
        );
      } catch (e) {
        // Failed to decode - show error widget
        return Container(
          width: 56,
          height: 56,
          color: AppColors.primaryLight,
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 28,
          ),
        );
      }
    } else {
      // It's a URL - use CachedNetworkImage
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 56,
            height: 56,
            color: AppColors.primaryLight,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 56,
            height: 56,
            color: AppColors.primaryLight,
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          // ── Avatar ──
          _buildAvatarImage(),
          const SizedBox(width: 14),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Specialty chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Rating + clients
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$clients clients',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── View profile ──
          Column(
            children: [
              Text(
                '\$$pricePerMonth/mo',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onViewProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 32),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
