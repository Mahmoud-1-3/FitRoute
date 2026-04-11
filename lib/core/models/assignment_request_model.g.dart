// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignmentRequestModel _$AssignmentRequestModelFromJson(
        Map<String, dynamic> json) =>
    AssignmentRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nutritionistId: json['nutritionistId'] as String,
      status: json['status'] as String,
      createdAt:
          AssignmentRequestModel._dateTimeFromTimestamp(json['createdAt']),
    );

Map<String, dynamic> _$AssignmentRequestModelToJson(
        AssignmentRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nutritionistId': instance.nutritionistId,
      'status': instance.status,
      'createdAt':
          AssignmentRequestModel._dateTimeToTimestamp(instance.createdAt),
    };
