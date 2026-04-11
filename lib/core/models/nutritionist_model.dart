import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutritionist_model.g.dart';

/// ─── Nutritionist Model ────────────────────────────────────────────────────
/// Public profile visible to users in the marketplace.

@HiveType(typeId: 1)
@JsonSerializable()
class NutritionistModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String bio;

  @HiveField(4)
  final List<String> specialties;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final int clientCount;

  @HiveField(8)
  final String whatsappNumber;

  const NutritionistModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.bio,
    required this.specialties,
    required this.price,
    required this.rating,
    required this.clientCount,
    required this.whatsappNumber,
  });

  factory NutritionistModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionistModelFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionistModelToJson(this);

  NutritionistModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? bio,
    List<String>? specialties,
    double? price,
    double? rating,
    int? clientCount,
    String? whatsappNumber,
  }) {
    return NutritionistModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      clientCount: clientCount ?? this.clientCount,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }
}
