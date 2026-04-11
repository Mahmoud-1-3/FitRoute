import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/nutritionist_model.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// ─── Nutritionist Profile Screen ───────────────────────────────────────────
/// The nutritionist's own profile management page (3rd tab in their shell).
/// Editable bio, specialties chips, pricing, contact links, save & logout.

class NutritionistProfileScreen extends ConsumerStatefulWidget {
  const NutritionistProfileScreen({super.key});

  @override
  ConsumerState<NutritionistProfileScreen> createState() =>
      _NutritionistProfileScreenState();
}

class _NutritionistProfileScreenState
    extends ConsumerState<NutritionistProfileScreen> {
  late final TextEditingController _bioCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _instagramCtrl;

  late List<String> _specialties;
  bool _hasChanges = false;

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void initState() {
    super.initState();
    // Initialize empty controllers, they will be updated in the builder if needed
    _bioCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _whatsappCtrl = TextEditingController();
    _instagramCtrl = TextEditingController();
    _specialties = [];
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _priceCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen directly to the Hive Box so the UI rebuilds immediately when 
    // the AuthController fetches updated data from Firestore.
    final box = Hive.box<NutritionistModel>(LocalStorageService.nutritionistBox);

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ['current_nutritionist']),
      builder: (context, Box<NutritionistModel> box, _) {
        final nutritionist = box.get('current_nutritionist');

        if (nutritionist == null) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // Only update text fields if they haven't been edited by the user yet 
        // to prevent overwriting during typing.
        if (!_hasChanges) {
          if (_bioCtrl.text != nutritionist.bio) _bioCtrl.text = nutritionist.bio;
          if (_priceCtrl.text != nutritionist.price.toString() && nutritionist.price > 0) {
            _priceCtrl.text = nutritionist.price.toString();
          }
          if (_whatsappCtrl.text != nutritionist.whatsappNumber) {
            _whatsappCtrl.text = nutritionist.whatsappNumber;
          }
          if (_specialties.isEmpty && nutritionist.specialties.isNotEmpty) {
            _specialties = List.from(nutritionist.specialties);
          }
        }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      'My Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Avatar ──
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              nutritionist.fullName.isNotEmpty
                                  ? nutritionist.fullName[0].toUpperCase()
                                  : 'N',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
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
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        nutritionist.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Nutritionist',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Bio / About Me ──
                    _SectionLabel(title: 'About Me', icon: Icons.info_outline),
                    const SizedBox(height: 8),
                    _EditableCard(
                      child: TextField(
                        controller: _bioCtrl,
                        maxLines: 4,
                        onChanged: (_) => _markChanged(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write about yourself…',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Specialties ──
                    _SectionLabel(
                      title: 'Specialties',
                      icon: Icons.local_offer_outlined,
                    ),
                    const SizedBox(height: 8),
                    _EditableCard(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._specialties.map(
                            (s) => _SpecialtyChip(
                              label: s,
                              onDelete: () {
                                setState(() => _specialties.remove(s));
                                _markChanged();
                              },
                            ),
                          ),
                          ActionChip(
                            label: Text(
                              '+ Add',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull,
                              ),
                              side: BorderSide.none,
                            ),
                            onPressed: () => _showAddSpecialty(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Pricing ──
                    _SectionLabel(
                      title: 'Monthly Price',
                      icon: Icons.attach_money_rounded,
                    ),
                    const SizedBox(height: 8),
                    _EditableCard(
                      child: Row(
                        children: [
                          Text(
                            '\$',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _markChanged(),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                suffixText: '/mo',
                                suffixStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Contact Links ──
                    _SectionLabel(
                      title: 'Contact Links',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 8),
                    _EditableCard(
                      child: Column(
                        children: [
                          _ContactField(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            controller: _whatsappCtrl,
                            onChanged: (_) => _markChanged(),
                          ),
                          const Divider(height: 20),
                          _ContactField(
                            icon: Icons.camera_alt_outlined,
                            label: 'Instagram',
                            controller: _instagramCtrl,
                            onChanged: (_) => _markChanged(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Log Out ──
                    Center(
                      child: TextButton.icon(
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
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Fixed Save button ──
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
                    onPressed: _hasChanges
                        ? () {
                            setState(() => _hasChanges = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profile saved ✓',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Save Changes'),
                  ),
                ),
              ),
            ),
          ],
            ),
          
        ),
      );
      },
    );
  }

  void _showAddSpecialty() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Add Specialty',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Vegan Nutrition',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                setState(() => _specialties.add(text));
                _markChanged();
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Editable Card Container ────────────────────────────────────────────────

class _EditableCard extends StatelessWidget {
  const _EditableCard({required this.child});
  final Widget child;

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
      child: child,
    );
  }
}

// ─── Specialty Chip ─────────────────────────────────────────────────────────

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label, this.onDelete});
  final String label;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Field ──────────────────────────────────────────────────────────

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.icon,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              TextField(
                controller: controller,
                onChanged: onChanged,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
