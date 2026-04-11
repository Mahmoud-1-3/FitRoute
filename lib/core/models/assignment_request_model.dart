import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_request_model.g.dart';

@JsonSerializable()
class AssignmentRequestModel {
  final String id;
  final String userId;
  final String nutritionistId;
  final String status;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  const AssignmentRequestModel({
    required this.id,
    required this.userId,
    required this.nutritionistId,
    required this.status,
    required this.createdAt,
  });

  factory AssignmentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentRequestModelToJson(this);

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _dateTimeToTimestamp(DateTime date) => FieldValue.serverTimestamp();
}
