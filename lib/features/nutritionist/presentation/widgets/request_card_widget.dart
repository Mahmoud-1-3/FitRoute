import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Request Card Widget ───────────────────────────────────────────────────
/// Incoming user request: name, goal, Accept / Decline buttons.

class RequestCardWidget extends StatelessWidget {
  const RequestCardWidget({
    super.key,
    required this.userName,
    required this.goal,
    required this.age,
    required this.weight,
    this.profileImageUrl,
    required this.onViewDetails,
  });

  final String userName;
  final String goal;
  final int age;
  final double weight;
  final String? profileImageUrl;
  final VoidCallback onViewDetails;

  /// Builds the appropriate avatar widget for handling both Base64 and network URLs
  Widget _buildAvatarImage() {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      // No image - show initials
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFEDE9FE),
        child: Text(
          userName.isNotEmpty ? userName[0] : 'U',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8B5CF6),
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
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEDE9FE),
              child: Icon(
                Icons.person,
                color: const Color(0xFF8B5CF6),
                size: 22,
              ),
            ),
          ),
        );
      } catch (e) {
        // Failed to decode - show error widget
        return CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFEDE9FE),
          child: Icon(
            Icons.person,
            color: const Color(0xFF8B5CF6),
            size: 22,
          ),
        );
      }
    } else {
      // It's a URL - use CachedNetworkImage
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImageUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEDE9FE),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          ),
          errorWidget: (context, url, error) => CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Icon(
              Icons.person,
              color: const Color(0xFF8B5CF6),
              size: 22,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              _buildAvatarImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Age: $age  •  ${weight}kg',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              // Goal badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  goal,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'View Details',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
