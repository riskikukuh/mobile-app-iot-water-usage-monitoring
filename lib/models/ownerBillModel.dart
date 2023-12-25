class OwnerBillModel {
  late String id;
  late String email;
  late String firstname;
  late String address;

  OwnerBillModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.address,
  });
  
  OwnerBillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    firstname = json['firstname'] as String;
    email = json['email'] as String;
    address = json['address'] as String;
  }
}