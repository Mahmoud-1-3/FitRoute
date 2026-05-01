import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_entry_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class WeightEntry {
  @HiveField(0)
  final double weight;

  @HiveField(1)
  final DateTime timestamp;

  const WeightEntry({
    required this.weight,
    required this.timestamp,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryFromJson(json);

  Map<String, dynamic> toJson() => _$WeightEntryToJson(this);
}
