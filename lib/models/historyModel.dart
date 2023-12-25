import 'package:intl/intl.dart';

class HistoryModel {
  late String id;
  late String userId;
  late double waterUsage;
  late String unit;
  late int startDate = 0;
  late int endDate = 0;
  late int nominal;
  late int pricePerMeter;
  late String convertedPricePerMeter;
  late int createdAt;

  HistoryModel({
    required this.id, 
    required this.userId, 
    required this.waterUsage, 
    required this.unit,
    required this.startDate,
    required this.endDate,
    required this.nominal,
    required this.pricePerMeter,
    required this.createdAt,
  });

  DateTime? convertedStartDate;
  DateTime? convertedEndDate;

  String simpleStartDate = "";
  String simpleEndDate = "";

  DateFormat dateFormat = DateFormat("HH:mm:ss");

  String simpleDateHistory = "";

  String idrFormat = "";


  HistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    userId = json['user_id'] as String;
    waterUsage = double.parse(json['water_usage'].toString());
    unit = json['unit'] as String;
    startDate = json['start_date'] as int;
    endDate = json['end_date'] as int;
    nominal = json['nominal'] as int;
    pricePerMeter = json['price_per_meter'] as int;
    createdAt = json['created_at'] as int;

    idrFormat = NumberFormat("#,##0").format(nominal);

    convertedStartDate = DateTime.fromMillisecondsSinceEpoch(startDate);
    convertedEndDate = DateTime.fromMillisecondsSinceEpoch(endDate);
    convertedPricePerMeter = NumberFormat("#,##0").format(pricePerMeter);
    
    // simpleDateHistory = DateFormat("").format(convertedStartDate!);
    simpleDateHistory = "${DateFormat.EEEE().format(convertedStartDate!)}, ${DateFormat.d().format(convertedStartDate!)} ${DateFormat.MMMM().format(convertedStartDate!)} ${DateFormat.y().format(convertedStartDate!)}";
    simpleStartDate = dateFormat.format(convertedStartDate!);
    simpleEndDate = dateFormat.format(convertedEndDate!);
  }
}
