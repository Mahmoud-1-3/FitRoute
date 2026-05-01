// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightEntryAdapter extends TypeAdapter<WeightEntry> {
  @override
  final int typeId = 4;

  @override
  WeightEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightEntry(
      weight: fields[0] as double,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightEntry _$WeightEntryFromJson(Map<String, dynamic> json) => WeightEntry(
      weight: (json['weight'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$WeightEntryToJson(WeightEntry instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'timestamp': instance.timestamp.toIso8601String(),
    };
