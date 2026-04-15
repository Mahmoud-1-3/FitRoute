import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/validation_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/meal_model.dart';
import '../../../../core/models/workout_model.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../shared/data/user_repository.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';
import '../../../shared/services/plan_generator_service.dart';
import '../../../shared/data/diet_repository.dart';
import '../../../shared/data/workout_repository.dart';

/// ─── User Profile Screen ───────────────────────────────────────────────────
/// The user's profile management page with editable data and image upload.

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _gender;
  String? _activityLevel;
  String? _goal;

  bool _hasChanges = false;
  bool _isUploading = false;
  File? _pickedImage;
  bool _isEditMode = false;
  bool _genderError = false;

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Heavily compress the image down to < 50KB to safely fit inside a Firestore document!
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _hasChanges = true;
      });
    }
  }

  /// Regenerates the meal and workout plans based on updated user profile
  Future<void> _regeneratePlans(UserModel updatedUser) async {
    try {
      final planGen = ref.read(planGeneratorProvider);
      final meals = planGen.generateDietPlan(updatedUser);
      final workouts = planGen.generateWorkoutPlan(updatedUser);

      final dietRepo = ref.read(dietRepositoryProvider);
      final workoutRepo = ref.read(workoutRepositoryProvider);
      await dietRepo.saveDailyMeals(meals);
      await workoutRepo.saveWorkouts(workouts);

      // Save plans to Firestore for real-time sync across devices
      try {
        await _savePlansToFirestore(updatedUser.id, meals, workouts);
        debugPrint('[Profile] ✅ Plans regenerated and synced to Firestore');
      } catch (firestoreError) {
        debugPrint('[Profile] ⚠️ Firestore sync failed: $firestoreError');
      }

      debugPrint('[Profile] ✅ Plans regenerated successfully');
    } catch (e) {
      debugPrint('[Profile] ❌ Error regenerating plans: $e');
    }
  }

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
          }, SetOptions(merge: true));
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
          }, SetOptions(merge: true));
    }
  }

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch userProvider to get notified of assignment changes
    ref.watch(userProvider);
    
    final box = Hive.box<UserModel>(LocalStorageService.userBox);

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ['current_user']),
      builder: (context, Box<UserModel> box, _) {
        final user = box.get('current_user');

        if (user == null) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // Initialize controllers only on first build with user data
        if (_fullNameCtrl.text.isEmpty) {
          _fullNameCtrl.text = user.fullName;
          _ageCtrl.text = user.age.toString();
          _weightCtrl.text = user.weight.toString();
          _heightCtrl.text = user.height.toString();
          _gender ??= user.gender;
          _activityLevel ??= user.activityLevel;
          _goal ??= user.goal;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ── Header ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isEditMode
                                      ? Icons.close_rounded
                                      : Icons.edit_outlined,
                                  size: 18,
                                ),
                                color: AppColors.primary,
                                onPressed: () {
                                  if (_isEditMode) {
                                    // Reset changes
                                    _fullNameCtrl.text = user.fullName;
                                    _ageCtrl.text = user.age.toString();
                                    _weightCtrl.text = user.weight.toString();
                                    _heightCtrl.text = user.height.toString();
                                    _gender = user.gender;
                                    _activityLevel = user.activityLevel;
                                    _goal = user.goal;
                                    _pickedImage = null;
                                  }
                                  setState(() {
                                    _isEditMode = !_isEditMode;
                                    _hasChanges = false;
                                    _genderError = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Avatar ──
                        Center(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: _isEditMode ? _pickImage : null,
                                child: CircleAvatar(
                                  radius: 52,
                                  backgroundColor: AppColors.primaryLight,
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                            as ImageProvider
                                      : (user.profileImageUrl.isNotEmpty
                                            ? (user.profileImageUrl.startsWith(
                                                        'http',
                                                      )
                                                      ? NetworkImage(
                                                          user.profileImageUrl,
                                                        )
                                                      : MemoryImage(
                                                          base64Decode(
                                                            user.profileImageUrl,
                                                          ),
                                                        ))
                                                  as ImageProvider
                                            : null),
                                  child:
                                      _pickedImage == null &&
                                          user.profileImageUrl.isEmpty
                                      ? Text(
                                          user.fullName.isNotEmpty
                                              ? user.fullName[0].toUpperCase()
                                              : 'U',
                                          style: GoogleFonts.poppins(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (_isEditMode)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            user.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            user.email,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── My Nutritionist ──
                        if (user.assignedNutritionistId != null) ...[
                          _AssignedNutritionistSection(
                            key: ValueKey(
                              'nutritionist_${user.assignedNutritionistId}',
                            ),
                            userId: user.id,
                            nutritionistId: user.assignedNutritionistId!,
                            onRevoke: () async {
                              try {
                                // Update local Hive cache immediately
                                final userBox = Hive.box<UserModel>(
                                  LocalStorageService.userBox,
                                );
                                final currentUser = userBox.get('current_user');
                                if (currentUser != null) {
                                  final updatedUser = currentUser.copyWith(
                                    assignedNutritionistId: null,
                                  );
                                  await userBox.put('current_user', updatedUser);
                                  debugPrint(
                                    '[Profile] ✅ Assignment revoked locally - Hive cleared',
                                  );
                                }

                                // Update Firestore in background (non-blocking)
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id)
                                    .update({
                                      'assignedNutritionistId':
                                          FieldValue.delete()
                                    })
                                    .then((_) {
                                      debugPrint(
                                        '[Profile] ✅ Assignment revoked - Firestore updated',
                                      );
                                    })
                                    .catchError((e) {
                                      debugPrint(
                                          '[Profile] ⚠️ Firestore sync failed: $e');
                                    });

                                if (context.mounted) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Assignment revoked successfully!'),
                                      duration:
                                          Duration(milliseconds: 1500),
                                    ),
                                  );

                                  // The Hive listener in userProvider will automatically
                                  // detect the update and trigger rebuilds across all screens
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  if (mounted) {
                                    debugPrint(
                                        '[Profile] ✅ Assignment revoked - Hive listener will notify all screens!');
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Physiological Data ──
                        if (_isEditMode)
                          _EditableSection(
                            title: 'Physiological Data',
                            icon: Icons.monitor_heart_outlined,
                            children: [
                              _EditableField(
                                label: 'Full Name',
                                controller: _fullNameCtrl,
                                keyboardType: TextInputType.text,
                                validator: ValidationConstants.validateFullName,
                                onChanged: (_) => _markChanged(),
                              ),
                              const SizedBox(height: 12),
                              _EditableField(
                                label: 'Age',
                                controller: _ageCtrl,
                                keyboardType: TextInputType.number,
                                validator: ValidationConstants.validateAge,
                                onChanged: (_) => _markChanged(),
                              ),
                              const SizedBox(height: 12),
                              _EditableField(
                                label: 'Weight (kg)',
                                controller: _weightCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: ValidationConstants.validateWeight,
                                onChanged: (_) => _markChanged(),
                              ),
                              const SizedBox(height: 12),
                              _EditableField(
                                label: 'Height (cm)',
                                controller: _heightCtrl,
                                keyboardType: TextInputType.number,
                                validator: ValidationConstants.validateHeight,
                                onChanged: (_) => _markChanged(),
                              ),
                              const SizedBox(height: 12),
                              _GenderDropdown(
                                value: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                    _genderError = false;
                                    _markChanged();
                                  });
                                },
                              ),
                              if (_genderError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Please select a gender',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              _ActivityLevelDropdown(
                                value: _activityLevel,
                                onChanged: (value) {
                                  setState(() {
                                    _activityLevel = value;
                                    _markChanged();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              _GoalDropdown(
                                value: _goal,
                                onChanged: (value) {
                                  setState(() {
                                    _goal = value;
                                    _markChanged();
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          _SectionCard(
                            title: 'Physiological Data',
                            icon: Icons.monitor_heart_outlined,
                            children: [
                              _DataRow(
                                label: 'Age',
                                value: '${user.age} years',
                              ),
                              _DataRow(
                                label: 'Weight',
                                value: '${user.weight} kg',
                              ),
                              _DataRow(
                                label: 'Height',
                                value: '${user.height} cm',
                              ),
                              _DataRow(label: 'Gender', value: user.gender),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // ── Preferences ──
                        if (!_isEditMode)
                          _SectionCard(
                            title: 'Preferences',
                            icon: Icons.tune_rounded,
                            children: [
                              _DataRow(
                                label: 'Activity Level',
                                value: user.activityLevel,
                              ),
                              _DataRow(label: 'Goal', value: user.goal),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // ── Log Out ──
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .logout();
                              if (context.mounted) {
                                context.go('/role-selection');
                              }
                            },
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Log Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Fixed Save button (only when editing) ──
              if (_isEditMode)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _hasChanges && !_isUploading
                            ? () async {
                                // Validate form
                                final formValid = _formKey.currentState!
                                    .validate();
                                final genderValid = _gender != null;
                                setState(() => _genderError = !genderValid);
                                if (!formValid || !genderValid) return;

                                setState(() => _isUploading = true);
                                try {
                                  String updatedImageUrl = user.profileImageUrl;

                                  if (_pickedImage != null) {
                                    final bytes = await _pickedImage!
                                        .readAsBytes();
                                    updatedImageUrl = base64Encode(bytes);
                                  }

                                  // Parse numeric fields
                                  final age =
                                      int.tryParse(_ageCtrl.text.trim()) ??
                                      user.age;
                                  final weight =
                                      double.tryParse(
                                        _weightCtrl.text.trim(),
                                      ) ??
                                      user.weight;
                                  final height =
                                      double.tryParse(
                                        _heightCtrl.text.trim(),
                                      ) ??
                                      user.height;

                                  final updatedUser = user.copyWith(
                                    fullName: _fullNameCtrl.text.trim(),
                                    age: age,
                                    weight: weight,
                                    height: height,
                                    gender: _gender ?? user.gender,
                                    activityLevel:
                                        _activityLevel ?? user.activityLevel,
                                    goal: _goal ?? user.goal,
                                    profileImageUrl: updatedImageUrl,
                                  );

                                  await ref
                                      .read(userRepositoryProvider)
                                      .saveUser(updatedUser);
                                  await ref
                                      .read(firestoreServiceProvider)
                                      .saveUserToCloud(updatedUser);

                                  // Regenerate plans based on updated profile
                                  await _regeneratePlans(updatedUser);

                                  if (mounted) {
                                    setState(() {
                                      _hasChanges = false;
                                      _isUploading = false;
                                      _isEditMode = false;
                                      _pickedImage = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Profile saved & plans updated ✓',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                          ),
                                        ),
                                        backgroundColor: AppColors.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isUploading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error saving profile: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Editable Section ──────────────────────────────────────────────────────

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// ─── Editable Field ────────────────────────────────────────────────────────

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
              errorStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Card (Read-only) ──────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// ─── Data Row ──────────────────────────────────────────────────────────────

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Assigned Nutritionist Section ────────────────────────────────────────

class _AssignedNutritionistSection extends StatelessWidget {
  const _AssignedNutritionistSection({
    super.key,
    required this.userId,
    required this.nutritionistId,
    required this.onRevoke,
  });

  final String userId;
  final String nutritionistId;
  final Future<void> Function() onRevoke;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('nutritionists')
          .doc(nutritionistId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String name = data['fullName'] ?? 'Nutritionist';
        final String? profileImageUrl = data['profileImageUrl'];

        return _SectionCard(
          title: 'My Nutritionist',
          icon: Icons.medical_services_outlined,
          children: [
            Row(
              children: [
                ClipOval(
                  child: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? (profileImageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: profileImageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 40,
                                  height: 40,
                                  color: AppColors.primaryLight,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 40,
                                  height: 40,
                                  color: AppColors.primaryLight,
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              )
                            : Image.memory(
                                base64Decode(profileImageUrl),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 40,
                                      height: 40,
                                      color: AppColors.primaryLight,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                              ))
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0] : 'N',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    color: AppColors.primary,
                    onPressed: () async {
                      final url = Uri.parse('whatsapp://send?phone=0000000000');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open WhatsApp'),
                            ),
                          );
                        }
                      }
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRevoke,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
                child: Text(
                  'Revoke Assignment',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Gender Dropdown ────────────────────────────────────────────────────────

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({required this.value, required this.onChanged});

  final String? value;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: ValidationConstants.genderOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Activity Level Dropdown ────────────────────────────────────────────────

class _ActivityLevelDropdown extends StatelessWidget {
  const _ActivityLevelDropdown({required this.value, required this.onChanged});

  final String? value;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Level',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: ValidationConstants.activityLevelOptions
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Goal Dropdown ──────────────────────────────────────────────────────────

class _GoalDropdown extends StatelessWidget {
  const _GoalDropdown({required this.value, required this.onChanged});

  final String? value;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: ValidationConstants.goalOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
