import 'package:intl/intl.dart';

class UpdateUsageModel {
  late double? usage = 0;
  late String? unit = "";
  late int? usageAt = 0;

  DateFormat dateFormat = DateFormat("HH:mm:ss");

  UpdateUsageModel({this.usage, this.unit, this.usageAt});

  UpdateUsageModel.fromJson(Map<String, dynamic> json) {
    usage = double.parse(json['usage'].toString());
    unit = json['unit'] as String;
    usageAt = json['usage_at'] as int;
  }
}
