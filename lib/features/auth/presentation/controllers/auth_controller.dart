import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/nutritionist_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/weight_entry_model.dart';
import '../../../../core/models/meal_model.dart';
import '../../../../core/models/workout_model.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../shared/data/diet_repository.dart';
import '../../../shared/data/nutritionist_repository.dart';
import '../../../shared/data/user_repository.dart';
import '../../../shared/data/workout_repository.dart';
import '../../../shared/services/plan_generator_service.dart';

/// ─── Auth State ────────────────────────────────────────────────────────────
/// Simple sealed-class-style state for the UI to react to.

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// ─── Auth Controller ───────────────────────────────────────────────────────
/// Orchestrates the full registration / login flow:
///   1. Firebase Auth  →  get UID
///   2. Save locally   →  Hive (instant UI access)
///   3. Sync to cloud  →  Firestore (background, fail-safe)
///   4. Generate plans →  diet + workout from user metrics
///   5. Save plans     →  Hive (ready for offline use)

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState());

  final Ref _ref;

  // ── Register a new USER ─────────────────────────────────────────────────
  /// Called when the user submits the sign-up form on UserSignupScreen.
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    // Show loading spinner in the UI.
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // ──────────────────────────────────────────────────────────────────────
      // STEP 1 — Firebase Auth: create the account and get the UID.
      // ──────────────────────────────────────────────────────────────────────
      final authService = _ref.read(firebaseAuthServiceProvider);
      final credential = await authService.signUpWithEmail(email, password);
      final uid = credential.user!.uid;
      debugPrint('[AuthController] ✅ Firebase account created — UID: $uid');

      // ──────────────────────────────────────────────────────────────────────
      // STEP 2 — Create the UserModel and save it LOCALLY (Hive).
      //          This makes profile data instantly available to the UI,
      //          even if the network call in Step 3 fails.
      // ──────────────────────────────────────────────────────────────────────
      final user = UserModel(
        id: uid,
        role: 'user',
        email: email,
        fullName: fullName,
        age: age,
        weightHistory: [
          WeightEntry(weight: weight, timestamp: DateTime.now()),
        ],
        height: height,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
      );

      final userRepo = _ref.read(userRepositoryProvider);
      await userRepo.saveUser(user);
      debugPrint('[AuthController] ✅ User saved locally (Hive)');

      // ──────────────────────────────────────────────────────────────────────
      // STEP 3 — Sync to Firestore (cloud).
      //          Wrapped in its own try/catch so a network failure does NOT
      //          block the user from using the app (Offline-First).
      // ──────────────────────────────────────────────────────────────────────
      try {
        final firestoreService = _ref.read(firestoreServiceProvider);
        await firestoreService.saveUserToCloud(user);
        debugPrint('[AuthController] ✅ User synced to Firestore');
      } catch (syncError) {
        debugPrint(
          '[AuthController] ⚠️ Cloud sync failed (will retry): $syncError',
        );
        // Non-blocking — the app continues with local data.
      }

      // ──────────────────────────────────────────────────────────────────────
      // STEP 4 — Generate initial diet + workout plans from user metrics.
      //          Uses the Mifflin-St Jeor equation to calculate BMR/TDEE.
      // ──────────────────────────────────────────────────────────────────────
      final planGen = _ref.read(planGeneratorProvider);
      final meals = planGen.generateDietPlan(user);
      final workouts = planGen.generateWorkoutPlan(user);
      debugPrint(
        '[AuthController] ✅ Plans generated — ${meals.length} meals, '
        '${workouts.length} workouts',
      );

      // ──────────────────────────────────────────────────────────────────────
      // STEP 5 — Save generated plans locally (Hive) for offline access.
      // ──────────────────────────────────────────────────────────────────────
      final dietRepo = _ref.read(dietRepositoryProvider);
      final workoutRepo = _ref.read(workoutRepositoryProvider);
      await dietRepo.saveDailyMeals(meals);
      await workoutRepo.saveWorkouts(workouts);
      debugPrint('[AuthController] ✅ Plans saved locally (Hive)');

      // ──────────────────────────────────────────────────────────────────────
      // STEP 6 — Save plans to Firestore for real-time sync across devices.
      //          Wrapped in try/catch so it doesn't block signup.
      // ──────────────────────────────────────────────────────────────────────
      try {
        await _savePlansToFirestore(uid, meals, workouts);
        debugPrint('[AuthController] ✅ Plans synced to Firestore');
      } catch (planSyncError) {
        debugPrint(
          '[AuthController] ⚠️ Plan sync failed (will retry): $planSyncError',
        );
      }

      // ──────────────────────────────────────────────────────────────────────
      // DONE — Mark as authenticated. The UI will navigate to /home.
      // ──────────────────────────────────────────────────────────────────────
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      debugPrint('[AuthController] ❌ Registration failed: $e');
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
    }
  }

  // ── Register a new NUTRITIONIST ─────────────────────────────────────────
  /// Called when the nutritionist submits their signup form.
  Future<void> registerNutritionist({
    required String email,
    required String password,
    required String fullName,
    required String bio,
    required List<String> specialties,
    required double price,
    required String whatsappNumber,
    required String instagramUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Step 1 — Firebase Auth
      final authService = _ref.read(firebaseAuthServiceProvider);
      final credential = await authService.signUpWithEmail(email, password);
      final uid = credential.user!.uid;

      // Step 2 — Create model & save locally
      final nutritionist = NutritionistModel(
        id: uid,
        email: email,
        fullName: fullName,
        bio: bio,
        specialties: specialties,
        price: price,
        rating: 0.0,
        clientCount: 0,
        whatsappNumber: whatsappNumber,
        profileImageUrl: '',
        instagramUrl: instagramUrl,
      );

      // Also save a UserModel so the app knows the current role.
      final userForRole = UserModel(
        id: uid,
        role: 'nutritionist',
        email: email,
        fullName: fullName,
        age: 0,
        weightHistory: [],
        height: 0,
        gender: '',
        activityLevel: '',
        goal: '',
      );
      final userRepo = _ref.read(userRepositoryProvider);
      await userRepo.saveUser(userForRole);

      // Save the nutritionist data to Hive so the profile screen updates instantly
      final nutRepo = _ref.read(nutritionistRepositoryProvider);
      await nutRepo.saveNutritionist(nutritionist);

      // Step 3 — Cloud sync (non-blocking)
      try {
        final firestoreService = _ref.read(firestoreServiceProvider);
        await firestoreService.saveNutritionistToCloud(nutritionist);
        await firestoreService.saveUserToCloud(userForRole);
      } catch (_) {
        debugPrint('[AuthController] ⚠️ Nutritionist cloud sync failed');
      }

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────
  /// Sign in an existing user and refresh local data from Firestore.
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authService = _ref.read(firebaseAuthServiceProvider);
      final credential = await authService.logInWithEmail(email, password);
      final uid = credential.user!.uid;
      debugPrint('[AuthController] ✅ Login successful — UID: $uid');

      // Try to fetch the user profile from Firestore and cache locally.
      try {
        final firestoreService = _ref.read(firestoreServiceProvider);
        final cloudUser = await firestoreService.getUserFromCloud(uid);

        if (cloudUser != null) {
          final userRepo = _ref.read(userRepositoryProvider);
          await userRepo.saveUser(cloudUser);

          // If it's a nutritionist, fetch their nutritionist profile too
          if (cloudUser.role == 'nutritionist') {
            final cloudNut = await firestoreService.getNutritionistFromCloud(
              uid,
            );
            if (cloudNut != null) {
              await _ref
                  .read(nutritionistRepositoryProvider)
                  .saveNutritionist(cloudNut);
            }
          }
          // If it's a regular user, ensure they have diet and workout plans locally
          else {
            final dietRepo = _ref.read(dietRepositoryProvider);
            final workoutRepo = _ref.read(workoutRepositoryProvider);

            if (dietRepo.getDailyMeals().isEmpty ||
                workoutRepo.getWorkouts().isEmpty) {
              final planGen = _ref.read(planGeneratorProvider);
              final meals = planGen.generateDietPlan(cloudUser);
              final workouts = planGen.generateWorkoutPlan(cloudUser);
              await dietRepo.saveDailyMeals(meals);
              await workoutRepo.saveWorkouts(workouts);
            }
          }
        }
      } catch (err) {
        debugPrint('[AuthController] ⚠️ Cloud fetch during login failed: $err');
      }

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController] ❌ Firebase Auth Error: ${e.code} - ${e.message}');
      final String errorMsg;
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          errorMsg = 'The email or password you entered is incorrect.';
          break;
        case 'invalid-email':
          errorMsg = 'Please enter a valid email address.';
          break;
        case 'network-request-failed':
          errorMsg = 'No internet connection. Please check your network and try again.';
          break;
        case 'too-many-requests':
          errorMsg = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMsg = 'An unexpected error occurred. Please try again.';
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    } catch (e) {
      debugPrint('[AuthController] ❌ Login error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  /// Sign out the current user and wipe local Hive data.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authService = _ref.read(firebaseAuthServiceProvider);
      await authService.signOut();

      // Wipe local caches
      await _ref.read(userRepositoryProvider).deleteUser();
      await _ref.read(dietRepositoryProvider).clearDiet();
      await _ref.read(workoutRepositoryProvider).clearWorkouts();
      await _ref.read(nutritionistRepositoryProvider).deleteNutritionist();

      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  /// Save diet and workout plans to Firestore for real-time sync.
  Future<void> _savePlansToFirestore(
    String userId,
    List<MealModel> meals,
    List<WorkoutModel> workouts,
  ) async {
    final firestore = FirebaseFirestore.instance;
    
    // Save diet plan
    if (meals.isNotEmpty) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('dietPlans')
          .doc('current')
          .set({
            'meals': meals.map((m) => m.toJson()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
    
    // Save workout plan
    if (workouts.isNotEmpty) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .doc('current')
          .set({
            'workouts': workouts.map((w) => w.toJson()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
  }

  /// Converts Firebase exceptions to user-friendly messages.
  String _friendlyError(Object error) {
    debugPrint('[AuthController] Error: ${error.runtimeType} - $error');
    
    // Network errors
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('connection') || 
        msg.contains('socket') || msg.contains('timeout') ||
        msg.contains('offline')) {
      return 'Network error. Please check your internet connection.';
    }
    
    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      final code = error.code;
      
      switch (code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-not-found':
          return 'Email not found. Please check or sign up.';
        case 'wrong-password':
          return 'Wrong password. Please try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please try later.';
        default:
          return 'Error. Please try again.';
      }
    }
    
    return 'An error occurred. Please try again.';
  }
}

/// ─── Provider ──────────────────────────────────────────────────────────────
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);
