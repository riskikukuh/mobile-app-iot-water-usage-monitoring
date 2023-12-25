import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';
import 'package:iot_water_monitoring/screen/notifications_screen.dart';
import 'package:iot_water_monitoring/screen/officer/officer_profile_screen.dart';
import 'package:iot_water_monitoring/screen/officer/paid_bill_screen.dart';
import 'package:iot_water_monitoring/screen/officer/unpaid_bill_screen.dart';
import 'package:iot_water_monitoring/screen/officer/users_screen.dart';

class OfficerHomeScreen extends StatefulWidget {
  const OfficerHomeScreen({Key? key}) : super(key: key);

  @override
  _OfficerHomeScreenState createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen> {
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
      screens.add(UnpaidBillScreen(token: token));
      screens.add(PaidBillScreen(token: token));
      screens.add(UsersScreen(token: token));
      screens.add(OfficerProfileScreen(token: token));
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
            // Stack(
            //   children: [
            //     IconButton(
            //         onPressed: () {
            //           Navigator.of(context).push(MaterialPageRoute(
            //               builder: (context) => NotificationScreen()));
            //         },
            //         icon: const Icon(Icons.notifications)),
            // Container(
            //   decoration:
            //       BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            //   padding: const EdgeInsetsDirectional.all(6),
            //   child: Text(
            //     "2",
            //     style: TextStyle(
            //       fontSize: 10,
            //     ),
            //   ),
            // ),
            //     ],
            //   )
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
              label: 'Unpaid Bill',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Paid Bill',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_sharp),
              label: 'Users',
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
