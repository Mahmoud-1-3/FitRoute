import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/form_fields.dart';
import '../controllers/auth_controller.dart';

/// ─── Nutritionist Sign-Up / Profile Setup Screen ───────────────────────────

class NutritionistSignupScreen extends ConsumerStatefulWidget {
  const NutritionistSignupScreen({super.key});

  @override
  ConsumerState<NutritionistSignupScreen> createState() =>
      _NutritionistSignupScreenState();
}

class _NutritionistSignupScreenState
    extends ConsumerState<NutritionistSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _specialtiesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _bioCtrl.dispose();
    _specialtiesCtrl.dispose();
    _priceCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final specialties = _specialtiesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    ref
        .read(authControllerProvider.notifier)
        .registerNutritionist(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          specialties: specialties,
          price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
          whatsappNumber: _whatsappCtrl.text.trim(),
          instagramUrl: _instagramCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen for auth state changes → navigate or show error.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go('/nutritionist-dashboard');
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
                  'Create your professional profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Set up your account and start connecting\nwith clients.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),



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

                // ── Account Info ──
                _sectionTitle('Account Information'),
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

                // ── Professional Details ──
                _sectionTitle('Professional Details'),
                const SizedBox(height: 12),

                // Bio — plain TextFormField to avoid potential issues
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio / About Me',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tell clients about yourself…',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Bio is required'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Specialties / Services',
                  hintText: 'e.g. Weight Loss, Sports Nutrition',
                  controller: _specialtiesCtrl,
                  prefixIcon: const Icon(Icons.star_outline_rounded, size: 20),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Consultation Price (EGP)',
                  hintText: 'e.g. 150',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 28),

                // ── Contact Links ──
                _sectionTitle('Contact Links'),
                const SizedBox(height: 12),

                CustomTextField(
                  label: 'WhatsApp Number',
                  hintText: 'e.g. +201012345678',
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Instagram Link',
                  hintText: 'https://instagram.com/yourhandle',
                  controller: _instagramCtrl,
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.link_rounded, size: 20),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'This field is required' : null,
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
                        : const Text('Create Professional Account'),
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
