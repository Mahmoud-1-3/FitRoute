// ──────────────────────────────────────────────────────────────────────────────
// After creating / modifying model files, run:
//
//   dart run build_runner build --delete-conflicting-outputs
//
// This generates the .g.dart files (Hive adapters + JSON serialisation).
// ──────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'weight_entry_model.dart';

part 'user_model.g.dart';

/// ─── User Model ────────────────────────────────────────────────────────────
/// Represents a FitRoute user (role: 'user' or 'nutritionist').

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role; // 'user' or 'nutritionist'

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final int age;

  @HiveField(5)
  final List<WeightEntry> weightHistory;

  /// Compatibility getter: returns the most recent weight, or 0.0 if empty.
  double get weight =>
      weightHistory.isNotEmpty ? weightHistory.last.weight : 0.0;

  @HiveField(6)
  final double height;

  @HiveField(7)
  final String gender;

  @HiveField(8)
  final String activityLevel;

  @HiveField(9)
  final String goal;

  @HiveField(10)
  final String? assignedNutritionistId;

  @HiveField(11, defaultValue: '')
  final String profileImageUrl;

  const UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.fullName,
    required this.age,
    required this.weightHistory,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.assignedNutritionistId,
    this.profileImageUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Create a copy with optional field overrides.
  UserModel copyWith({
    String? id,
    String? role,
    String? email,
    String? fullName,
    int? age,
    List<WeightEntry>? weightHistory,
    double? height,
    String? gender,
    String? activityLevel,
    String? goal,
    String? assignedNutritionistId,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      weightHistory: weightHistory ?? this.weightHistory,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      assignedNutritionistId:
          assignedNutritionistId ?? this.assignedNutritionistId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
