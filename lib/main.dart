import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  print("NotificationBackground: ${notification?.title}");
  flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel!.id, channel!.name,
                    icon: 'launch_background')));
}

AndroidNotificationChannel? channel;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (true) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin != null
        ? await flutterLocalNotificationsPlugin!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel!)
        : print('ERROR');

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    flutterLocalNotificationsPlugin?.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel!.id, channel!.name,
                    icon: 'launch_background')));
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel!.id, channel!.name,
                    icon: 'launch_background')));
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      print(event);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel!.id, channel!.name,
                    icon: 'launch_background')));
      }
    });
    getToken();
    super.initState();
  }

  getToken() async {
    print("Token: ${await FirebaseMessaging.instance.getToken()}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Usage Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
