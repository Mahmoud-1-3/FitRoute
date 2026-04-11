import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

/// ─── Meal Model ────────────────────────────────────────────────────────────
/// A single meal item within a daily diet plan.

@HiveType(typeId: 2)
@JsonSerializable()
class MealModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'

  @HiveField(3)
  final int calories;

  @HiveField(4)
  final int carbs;

  @HiveField(5)
  final int protein;

  @HiveField(6)
  final int fat;

  @HiveField(7)
  final String imageUrl;

  @HiveField(8)
  final bool isSelected;

  const MealModel({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.imageUrl,
    this.isSelected = false,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  MealModel copyWith({
    String? id,
    String? name,
    String? category,
    int? calories,
    int? carbs,
    int? protein,
    int? fat,
    String? imageUrl,
    bool? isSelected,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
