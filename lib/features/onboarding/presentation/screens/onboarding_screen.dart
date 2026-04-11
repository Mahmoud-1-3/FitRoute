import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/onboarding_page_widget.dart';

/// ─── Onboarding Screen ──────────────────────────────────────────────────────
/// A 3-page carousel showcasing the app's value propositions.
/// • Skip at any time → /role-selection
/// • Next advances the page; final page shows "Get Started" → /role-selection

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// The three onboarding slides.
  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Personalized ',
      titleAccent: 'Diet Plans',
      subtitle:
          'Fuel your body with meals tailored to your goals. Whether you\'re '
          'building muscle or staying lean, FitRoute crafts the perfect plan for you.',
      chips: [],
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Connect with\n',
      titleAccent: 'Nutritionists',
      subtitle:
          'Get matched with professional coaches who will create a roadmap '
          'specifically for your body type and fitness goals.',
      chips: ['💬  24/7 Chat', '🍽  Meal Plans'],
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Track Your ',
      titleAccent: 'Workouts',
      subtitle:
          'Follow structured workout plans, track sets & reps, and monitor '
          'your progress over time with detailed analytics.',
      chips: ['🏋️  Programs', '📊  Analytics'],
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/role-selection');
    }
  }

  void _onSkip() => context.go('/role-selection');

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (back + skip) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show back arrow from page 2 onward
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page view ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    OnboardingPageWidget(data: _pages[index]),
              ),
            ),

            // ── Bottom controls ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dots
                  _PageIndicator(count: _pages.length, current: _currentPage),
                  const SizedBox(height: 32),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLastPage ? 'Get Started' : 'Continue'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // "Already have an account?" on last page
                  if (isLastPage)
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page Indicator ─────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
