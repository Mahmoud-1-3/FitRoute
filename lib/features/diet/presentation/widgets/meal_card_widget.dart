import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Meal Card Widget ──────────────────────────────────────────────────────
/// A card showing meal name, calories/macros, selected indicator, and
/// an optional **locked** overlay when the category isn't ready yet.

class MealCardWidget extends StatelessWidget {
  const MealCardWidget({
    super.key,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.imageUrl,
    this.isSelected = false,
    this.isLocked = false,
    this.onTap,
    this.onInfoTap,
  });

  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final String? imageUrl;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    final opacity = isLocked ? 0.45 : 1.0;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight
                : (isLocked ? const Color(0xFFF3F4F6) : Colors.white),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isSelected && !isLocked)
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // ── Image placeholder ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isLocked
                      ? const Color(0xFFE5E7EB)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : Icons.restaurant_rounded,
                  color: isLocked ? AppColors.textHint : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // ── Text info ──
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$calories kcal',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MacroChip('C: ${carbs}g', const Color(0xFF6366F1)),
                        const SizedBox(width: 6),
                        _MacroChip('P: ${protein}g', const Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        _MacroChip('F: ${fat}g', const Color(0xFFEF4444)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Info icon ──
              GestureDetector(
                onTap: onInfoTap,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── Selected / locked indicator ──
              if (isLocked)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 14,
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
