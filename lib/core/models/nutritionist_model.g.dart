// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutritionist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionistModelAdapter extends TypeAdapter<NutritionistModel> {
  @override
  final int typeId = 1;

  @override
  NutritionistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionistModel(
      id: fields[0] as String,
      email: fields[1] as String,
      fullName: fields[2] as String,
      bio: fields[3] as String,
      specialties: (fields[4] as List).cast<String>(),
      price: fields[5] as double,
      rating: fields[6] as double,
      clientCount: fields[7] as int,
      whatsappNumber: fields[8] as String,
      profileImageUrl: fields[9] == null ? '' : fields[9] as String,
      instagramUrl: fields[10] == null ? '' : fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionistModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.specialties)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.clientCount)
      ..writeByte(8)
      ..write(obj.whatsappNumber)
      ..writeByte(9)
      ..write(obj.profileImageUrl)
      ..writeByte(10)
      ..write(obj.instagramUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionistModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionistModel _$NutritionistModelFromJson(Map<String, dynamic> json) =>
    NutritionistModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      bio: json['bio'] as String,
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      clientCount: (json['clientCount'] as num).toInt(),
      whatsappNumber: json['whatsappNumber'] as String,
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      instagramUrl: json['instagramUrl'] as String? ?? '',
    );

Map<String, dynamic> _$NutritionistModelToJson(NutritionistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'bio': instance.bio,
      'specialties': instance.specialties,
      'price': instance.price,
      'rating': instance.rating,
      'clientCount': instance.clientCount,
      'whatsappNumber': instance.whatsappNumber,
      'profileImageUrl': instance.profileImageUrl,
      'instagramUrl': instance.instagramUrl,
    };
