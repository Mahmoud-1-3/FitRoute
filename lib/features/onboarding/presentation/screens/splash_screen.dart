import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/data/user_repository.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../shared/data/diet_repository.dart';
import '../../../shared/data/workout_repository.dart';
import '../../../shared/data/nutritionist_repository.dart';
import '../../../shared/services/plan_generator_service.dart';

/// ─── Splash Screen ──────────────────────────────────────────────────────────
/// Displays the FitRoute brand logo and initialising indicator for 2.5 s,
/// then checks Firebase auth state to decide the next screen.

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();

    // Animate logo entrance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Navigate after 2.5 seconds — check auth state first
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _resolveNavigation();
    });
  }

  /// Checks Firebase auth and determines the correct destination.
  Future<void> _resolveNavigation() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // Not logged in → show onboarding / login flow
      if (mounted) context.go('/onboarding');
      return;
    }

    // User is logged in. Try to hydrate local Hive data from Firestore
    // so the dashboard has everything it needs on first frame.
    try {
      final userRepo = ref.read(userRepositoryProvider);
      var localUser = userRepo.getUser();

      // If Hive is empty (e.g. after app reinstall), re-fetch from cloud
      if (localUser == null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        final cloudUser = await firestoreService.getUserFromCloud(firebaseUser.uid);

        if (cloudUser != null) {
          await userRepo.saveUser(cloudUser);
          localUser = cloudUser;

          // Also hydrate plans if needed
          if (cloudUser.role == 'user') {
            final dietRepo = ref.read(dietRepositoryProvider);
            final workoutRepo = ref.read(workoutRepositoryProvider);
            if (dietRepo.getDailyMeals().isEmpty || workoutRepo.getWorkouts().isEmpty) {
              final planGen = ref.read(planGeneratorProvider);
              final meals = planGen.generateDietPlan(cloudUser);
              final workouts = planGen.generateWorkoutPlan(cloudUser);
              await dietRepo.saveDailyMeals(meals);
              await workoutRepo.saveWorkouts(workouts);
            }
          } else if (cloudUser.role == 'nutritionist') {
            final firestoreService = ref.read(firestoreServiceProvider);
            final cloudNut = await firestoreService.getNutritionistFromCloud(firebaseUser.uid);
            if (cloudNut != null) {
              await ref.read(nutritionistRepositoryProvider).saveNutritionist(cloudNut);
            }
          }
        }
      }

      if (!mounted) return;

      if (localUser != null && localUser.role == 'nutritionist') {
        context.go('/nutritionist-dashboard');
      } else {
        context.go('/home');
      }
    } catch (e) {
      // If anything goes wrong, fall back to the default flow
      debugPrint('[SplashScreen] Error during auth resolution: $e');
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF1DB893)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Logo area (centered) ──
              Expanded(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: ScaleTransition(
                    scale: _scaleIn,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main icon
                              const Icon(
                                Icons.fitness_center_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              // Small accent dot (top-right)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App name
                        Text(
                          'FitRoute',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EMPOWERING YOUR HEALTH JOURNEY',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.75),
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

