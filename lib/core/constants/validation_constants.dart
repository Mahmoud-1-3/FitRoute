/// ─── Validation Constants ──────────────────────────────────────────────────
/// Centralized validation boundaries used during signup and profile editing.
/// Ensures consistent user data constraints across the app.

class ValidationConstants {
  // ── Age boundaries ──
  static const int minAge = 10;
  static const int maxAge = 100;
  static const String ageErrorMessage = '10 – 100 years';

  // ── Weight boundaries (kg) ──
  static const double minWeight = 20;
  static const double maxWeight = 300;
  static const String weightErrorMessage = '20 – 300 kg';

  // ── Height boundaries (cm) ──
  static const double minHeight = 80;
  static const double maxHeight = 250;
  static const String heightErrorMessage = '80 – 250 cm';

  // ── Gender options ──
  static const List<String> genderOptions = ['Male', 'Female'];

  // ── Activity levels ──
  static const List<String> activityLevelOptions = [
    'Little to no exercise (e.g., Desk job)',
    'Light exercise (1-3 days a week)',
    'Moderate exercise (3-5 days a week)',
    'Heavy exercise (6-7 days a week)',
    'Very heavy exercise (Physical job or training 2x/day)',
  ];

  // ── Goal options ──
  static const List<String> goalOptions = [
    'Lose Weight',
    'Build Muscle',
    'Maintain',
  ];

  // ── Validators ──
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < minAge || n > maxAge) return ageErrorMessage;
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Weight is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < minWeight || n > maxWeight) return weightErrorMessage;
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Height is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < minHeight || n > maxHeight) return heightErrorMessage;
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null) return 'Please select a gender';
    return null;
  }

  static String? validateActivityLevel(String? value) {
    if (value == null)
      return 'Please select your activity level';
    return null;
  }

  static String? validateGoal(String? value) {
    if (value == null) return 'Please select your goal';
    return null;
  }
}
