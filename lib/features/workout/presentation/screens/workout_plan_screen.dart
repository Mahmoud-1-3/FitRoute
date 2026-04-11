import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// ─── Workout Plan Screen ───────────────────────────────────────────────────
/// Full-body bodyweight workout with expandable exercise cards, inline set
/// tracking, rest timer, progress bar, and exercise tips.

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  // ── Exercise data ──
  final List<_ExerciseData> _exercises = [
    _ExerciseData(
      name: 'Push-ups',
      icon: Icons.fitness_center_rounded,
      sets: 3,
      reps: 10,
      repsLabel: '10 reps',
      description:
          'Start in a plank position with hands slightly wider than shoulder-width. '
          'Lower your body until your chest nearly touches the floor, then push back up. '
          'Keep your core tight and body in a straight line throughout.',
    ),
    _ExerciseData(
      name: 'Bodyweight Squats',
      icon: Icons.accessibility_new_rounded,
      sets: 3,
      reps: 15,
      repsLabel: '15 reps',
      description:
          'Stand with feet shoulder-width apart. Lower your hips back and down as if '
          'sitting in a chair until thighs are parallel to the floor. Keep your chest '
          'up and knees over your toes, then drive through your heels to stand.',
    ),
    _ExerciseData(
      name: 'Plank',
      icon: Icons.straighten_rounded,
      sets: 3,
      reps: 1,
      repsLabel: '30 sec hold',
      description:
          'Support your body on forearms and toes with elbows directly under shoulders. '
          'Keep your body perfectly straight from head to heels. Engage your core and '
          'hold the position without letting your hips sag or pike up.',
    ),
    _ExerciseData(
      name: 'Walking Lunges',
      icon: Icons.directions_walk_rounded,
      sets: 2,
      reps: 10,
      repsLabel: '10 reps each leg',
      description:
          'Step forward with one leg and lower your hips until both knees are bent at '
          '90 degrees. Push off the front foot to step the back foot forward into the '
          'next lunge. Alternate legs with each step and keep your torso upright.',
    ),
    _ExerciseData(
      name: 'Shoulder Taps',
      icon: Icons.back_hand_rounded,
      sets: 2,
      reps: 20,
      repsLabel: '20 reps',
      description:
          'Start in a high plank position. Lift one hand to tap the opposite shoulder, '
          'then return it to the floor. Alternate sides while keeping your hips as '
          'still as possible. This builds core stability and shoulder strength.',
    ),
  ];

  late List<List<bool>> _setCompleted;
  int _expandedIndex = -1;
  int _restSeconds = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _setCompleted = _exercises.map((e) => List.filled(e.sets, false)).toList();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  int get _totalSets => _exercises.fold<int>(0, (s, e) => s + e.sets);

  int get _completedSets =>
      _setCompleted.fold<int>(0, (s, list) => s + list.where((b) => b).length);

  double get _progress => _totalSets > 0 ? _completedSets / _totalSets : 0.0;

  String get _progressLabel {
    final pct = (_progress * 100).round();
    if (pct == 0) return 'Getting started!';
    if (pct < 50) return 'Keep going!';
    if (pct < 100) return 'Almost there!';
    return 'Workout complete! 💪';
  }

  void _toggleSet(int exerciseIdx, int setIdx) {
    setState(() {
      _setCompleted[exerciseIdx][setIdx] = !_setCompleted[exerciseIdx][setIdx];
    });
  }

  void _startRestTimer() {
    if (_restSeconds > 0) return;
    setState(() => _restSeconds = 60);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 1) {
        t.cancel();
        setState(() => _restSeconds = 0);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Exercise Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Progress Section ──
                    _SectionTitle(
                      icon: Icons.show_chart_rounded,
                      title: 'Your Progress',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progress * 100).round()}% Complete',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _progressLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Plan info card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Basic Exercise Plan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'For beginners of all fitness levels',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This exercise plan is designed for beginners '
                            'and can be done without any equipment. Perform '
                            'this routine 3 times per week with at least one '
                            'rest day between sessions.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Today's Workout ──
                    _SectionTitle(
                      icon: Icons.today_rounded,
                      title: "Today's Workout",
                    ),
                    const SizedBox(height: 12),

                    // ── Exercise cards ──
                    ...List.generate(_exercises.length, (i) {
                      final ex = _exercises[i];
                      final isExpanded = _expandedIndex == i;
                      final completedInEx = _setCompleted[i]
                          .where((b) => b)
                          .length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ExerciseCard(
                          exercise: ex,
                          isExpanded: isExpanded,
                          setCompleted: _setCompleted[i],
                          completedCount: completedInEx,
                          restSeconds: _restSeconds,
                          onExpandToggle: () {
                            setState(() {
                              _expandedIndex = isExpanded ? -1 : i;
                            });
                          },
                          onToggleSet: (setIdx) => _toggleSet(i, setIdx),
                          onStartRest: _startRestTimer,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // ── Exercise Tips ──
                    const Divider(),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Exercise Tips',
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                      icon: Icons.wb_sunny_outlined,
                      text:
                          'Always warm up for 5 minutes before starting your workout.',
                    ),
                    _TipRow(
                      icon: Icons.tune_rounded,
                      text:
                          'Start with lighter weights or modifications if needed.',
                    ),
                    _TipRow(
                      icon: Icons.water_drop_outlined,
                      text: 'Stay hydrated throughout your workout.',
                    ),
                    _TipRow(
                      icon: Icons.timer_outlined,
                      text: 'Rest between sets for 30-60 seconds.',
                    ),
                    _TipRow(
                      icon: Icons.warning_amber_rounded,
                      text:
                          'If you experience sharp pain, stop immediately and consult a professional.',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Exercise Data ──────────────────────────────────────────────────────────

class _ExerciseData {
  const _ExerciseData({
    required this.name,
    required this.icon,
    required this.sets,
    required this.reps,
    required this.repsLabel,
    required this.description,
  });

  final String name;
  final IconData icon;
  final int sets;
  final int reps;
  final String repsLabel;
  final String description;
}

// ─── Section Title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Exercise Card ──────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isExpanded,
    required this.setCompleted,
    required this.completedCount,
    required this.restSeconds,
    required this.onExpandToggle,
    required this.onToggleSet,
    required this.onStartRest,
  });

  final _ExerciseData exercise;
  final bool isExpanded;
  final List<bool> setCompleted;
  final int completedCount;
  final int restSeconds;
  final VoidCallback onExpandToggle;
  final ValueChanged<int> onToggleSet;
  final VoidCallback onStartRest;

  @override
  Widget build(BuildContext context) {
    final allDone = completedCount == exercise.sets;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: allDone
              ? AppColors.primary
              : (isExpanded
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.divider),
          width: allDone ? 1.5 : 1,
        ),
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
          // ── Header row (always visible) ──
          InkWell(
            onTap: onExpandToggle,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Exercise icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: allDone
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      allDone ? Icons.check_rounded : exercise.icon,
                      color: allDone ? Colors.white : AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & sets x reps
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: allDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          '${exercise.sets} sets x ${exercise.repsLabel}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Completed count badge
                  if (completedCount > 0 && !allDone)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        '$completedCount/${exercise.sets}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textHint,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    exercise.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Set tracking rows
                  ...List.generate(exercise.sets, (si) {
                    final done = setCompleted[si];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => onToggleSet(si),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.primaryLight
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: done
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: done
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: done
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                    width: 2,
                                  ),
                                ),
                                child: done
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Set ${si + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      exercise.repsLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (done)
                                Text(
                                  'Done ✓',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),

                  // Rest timer button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: restSeconds > 0 ? null : onStartRest,
                      icon: Icon(
                        restSeconds > 0
                            ? Icons.hourglass_bottom_rounded
                            : Icons.timer_outlined,
                        size: 18,
                      ),
                      label: Text(
                        restSeconds > 0
                            ? 'Resting… ${restSeconds}s'
                            : 'Start Rest Timer (60s)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: restSeconds > 0
                            ? AppColors.textHint
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

// ─── Tip Row ────────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
