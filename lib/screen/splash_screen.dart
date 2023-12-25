import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/customer/customer_home_screen.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';
import 'package:iot_water_monitoring/screen/officer/officer_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    delayAndPush();
  }

  final repository = MainRepository();

  delayAndPush() async {
    var tokenResponse = await repository.readToken();
    if (tokenResponse is Failure) {
      Future.microtask(() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen())));
    } else {
      final token = (tokenResponse as Success<String>).data;
      var profileResult = await repository.getProfile(token);
      if (profileResult is Failure) {
        Future.microtask(() => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen())));
      } else {
        final data = (profileResult as Success<UserModel>);
        await FirebaseMessaging.instance
            .subscribeToTopic("notifications.${data.data.id}");
        if (data.data.role == "customer") {
          Future.microtask(() => navigateToHomeCustomer(context));
        } else {
          Future.microtask(() => navigateToHomeOfficer(context));
        }
      }
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  navigateToHomeCustomer(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()));
  }

  navigateToHomeOfficer(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OfficerHomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                    size: MediaQuery.of(context).size.width / 4,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Water Usage Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Made with ♥ by Riski Kukuh',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
