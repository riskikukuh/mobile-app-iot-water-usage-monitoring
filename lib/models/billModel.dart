import 'package:intl/intl.dart';
import 'package:iot_water_monitoring/models/ownerBillModel.dart';

class BillModel {
  late String id;
  late int waterUsage;
  late String unit;
  late int startDate = 0;
  late int endDate = 0;
  late int nominal;
  late int pricePerMeter;
  late int createdAt;
  late int? paidAt;
  late String status;
  late String convertedPricePerMeter;

  late OwnerBillModel? owner;

  BillModel({
    required this.id, 
    required this.waterUsage, 
    required this.unit,
    required this.startDate,
    required this.endDate,
    required this.nominal,
    required this.pricePerMeter,
    required this.createdAt,
    required this.status,
  });

  DateTime? convertedStartDate;
  DateTime? convertedEndDate;

  DateTime? convertedMonth;

  String simpleStartDate = "";
  String simpleEndDate = "";

  DateFormat dateFormat = DateFormat("dd MMMM yyyy");

  String simpleDateBill = "";
  String simplePaidAt = "";
  DateTime? paidAtDate;

  String idrFormat = "";

  BillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    // userId = json['user_id'] as String;
    waterUsage = json['water_usage'] as int;
    unit = json['unit'] as String;
    startDate = json['start_date'] as int;
    endDate = json['end_date'] as int;
    nominal = json['nominal'] as int;
    pricePerMeter = json['price_per_meter'] as int;
    createdAt = json['created_at'] as int;
    status = json['status'] as String;

    idrFormat = NumberFormat("#,##0").format(nominal);

    convertedStartDate = DateTime.fromMillisecondsSinceEpoch(startDate);
    convertedEndDate = DateTime.fromMillisecondsSinceEpoch(endDate);
    convertedMonth = convertedStartDate!.add(const Duration(days: 14));

    convertedPricePerMeter = NumberFormat("#,##0").format(pricePerMeter);
    
    paidAt = json['paid_at'] as int?;
    // simpleDateHistory = DateFormat("").format(convertedStartDate!);
    simpleDateBill = "${DateFormat.MMMM().format(convertedStartDate!)} ${DateFormat.y().format(convertedStartDate!)}";
    if (paidAt != null) {
      paidAtDate = DateTime.fromMillisecondsSinceEpoch(paidAt!);
      simplePaidAt = DateFormat('hh:mm:ss dd MMMM yyyy').format(paidAtDate!);
    }
    
    simpleStartDate = dateFormat.format(convertedStartDate!);
    simpleEndDate = dateFormat.format(convertedEndDate!);
    
    if (json['user'] != null) {
      owner = OwnerBillModel.fromJson(json['user']);
    }
  }
}
