import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/weight_entry_model.dart';

/// ─── Client Weight Chart ───────────────────────────────────────────────────
/// Read-only weight tracking chart for a client's profile.
/// Accepts a [List<WeightEntry>] directly instead of reading from a provider,
/// so it can be used in any context (nutritionist viewing a client, etc.).

class ClientWeightChart extends StatelessWidget {
  const ClientWeightChart({
    super.key,
    required this.weightHistory,
    required this.clientName,
  });

  final List<WeightEntry> weightHistory;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    // Sort history chronologically
    final history = weightHistory.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate the trend badge
    String trendText = '';
    IconData trendIcon = Icons.trending_flat_rounded;
    Color trendColor = AppColors.textHint;

    if (history.length >= 2) {
      final diff = history.last.weight - history.first.weight;
      if (diff < 0) {
        trendText = '${diff.toStringAsFixed(1)} kg';
        trendIcon = Icons.trending_down_rounded;
        trendColor = AppColors.primary;
      } else if (diff > 0) {
        trendText = '+${diff.toStringAsFixed(1)} kg';
        trendIcon = Icons.trending_up_rounded;
        trendColor = const Color(0xFFEF4444);
      } else {
        trendText = '0 kg';
        trendIcon = Icons.trending_flat_rounded;
        trendColor = AppColors.textHint;
      }
    }

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
          // ── Title row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Weight Tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (history.length >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor == AppColors.primary
                        ? AppColors.primaryLight
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            history.length > 1
                ? 'Recent trend'
                : (history.length == 1 ? 'Starting weight' : ''),
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),

          // ── Chart ──
          SizedBox(
            height: 180,
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 40,
                          color: AppColors.textHint.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Client hasn't logged their\nstarting weight yet.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildChart(history),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<WeightEntry> history) {
    // Prepare plot data
    final List<double> plotWeights = [];
    final List<String> plotLabels = [];

    if (history.length == 1) {
      plotWeights.add(history.first.weight);
      plotWeights.add(history.first.weight);
      plotLabels.add('');
      plotLabels.add('Start');
    } else {
      for (final entry in history) {
        plotWeights.add(entry.weight);
        final date = entry.timestamp;
        plotLabels.add('${date.day}/${date.month}');
      }
    }

    // Calculate bounds
    final double maxW = plotWeights.reduce((a, b) => a > b ? a : b);
    final double minW = plotWeights.reduce((a, b) => a < b ? a : b);

    final double minY = minW - 2.0;
    final double maxY = maxW + 2.0;
    final double range = maxY - minY;

    double yInterval = 1.0;
    if (range > 20) {
      yInterval = 5.0;
    } else if (range > 10) {
      yInterval = 2.0;
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.divider, strokeWidth: 0.8),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: yInterval,
              getTitlesWidget: (value, _) {
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= plotLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    plotLabels[i],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              plotWeights.length,
              (i) => FlSpot(i.toDouble(), plotWeights[i]),
            ),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y} kg',
                    GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 600),
    );
  }
}
