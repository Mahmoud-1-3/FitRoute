import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/user_model.dart';
import '../../core/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/nutritionist_signup_screen.dart';
import '../../features/auth/presentation/screens/user_signup_screen.dart';
import '../../features/dashboard/presentation/screens/user_main_shell.dart';
import '../../features/marketplace/presentation/screens/nutritionist_detail_screen.dart';
import '../../features/marketplace/presentation/screens/nutritionist_marketplace_screen.dart';
import '../../features/nutritionist/presentation/screens/nutritionist_main_shell.dart';
import '../../features/nutritionist_dashboard/presentation/screens/client_progress_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/workout/presentation/screens/exercise_detail_screen.dart';
import '../../features/diet/presentation/screens/meal_detail_screen.dart';
import '../../features/shared/data/user_repository.dart';

/// ─── Public / Auth-free routes ─────────────────────────────────────────────
/// Users may visit these without being logged in.
const _publicPaths = <String>{
  '/',           // splash
  '/onboarding',
  '/role-selection',
  '/login',
  '/signup-user',
  '/signup-nutritionist',
};

/// Routes that only regular users may access.
const _userOnlyPaths = <String>{
  '/home',
  '/exercise-detail',
  '/meal-detail',
  '/marketplace',
  '/nutritionist-profile',
};

/// Routes that only nutritionists may access.
const _nutritionistOnlyPaths = <String>{
  '/nutritionist-dashboard',
  '/client-progress',
};

/// ─── App Router Provider ───────────────────────────────────────────────────
/// A Riverpod provider that creates a GoRouter with auth-aware redirects.
/// The router listens to the Firebase auth stream via [GoRouterRefreshStream]
/// and re-evaluates redirects whenever the user signs in or out.

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),

    /// ── Redirect callback ──────────────────────────────────────────────────
    /// Runs on every navigation event AND whenever the auth stream emits.
    redirect: (context, state) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final isLoggedIn = firebaseUser != null;
      final currentPath = state.matchedLocation;
      final isPublicRoute = _publicPaths.contains(currentPath);

      // Always let the splash screen run its animation.
      if (currentPath == '/') return null;

      // ── Unauthenticated user trying to access a protected route ──
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // ── Authenticated user: check local Hive for role ──
      if (isLoggedIn) {
        final userRepo = ref.read(userRepositoryProvider);
        final localUser = userRepo.getUser();
        final isNutritionist = localUser?.role == 'nutritionist';

        // If Hive has no user data yet (e.g. cold start before splash
        // finishes hydrating), do NOT redirect — let the splash screen
        // handle the initial navigation after it fetches from Firestore.
        if (localUser == null && isPublicRoute) {
          return null;
        }

        // ── Authenticated on a public route → send to dashboard ──
        if (isPublicRoute) {
          return isNutritionist ? '/nutritionist-dashboard' : '/home';
        }

        // ── Cross-role protection ──
        // A nutritionist trying to access a user-only route
        if (isNutritionist && _userOnlyPaths.contains(currentPath)) {
          return '/nutritionist-dashboard';
        }
        // A user trying to access a nutritionist-only route
        if (!isNutritionist && _nutritionistOnlyPaths.contains(currentPath)) {
          return '/home';
        }
      }

      // No redirect needed.
      return null;
    },

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
            specialties: (data['specialties'] as List<dynamic>?)?.cast<String>() ?? [],
            rating: data['rating'] as double? ?? 4.5,
            clients: data['clients'] as int? ?? 0,
            price: data['price'] as int? ?? 50,
            bio: data['bio'] as String? ?? '',
            whatsappNumber: data['whatsappNumber'] as String? ?? '',
            instagramUrl: data['instagramUrl'] as String? ?? '',
            profileImageUrl: data['profileImageUrl'] as String?,
          );
        },
      ),

      // ── Nutritionist Main App ──
      GoRoute(
        path: '/nutritionist-dashboard',
        name: 'nutritionist-dashboard',
        builder: (context, state) => const NutritionistMainShell(),
      ),

      // ── Client Progress (viewed by Nutritionist) ──
      GoRoute(
        path: '/client-progress',
        name: 'client-progress',
        builder: (context, state) {
          final client = state.extra as UserModel;
          return ClientProgressScreen(client: client);
        },
      ),
    ],
  );
});
