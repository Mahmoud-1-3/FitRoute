import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/client_weight_chart.dart';

/// ─── Client Progress Screen ────────────────────────────────────────────────
/// Displays a read-only overview of a client's progress, including their
/// weight history chart. Navigated to from the Nutritionist's client list.

class ClientProgressScreen extends StatelessWidget {
  const ClientProgressScreen({
    super.key,
    required this.client,
  });

  final UserModel client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Client Progress',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Client Header ──
            _buildClientHeader(),
            const SizedBox(height: 20),

            // ── Stats Row ──
            _buildStatsRow(),
            const SizedBox(height: 20),

            // ── Weight Chart ──
            ClientWeightChart(
              weightHistory: client.weightHistory,
              clientName: client.fullName,
            ),
            const SizedBox(height: 20),

            // ── Additional Info ──
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    'Goal: ${client.goal}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatTile(
          icon: Icons.monitor_weight_outlined,
          label: 'Current',
          value: '${client.weight.toStringAsFixed(1)} kg',
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.height_rounded,
          label: 'Height',
          value: '${client.height.toStringAsFixed(0)} cm',
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.cake_outlined,
          label: 'Age',
          value: '${client.age} yrs',
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Gender', value: client.gender),
          const Divider(height: 20),
          _DetailRow(label: 'Activity Level', value: client.activityLevel),
          const Divider(height: 20),
          _DetailRow(label: 'Goal', value: client.goal),
          if (client.weightHistory.isNotEmpty) ...[
            const Divider(height: 20),
            _DetailRow(
              label: 'Starting Weight',
              value: '${client.weightHistory.first.weight.toStringAsFixed(1)} kg',
            ),
          ],
          if (client.weightHistory.length >= 2) ...[
            const Divider(height: 20),
            _DetailRow(
              label: 'Weight Entries',
              value: '${client.weightHistory.length} records',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (client.profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          client.fullName.isNotEmpty ? client.fullName[0] : 'C',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final bool isBase64 = !client.profileImageUrl.startsWith('http');

    if (isBase64) {
      try {
        final imageBytes = base64Decode(client.profileImageUrl);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            client.fullName.isNotEmpty ? client.fullName[0] : 'C',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        );
      }
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: client.profileImageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLight,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            client.fullName.isNotEmpty ? client.fullName[0] : 'C',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
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
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
