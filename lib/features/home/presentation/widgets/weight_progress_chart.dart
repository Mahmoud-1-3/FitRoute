import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/controllers/user_provider.dart';

/// ─── Weight Progress Chart ─────────────────────────────────────────────────
/// A clean, minimalist line chart showing a recent weight trend.

class WeightProgressChart extends ConsumerWidget {
  const WeightProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    // Sort history chronologically just in case
    final history = user?.weightHistory.toList() ?? [];
    history.sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
          Builder(builder: (context) {
            // Calculate dynamic trend
            String trendText = '';
            IconData trendIcon = Icons.trending_flat_rounded;
            Color trendColor = AppColors.textHint;
            Color trendBg = const Color(0xFFF3F4F6);

            if (history.length >= 2) {
              final diff = history.last.weight - history.first.weight;
              if (diff < 0) {
                trendText = '${diff.toStringAsFixed(1)} kg';
                trendIcon = Icons.trending_down_rounded;
                trendColor = AppColors.primary;
                trendBg = AppColors.primaryLight;
              } else if (diff > 0) {
                trendText = '+${diff.toStringAsFixed(1)} kg';
                trendIcon = Icons.trending_up_rounded;
                trendColor = const Color(0xFFEF4444);
                trendBg = const Color(0xFFFEE2E2);
              } else {
                trendText = '0 kg';
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight Tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (history.length >= 2)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: trendBg,
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
            );
          }),
          const SizedBox(height: 4),
          Text(
            history.length > 1 ? 'Recent trend' : 'Starting weight',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),

          // ── Chart ──
          SizedBox(
            height: 180,
            child: history.isEmpty 
              ? Center(
                  child: Text(
                    'No weight data yet.',
                    style: GoogleFonts.poppins(color: AppColors.textHint),
                  ),
                )
              : Builder(
              builder: (context) {
                // If only 1 entry, duplicate it so the line chart can draw a horizontal line
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
            ),
          ),
        ],
      ),
    );
  }
}
