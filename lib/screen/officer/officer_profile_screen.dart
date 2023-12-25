import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/config/util.dart';
import 'package:iot_water_monitoring/models/historyModel.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';

class OfficerProfileScreen extends StatefulWidget {
  const OfficerProfileScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _OfficerProfileScreenState createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  final repository = MainRepository();
  UserModel? _profile;
  final numberFormat = NumberFormat("#,##0");

  Future<UserModel?> _getProfile() async {
    final profileResponse = await repository.getProfile(widget.token);
    if (profileResponse is Success<UserModel>) {
      return profileResponse.data;
    }
    return null;
  }

  getData() async {
    UserModel? tempProfile = await _getProfile();
    setState(() {
      if (tempProfile != null) {
        _profile = tempProfile;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile failed to load!')));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            child: Icon(
              Icons.person,
              size: 68,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: Text('Firstname'),
              subtitle: Text(
                _profile?.firstname ?? "Unknown",
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              title: Text('Lastname'),
              subtitle: Text(
                _profile?.lastname ?? "Unknown",
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              title: Text('Email'),
              subtitle: Text(
                _profile?.email ?? "Unknown",
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              title: Text('Address'),
              subtitle: Text(
                _profile?.address ?? "Unknown",
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              title: Text('Role'),
              subtitle: Text(
                _profile?.role ?? "Unknown",
              ),
            ),
          ),
          const SizedBox(height: 4),          
          MaterialButton(
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.red,
            onPressed: () async {
              final logoutResponse = await repository.logout(widget.token);
              if (logoutResponse is Success<bool>) {
                Future.microtask(() => Util.showSnackbar(context, "Logout berhasil!"));
                Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen()),
                    (route) => false));
              }
            },
          ),
        ],
      ),
    );
  }
}
