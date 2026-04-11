import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Client Card Widget ────────────────────────────────────────────────────
/// Active client: avatar, name, weight, and message icon.

class ClientCardWidget extends StatelessWidget {
  const ClientCardWidget({
    super.key,
    required this.name,
    required this.currentWeight,
    required this.goal,
    required this.weeksActive,
    this.onMessage,
  });

  final String name;
  final double currentWeight;
  final String goal;
  final int weeksActive;
  final VoidCallback? onMessage;

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
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFEF3C7),
            child: Text(
              name.isNotEmpty ? name[0] : 'C',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(
                      Icons.monitor_weight_outlined,
                      '${currentWeight}kg',
                    ),
                    const SizedBox(width: 8),
                    _infoChip(Icons.flag_outlined, goal),
                    const SizedBox(width: 8),
                    _infoChip(Icons.calendar_today_outlined, '${weeksActive}w'),
                  ],
                ),
              ],
            ),
          ),

          // Message button
          GestureDetector(
            onTap: onMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
