class ErrorModel {
  bool? success;
  int? status;
  late String message;

  ErrorModel({this.success, this.status, this.message = "Something went wrong, please try again!"});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    message = json['message'] ?? "Something went wrong, please try again!";
  }
}
