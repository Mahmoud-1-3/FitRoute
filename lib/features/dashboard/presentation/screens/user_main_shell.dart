import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../diet/presentation/screens/diet_plan_screen.dart';
import '../../../home/presentation/screens/user_home_screen.dart';
import '../../../marketplace/presentation/screens/nutritionist_marketplace_screen.dart';
import '../../../profile/presentation/screens/user_profile_screen.dart';
import '../../../workout/presentation/screens/workout_plan_screen.dart';

/// ─── User Main Shell ───────────────────────────────────────────────────────
/// Persistent bottom navigation bar with 5 tabs.

class UserMainShell extends StatefulWidget {
  const UserMainShell({super.key});

  @override
  State<UserMainShell> createState() => _UserMainShellState();
}

class _UserMainShellState extends State<UserMainShell> {
  int _selectedIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.restaurant_menu_rounded, label: 'Diet'),
    _TabItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
    _TabItem(icon: Icons.people_rounded, label: 'Market'),
    _TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      UserHomeScreen(),
      DietPlanScreen(),
      WorkoutPlanScreen(),
      NutritionistMarketplaceScreen(),
      UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final isSelected = i == _selectedIndex;
                return _NavItem(
                  icon: _tabs[i].icon,
                  label: _tabs[i].label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedIndex = i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tab item data ──────────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ─── Custom Nav Item ────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
