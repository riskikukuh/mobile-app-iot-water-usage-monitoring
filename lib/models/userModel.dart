class UserModel {
  late String id;
  late String email;
  late String firstname;
  late String lastname;
  late String address;
  late int latitude;
  late int longitude;
  late String role;
  late bool tresholdSystem;
  late int treshold;
  late int pricePerMeter;
  late bool isActive;
  late int createdAt;
  late double? monthlyUsage;

  UserModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.role,
    required this.tresholdSystem,
    required this.treshold,
    required this.pricePerMeter,
    required this.isActive,
    required this.createdAt,
    required this.monthlyUsage,
  });
  
  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    email = json['email'] as String;
    firstname = json['firstname'] as String;
    lastname = json['lastname'] as String;
    address = json['address'] as String;
    latitude = json['latitude'] as int;
    longitude = json['longitude'] as int;
    role = json['role'] as String;
    tresholdSystem = (json['treshold_system'] as String) == "on";
    treshold = json['treshold'] as int;
    pricePerMeter = json['price_per_meter'] as int;
    isActive = (json['is_active'] as int) == 1;
    createdAt = json['created_at'];
    if (json.containsKey('monthly_usage')) {
      monthlyUsage = double.parse(json['monthly_usage'].toString());
    }
  }
}