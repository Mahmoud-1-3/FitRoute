import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/validation_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/form_fields.dart';
import '../controllers/auth_controller.dart';

/// ─── User Sign-Up Screen ───────────────────────────────────────────────────
/// Multi-section registration form: basic info → body data → preferences.

class UserSignupScreen extends ConsumerStatefulWidget {
  const UserSignupScreen({super.key});

  @override
  ConsumerState<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends ConsumerState<UserSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  // Selections
  String? _gender;
  String? _activityLevel;
  String? _goal;

  bool _genderError = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    final genderValid = _gender != null;
    setState(() => _genderError = !genderValid);
    if (!formValid || !genderValid) return;

    // Safely parse numeric fields — show SnackBar if invalid.
    final age = int.tryParse(_ageCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    final height = double.tryParse(_heightCtrl.text.trim());

    if (age == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid numbers for age, weight, and height.',
          ),
        ),
      );
      return;
    }

    // Trigger the full offline-first registration flow via AuthController.
    ref
        .read(authControllerProvider.notifier)
        .registerUser(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          age: age,
          weight: weight,
          height: height,
          gender: _gender!,
          activityLevel: _activityLevel!,
          goal: _goal!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen for auth state changes → navigate or show error.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/role-selection');
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/role-selection'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Header ──
                Text(
                  'Create Your Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Start your fitness journey today.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Error Banner ──
                if (authState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // ── Basic Info Section ──
                _sectionTitle('Basic Information'),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    if (!RegExp(r'^[\w\-.]+@[\w\-.]+\.\w+$').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordField(
                  label: 'Password',
                  hintText: 'Min. 6 characters',
                  controller: _passwordCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Physiological Data Section ──
                _sectionTitle('Body Information'),
                const SizedBox(height: 12),

                // Age + Gender row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Age',
                        hintText: 'e.g. 25',
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                        validator: ValidationConstants.validateAge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionChipGroup(
                            label: 'Gender',
                            options: const ['Male', 'Female'],
                            selectedValue: _gender,
                            onSelected: (v) => setState(() {
                              _gender = v;
                              _genderError = false;
                            }),
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weight + Height row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Weight (kg)',
                        hintText: 'e.g. 70',
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: const Icon(
                          Icons.monitor_weight_outlined,
                          size: 20,
                        ),
                        validator: ValidationConstants.validateWeight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Height (cm)',
                        hintText: 'e.g. 175',
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.height_rounded, size: 20),
                        validator: ValidationConstants.validateHeight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Preferences Section ──
                _sectionTitle('Preferences'),
                const SizedBox(height: 12),
                CustomDropdownField<String>(
                  label: 'Activity Level',
                  hintText: 'Select your activity level',
                  value: _activityLevel,
                  items: const [
                    DropdownMenuItem(
                      value: 'Little to no exercise (e.g., Desk job)',
                      child: Text(
                        'Little to no exercise (e.g., Desk job)',
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Light exercise (1-3 days a week)',
                      child: Text(
                        'Light exercise (1-3 days a week)',
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Moderate exercise (3-5 days a week)',
                      child: Text(
                        'Moderate exercise (3-5 days a week)',
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Heavy exercise (6-7 days a week)',
                      child: Text(
                        'Heavy exercise (6-7 days a week)',
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'Very heavy exercise (Physical job or training 2x/day)',
                      child: Text(
                        'Very heavy exercise (Physical job or training 2x/day)',
                        maxLines: 1,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _activityLevel = v),
                  validator: (v) => v == null
                      ? 'Please select your activity level to calculate your calories.'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomDropdownField<String>(
                  label: 'Main Goal',
                  hintText: 'Select your goal',
                  value: _goal,
                  items: const [
                    DropdownMenuItem(
                      value: 'Lose Weight',
                      child: Text('Lose Weight'),
                    ),
                    DropdownMenuItem(
                      value: 'Build Muscle',
                      child: Text('Build Muscle'),
                    ),
                    DropdownMenuItem(
                      value: 'Maintain',
                      child: Text('Maintain'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _goal = v),
                  validator: (v) => v == null ? 'Please select a goal' : null,
                ),
                const SizedBox(height: 36),

                // ── Submit Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Create Account'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Footer ──
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Log in',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
