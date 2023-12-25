import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/notificationModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';
import 'package:iot_water_monitoring/util/custom_type.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final repository = MainRepository();
  final List<NotificationModel> _notifications = [];
  String _token = "";

  Future<List<NotificationModel>> _getNotifications() async {
    var tokenResponse = await repository.readToken();
    if (tokenResponse is Failure) {
      Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false));
      return [];
    } else {
      final List<NotificationModel> result = [];
      _token = (tokenResponse as Success<String>).data;
      final notificationReponse = await repository.getNotifications(_token);
      if (notificationReponse is Success<List<NotificationModel>>) {
        result.addAll(notificationReponse.data.reversed);
      }
      return result;
    }
  }

  getData() async {
    List<NotificationModel> temp = await _getNotifications();
    setState(() {
      _notifications.clear();
      _notifications.addAll(temp);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          MaterialButton(
            onPressed: () {
              if (_token.isNotEmpty) {
                repository.readAllNotification(_token);
                getData();
              }
            },
            child: const Text(
              "Read All",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemBuilder: (context, i) {
            final data = _notifications[i];
            return InkWell(
              onTap: () async {
                if (_token.isNotEmpty) {
                  final response = await repository.readNotification(_token, data.id);
                  if (response is Success<void>) {
                    setState(() {
                      data.readOn = DateTime.now().millisecondsSinceEpoch;
                    });
                  }
                }
              },
              child: Card(
                color: data.readOn == 0 ? const Color(0xFFe0e0e0) : Colors.white,
                child: ListTile(
                  leading: data.type == NotificationType.alert.value
                      ? const Icon(
                          Icons.dangerous,
                          color: Colors.redAccent,
                        )
                      : const Icon(
                          Icons.warning,
                          color: Colors.yellow,
                        ),
                  title: Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "[${data.simpleCreatedAt}] - ${data.description}",
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, i) {
            return const SizedBox(height: 10);
          },
          itemCount: _notifications.length,
        ),
      ),
    );
  }
}
