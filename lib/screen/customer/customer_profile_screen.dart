import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/config/util.dart';
import 'package:iot_water_monitoring/models/historyModel.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/login_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final repository = MainRepository();
  UserModel? _profile;
  final numberFormat = NumberFormat("#,##0");

  final tresholdControlller = TextEditingController();

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
        tresholdControlller.value =
            TextEditingValue(text: _profile?.treshold.toString() ?? "0");
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
          Card(
            child: ListTile(
              onTap: () {
                
              },
              title: Text('Price Per Meter'),
              subtitle: Text(
                "Rp ${numberFormat.format(_profile?.pricePerMeter ?? 0)}",
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              title: const Text('Treshold System'),
              subtitle: const Text(
                "Treshold water usage in 1 month",
              ),
              trailing: Switch(
                value: _profile?.tresholdSystem ?? false,
                onChanged: (value) async {
                  await repository.postConfiguration(
                    widget.token,
                    tresholdSystem: value,
                  );
                  setState(() {
                    _profile?.tresholdSystem = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12,
                            MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "New Treshold Value",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              autofocus: true,
                              controller: tresholdControlller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                suffix: Text('Meter³'),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    child: const Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      await repository.postConfiguration(
                                        widget.token,
                                        treshold: int.parse(
                                            tresholdControlller.value.text),
                                      );
                                      setState(() {
                                        _profile?.treshold = int.parse(
                                            tresholdControlller.value.text);
                                      });
                                      Future.microtask(
                                          () => Navigator.of(context).pop());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              },
              enabled: _profile?.tresholdSystem ?? true,
              title: const Text('Treshold Value'),
              subtitle: Text(
                "${_profile?.treshold ?? 0} Meter³",
              ),
            ),
          ),
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
