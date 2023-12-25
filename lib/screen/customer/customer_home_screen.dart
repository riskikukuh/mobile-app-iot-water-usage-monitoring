import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/customer/bills_screen.dart';
import 'package:iot_water_monitoring/screen/customer/dashboard_screen.dart';
import 'package:iot_water_monitoring/screen/customer/histories_screen.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';
import 'package:iot_water_monitoring/screen/notifications_screen.dart';
import 'package:iot_water_monitoring/screen/customer/customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final repository = MainRepository();

  var _index = 0;
  var titles = ["Today Usage", "Histories", "Bills", "Profiles"];
  final List<Widget> screens = [
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
      ],
    )
  ];

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  checkToken() async {
    final tokenResult = await repository.readToken();
    if (tokenResult is Failure<String>) {
      Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginScreen()),
          (route) => false));
      return;
    }
    final token = (tokenResult as Success<String>).data;
    setState(() {
      screens.clear();
      screens.add(DashboardScreen(token: token));
      screens.add(HistoriesScreen(token: token));
      screens.add(BillsScreen(token: token));
      screens.add(CustomerProfileScreen(token: token));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.water_drop),
          title: const Text("Water Monitoring"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationScreen()));
              },
              icon: const Icon(Icons.notifications),
            ),
          ],
        ),
        body: screens[_index],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (i) {
            setState(() {
              _index = i;
            });
          },
          currentIndex: _index,
          unselectedItemColor: Colors.blueGrey,
          selectedItemColor: Colors.blue,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: 'Today Usage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Hiistories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_outlined),
              label: 'Bills',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_rounded),
              label: 'Settings',
            ),
          ],
        ),
        // bottomNavigationBar: AnimatedBottomNavigationBar(icons: icons, activeIndex: activeIndex, onTap: onTap),
      ),
    );
  }
}
