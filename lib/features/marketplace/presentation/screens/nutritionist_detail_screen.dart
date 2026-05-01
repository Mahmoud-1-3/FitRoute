import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/assignment_request_model.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';
import '../../../shared/data/user_repository.dart';
import '../../data/assignment_repository.dart';

/// ─── Nutritionist Detail Screen ────────────────────────────────────────────

class NutritionistDetailScreen extends ConsumerStatefulWidget {
  const NutritionistDetailScreen({
    super.key,
    required this.nutritionistId,
    required this.name,
    required this.specialty,
    required this.specialties,
    required this.rating,
    required this.clients,
    required this.price,
    required this.bio,
    required this.whatsappNumber,
    required this.instagramUrl,
    this.profileImageUrl,
  });

  final String nutritionistId;
  final String name;
  final String specialty;
  final List<String> specialties;
  final double rating;
  final int clients;
  final int price;
  final String bio;
  final String whatsappNumber;
  final String instagramUrl;
  final String? profileImageUrl;

  @override
  ConsumerState<NutritionistDetailScreen> createState() =>
      _NutritionistDetailScreenState();
}

class _NutritionistDetailScreenState
    extends ConsumerState<NutritionistDetailScreen> {
  bool _isLoading = false;

  // ── Avatar builder ───────────────────────────────────────────────────────
  Widget _buildAvatar(double size) {
    final url = widget.profileImageUrl;
    if (url == null || url.isEmpty) {
      return _initialsAvatar(size);
    }
    if (!url.startsWith('http')) {
      // Base64
      try {
        final bytes = base64Decode(url);
        return ClipOval(
          child: Image.memory(bytes,
              width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsAvatar(size)),
        );
      } catch (_) {
        return _initialsAvatar(size);
      }
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: Colors.white24,
          child: const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
        ),
        errorWidget: (_, __, ___) => _initialsAvatar(size),
      ),
    );
  }

  Widget _initialsAvatar(double size) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'N',
            style: GoogleFonts.poppins(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );

  // ── URL launchers ────────────────────────────────────────────────────────

  /// Tries the native WhatsApp scheme first; falls back to wa.me web link.
  Future<void> _launchWhatsApp(String rawNumber) async {
    if (rawNumber.trim().isEmpty) return;
    // Strip everything except digits and leading +
    final digits = rawNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
    // 1️⃣ Native app
    final nativeUri = Uri.parse('whatsapp://send?phone=$digits');
    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    // 2️⃣ Web fallback
    final webUri = Uri.parse('https://wa.me/$digits');
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  /// Normalises a URL (adds https:// if missing) and opens it externally.
  Future<void> _launchUrl(String rawUrl) async {
    if (rawUrl.trim().isEmpty) return;
    var url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isAssignedToThis =
        user?.assignedNutritionistId == widget.nutritionistId;
    final isAssignedToOther = user?.assignedNutritionistId != null &&
        user?.assignedNutritionistId != widget.nutritionistId;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header ──
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(36),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            // Back button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Avatar with white ring
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.25),
                              ),
                              child: _buildAvatar(84),
                            ),
                            const SizedBox(height: 10),
                            // Name — high contrast white
                            Text(
                              widget.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Certified Nutritionist',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Stats row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBadge(
                            icon: Icons.people_rounded,
                            value: '${widget.clients}',
                            label: 'Clients',
                            color: const Color(0xFF6366F1),
                          ),
                          Container(
                              width: 1, height: 40, color: AppColors.divider),
                          _StatBadge(
                            icon: Icons.payments_outlined,
                            value: '${widget.price} EGP',
                            label: 'Per Month',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── About ──
                  if (widget.bio.isNotEmpty) ...[
                    _Section(
                      title: 'About',
                      child: Text(
                        widget.bio,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Specialties ──
                  if (widget.specialties.isNotEmpty) ...[
                    _Section(
                      title: 'Specialties',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.specialties
                            .map((s) => _chip(s))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Connect section (always shown if links exist) ──
                  if (widget.whatsappNumber.isNotEmpty || widget.instagramUrl.isNotEmpty) ...[
                    _Section(
                      title: 'Connect',
                      child: Column(
                        children: [
                          // WhatsApp
                          if (widget.whatsappNumber.isNotEmpty)
                            _ContactTile(
                              icon: FontAwesomeIcons.whatsapp,
                              iconColor: const Color(0xFF25D366),
                              bgColor:
                                  const Color(0xFF25D366).withOpacity(0.08),
                              label: 'WhatsApp',
                              subtitle: widget.whatsappNumber,
                              onTap: () => _launchWhatsApp(widget.whatsappNumber),
                            ),
                          if (widget.whatsappNumber.isNotEmpty &&
                              widget.instagramUrl.isNotEmpty)
                            const SizedBox(height: 10),
                          // Instagram
                          if (widget.instagramUrl.isNotEmpty)
                            _ContactTile(
                              icon: FontAwesomeIcons.instagram,
                              iconColor: const Color(0xFFE1306C),
                              bgColor:
                                  const Color(0xFFE1306C).withOpacity(0.08),
                              label: 'Instagram',
                              subtitle: widget.instagramUrl,
                              onTap: () => _launchUrl(widget.instagramUrl),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Pricing ──
                  _Section(
                    title: 'Pricing',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Coaching',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Custom meal plans + weekly check-ins',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${widget.price} EGP/mo',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Fixed bottom action bar ──
          if (!isAssignedToThis && !isAssignedToOther)
            _BottomBar(
              isLoading: _isLoading,
              price: widget.price,
              onSend: () async {
                final user =
                    ref.read(userRepositoryProvider).getUser();
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Not logged in.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                setState(() => _isLoading = true);
                try {
                  final requestRepo =
                      ref.read(assignmentRepositoryProvider);
                  final reqId = FirebaseFirestore.instance
                      .collection('assignment_requests')
                      .doc()
                      .id;
                  final newRequest = AssignmentRequestModel(
                    id: reqId,
                    userId: user.id,
                    nutritionistId: widget.nutritionistId,
                    status: 'pending',
                    createdAt: DateTime.now(),
                  );
                  await requestRepo.createRequest(newRequest);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Request sent to ${widget.name}!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send request: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            )
          else if (isAssignedToThis)
            _ActiveNutritionistBar(name: widget.name),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      );
}

// ─── Bottom Bars ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.isLoading,
      required this.price,
      required this.onSend});
  final bool isLoading;
  final int price;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSend,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    'Send Request ($price EGP/mo)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ActiveNutritionistBar extends StatelessWidget {
  const _ActiveNutritionistBar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Active Nutritionist',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Badge ──────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ─── Section wrapper ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Contact Tile ─────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor, bgColor;
  final String label, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded,
                size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
