import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/nutritionist_signup_screen.dart';
import '../../features/auth/presentation/screens/user_signup_screen.dart';
import '../../features/dashboard/presentation/screens/user_main_shell.dart';
import '../../features/marketplace/presentation/screens/nutritionist_detail_screen.dart';
import '../../features/marketplace/presentation/screens/nutritionist_marketplace_screen.dart';
import '../../features/nutritionist/presentation/screens/nutritionist_main_shell.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/workout/presentation/screens/exercise_detail_screen.dart';
import '../../features/diet/presentation/screens/meal_detail_screen.dart';

/// ─── App Router ─────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Onboarding flow ──
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // ── Auth ──
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup-user',
      name: 'signup-user',
      builder: (context, state) => const UserSignupScreen(),
    ),
    GoRoute(
      path: '/signup-nutritionist',
      name: 'signup-nutritionist',
      builder: (context, state) => const NutritionistSignupScreen(),
    ),

    // ── User Main App ──
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const UserMainShell(),
    ),

    // ── Exercise Detail ──
    GoRoute(
      path: '/exercise-detail',
      name: 'exercise-detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ExerciseDetailScreen(
          name: data['name'] as String? ?? 'Exercise',
          sets: data['sets'] as int? ?? 3,
          reps: data['reps'] as int? ?? 10,
          target: data['target'] as String? ?? 'General',
        );
      },
    ),

    // ── Meal Detail ──
    GoRoute(
      path: '/meal-detail',
      name: 'meal-detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return MealDetailScreen(
          mealId: data['mealId'] as String? ?? '',
          name: data['name'] as String? ?? 'Meal',
          category: data['category'] as String? ?? 'Meal',
          calories: data['calories'] as int? ?? 0,
          carbs: data['carbs'] as int? ?? 0,
          protein: data['protein'] as int? ?? 0,
          fat: data['fat'] as int? ?? 0,
          isSelected: data['isSelected'] as bool? ?? false,
        );
      },
    ),

    // ── Marketplace ──
    GoRoute(
      path: '/marketplace',
      name: 'marketplace',
      builder: (context, state) => const NutritionistMarketplaceScreen(),
    ),
    GoRoute(
      path: '/nutritionist-profile',
      name: 'nutritionist-profile',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return NutritionistDetailScreen(
          nutritionistId: data['id'] as String? ?? '',
          name: data['name'] as String? ?? 'Nutritionist',
          specialty: data['specialty'] as String? ?? 'General',
          rating: data['rating'] as double? ?? 4.5,
          clients: data['clients'] as int? ?? 0,
          price: data['price'] as int? ?? 50,
          bio: data['bio'] as String? ?? '',
        );
      },
    ),

    // ── Nutritionist Main App ──
    GoRoute(
      path: '/nutritionist-dashboard',
      name: 'nutritionist-dashboard',
      builder: (context, state) => const NutritionistMainShell(),
    ),
  ],
);
