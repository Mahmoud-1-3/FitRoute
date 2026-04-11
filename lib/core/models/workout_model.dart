import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_model.g.dart';

/// ─── Workout Model ─────────────────────────────────────────────────────────
/// A single exercise within a workout plan.

@HiveType(typeId: 3)
@JsonSerializable()
class WorkoutModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String targetMuscle;

  @HiveField(3)
  final int sets;

  @HiveField(4)
  final int reps;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String instructions;

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.reps,
    required this.imageUrl,
    required this.instructions,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutModelToJson(this);

  WorkoutModel copyWith({
    String? id,
    String? name,
    String? targetMuscle,
    int? sets,
    int? reps,
    String? imageUrl,
    String? instructions,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
    );
  }
}
