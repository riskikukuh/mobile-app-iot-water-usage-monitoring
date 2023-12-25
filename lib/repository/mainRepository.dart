import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/authModel.dart';
import 'package:http/http.dart';
import 'package:iot_water_monitoring/models/baseModel.dart';
import 'package:iot_water_monitoring/models/billModel.dart';
import 'package:iot_water_monitoring/models/errorModel.dart';
import 'package:iot_water_monitoring/models/historyModel.dart';
import 'package:iot_water_monitoring/models/notificationModel.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/models/waterUsageModel.dart';

class MainRepository {
  final _client = Client();
  static String host = "# Input Your Host here";
  String baseUrl = "";
  MainRepository() {
    baseUrl = "$host/api";
  }
  final _storage = const FlutterSecureStorage();
  final _xtoken_key = 'iot-user-token';

  Future<Result<String>> readToken() async {
    try {
      var token = await _storage.read(key: _xtoken_key);
      if (token == null) {
        throw Exception('Token not found!');
      }
      return Success(data: token);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<bool>> saveToken(String token) async {
    try {
      await _storage.write(key: _xtoken_key, value: token);
      return Success(data: true);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<UserModel>> getProfile(String token) async {
    try {
      var response =
          await _client.get(Uri.parse("$baseUrl/user/profile"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponse<UserModel>.fromJson(
            json.decode(response.body), UserModel.fromJson);
        return Success(data: data.data);
      } else {
        ErrorModel errorMessage =
            ErrorModel.fromJson(json.decode(response.body));
        return Failure(
            status: response.statusCode, message: errorMessage.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<bool>> postConfigurationOfficer(String token, {
    required String userId,
    int? pricePerMeter,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
      };
      if (pricePerMeter != null) {
        data["pricePerMeter"] = pricePerMeter;
      }
      var response = await _client.post(
        Uri.parse("$baseUrl/user/config"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return Success(data: true);
      } else {
        return Failure(
            status: response.statusCode,
            message: 'Failed to update configuration!');
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<bool>> postConfiguration(String token,
      {bool? tresholdSystem, int? treshold, int? pricePerMeter}) async {
    try {
      var data = {};
      if (tresholdSystem != null) {
        data['tresholdSystem'] = tresholdSystem ? "on" : "off";
      }
      if (treshold != null) {
        data["treshold"] = treshold;
      }
      if (pricePerMeter != null) {
        data["pricePerMeter"] = pricePerMeter;
      }
      var response = await _client.post(
        Uri.parse("$baseUrl/user/config"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return Success(data: true);
      } else {
        return Failure(
            status: response.statusCode,
            message: 'Failed to update configuration!');
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<AuthData>> postLogin(String email, String password) async {
    try {
      var data = jsonEncode({
        "email": email,
        "password": password,
      });
      var response = await _client.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: data,
      );
      if (response.statusCode == 200) {
        var data = ApiResponse<AuthData>.fromJson(
            json.decode(response.body), AuthData.fromJson);
        await saveToken(data.data.token);
        return Success(data: data.data);
      } else {
        ErrorModel errorMessage =
            ErrorModel.fromJson(json.decode(response.body));
        return Failure(
            status: response.statusCode, message: errorMessage.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<bool>> logout(String token) async {
    try {
      final resultToken = await readToken();
      if (resultToken is Success<String>) {
        if (token == resultToken.data) {
          final profileUserResponse = await getProfile(token);
          if (profileUserResponse is Success<UserModel>) {
            await FirebaseMessaging.instance.unsubscribeFromTopic(
                "notifications.${profileUserResponse.data.id}");
          }
          await _storage.delete(key: _xtoken_key);
          return Success(data: true);
        }
        return Failure(message: 'Failed to logout!');
      }
      return Failure(message: 'Failed to logout!');
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<WaterUsageModel>>> getTodayUsage() async {
    try {
      final tokenResult = await readToken();
      if (tokenResult is Failure) {
        throw Exception((tokenResult as Failure).message);
      }
      final token = (tokenResult as Success<String>).data;
      var response =
          await _client.get(Uri.parse("$baseUrl/waterUsage/today"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final dataUsages = json.decode(response.body);
        final data = dataUsages['data'];
        final result = (data as List<dynamic>)
            .map((usage) => WaterUsageModel.fromJson(usage))
            .toList();
        return Success(data: result);
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<HistoryModel>>> getHistories(String token) async {
    try {
      var response =
          await _client.get(Uri.parse("$baseUrl/waterUsage/history"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponseList<HistoryModel>.fromJson(
            json.decode(response.body), HistoryModel.fromJson);
        return Success(data: data.data.reversed.toList());
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<BillModel>>> getBills(String token) async {
    try {
      var response = await _client.get(Uri.parse("$baseUrl/bills"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponseList<BillModel>.fromJson(
            json.decode(response.body), BillModel.fromJson);
        return Success(data: data.data.reversed.toList());
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<BillModel>>> getOfficerPaidBill(String token) async {
    try {
      var response = await _client.get(Uri.parse("$baseUrl/bills/paid"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponseList<BillModel>.fromJson(
            json.decode(response.body), BillModel.fromJson);
        return Success(data: data.data.reversed.toList());
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<BillModel>>> getOfficerUnpaidBill(String token) async {
    try {
      var response =
          await _client.get(Uri.parse("$baseUrl/bills/unpaid"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponseList<BillModel>.fromJson(
            json.decode(response.body), BillModel.fromJson);
        return Success(data: data.data.reversed.toList());
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<bool>> postOfficerPayBill(
      String token, String billId, String status) async {
    try {
      final data = {
        "bill_id": billId,
        "status": status,
      };
      final response = await _client.post(
        Uri.parse("$baseUrl/bills/pay"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return Success(data: true);
      } else {
        return Failure(message: 'Failed to pay bill!');
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<NotificationModel>>> getNotifications(String token) async {
    try {
      var response =
          await _client.get(Uri.parse("$baseUrl/notifications"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = ApiResponseList<NotificationModel>.fromJson(
            json.decode(response.body), NotificationModel.fromJson);
        return Success(data: data.data);
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<void>> readNotification(
      String token, String notificationId) async {
    try {
      var response = await _client.post(
          Uri.parse("$baseUrl/notifications/read/$notificationId"),
          headers: {
            'Authorization': 'Bearer $token',
          });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          return Success(data: null);
        } else {
          return Failure(status: 400, message: 'Failed to read notifications');
        }
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<void>> readAllNotification(String token) async {
    try {
      var response =
          await _client.post(Uri.parse("$baseUrl/notifications/read"), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          return Success(data: null);
        } else {
          return Failure(
              status: 400, message: 'Failed to read all notifications');
        }
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  Future<Result<List<UserModel>>> getOfficerUsers(String token) async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/users"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var data = ApiResponseList<UserModel>.fromJson(
            json.decode(response.body), UserModel.fromJson);
        return Success(data: data.data);
      } else {
        ErrorModel message = ErrorModel.fromJson(json.decode(response.body));
        return Failure(status: response.statusCode, message: message.message);
      }
    } catch (e) {
      print(e.toString());
      return Failure(message: e.toString());
    }
  }
}
