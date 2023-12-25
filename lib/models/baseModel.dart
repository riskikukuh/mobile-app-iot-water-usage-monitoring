class ApiResponse<T> {
  bool? status;
  late T data;
  ApiResponse({this.status, required this.data});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, Function(Map<String, dynamic>) create) {
    return ApiResponse<T>(
      status: json["status"],
      data: create(json["data"]),
    );
  }
}

class ApiResponseList<T> {
  bool? status;
  late List<T> data;
  ApiResponseList({this.status, required this.data});

  factory ApiResponseList.fromJson(
      Map<String, dynamic> json, Function(Map<String, dynamic>) create) {
    return ApiResponseList<T>(
      status: json["status"],
      data: json['data'].map((item) => create(item)).toList().cast<T>(),
    );
  }
}
