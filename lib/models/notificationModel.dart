import 'package:intl/intl.dart';

class NotificationModel {
  late String id;
  late String userId;
  late String title;
  late String description;
  late String type;
  late int readOn;
  late String messageId;
  late int createdAt;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String simpleCreatedAt = "";

  NotificationModel({
    required this.id, 
    required this.userId, 
    required this.title, 
    required this.description,
    required this.type,
    required this.readOn,
    required this.messageId,
    required this.createdAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    userId = json['user_id'] as String;
    title = json['title'] as String;
    description = json['description'] as String;
    type = json['type'] as String;
    readOn = json['read_on'] as int;
    messageId = json['message_id'] as String;
    createdAt = (json['created_at'] as int?) ?? 0;
    
    simpleCreatedAt = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(createdAt));
  }
}
