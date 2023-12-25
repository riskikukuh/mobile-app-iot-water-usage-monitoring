import 'package:intl/intl.dart';

class WaterUsageModel {
  late double? usage = 0;
  late String? unit = "";
  late int? startDate = 0;
  late int? endDate = 0;
  DateTime? convertedStartDate;
  DateTime? convertedEndDate;

  String simpleStartDate = "";
  String simpleEndDate = "";

  DateFormat dateFormat = DateFormat("HH:mm:ss");

  WaterUsageModel({this.usage, this.unit, this.startDate, this.endDate});

  WaterUsageModel.fromJson(Map<String, dynamic> json) {
    usage = double.parse(json['usage'].toString());
    unit = json['unit'] as String;
    startDate = json['startDate'] as int;
    endDate = json['endDate'] as int;

    if (startDate != null) {
      convertedStartDate = DateTime.fromMillisecondsSinceEpoch(startDate!);
    }
    if (endDate != null) {
      convertedEndDate = DateTime.fromMillisecondsSinceEpoch(endDate!);
    }
    if (convertedStartDate != null) {
      simpleStartDate = dateFormat.format(convertedStartDate!);
    }
    if (convertedEndDate != null) {
      simpleEndDate = dateFormat.format(convertedEndDate!);
    }
  }
}
