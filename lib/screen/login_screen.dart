import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/config/util.dart';
import 'package:iot_water_monitoring/models/authModel.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/customer/customer_home_screen.dart';
import 'package:iot_water_monitoring/screen/officer/officer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final repository = MainRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _obsecurePassword = true;

  navigateToHomeCustomer(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()));
  }

  navigateToHomeOfficer(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OfficerHomeScreen()));
  }

  getProfile(BuildContext context, String token) async {
    final resultProfile = await repository.getProfile(token);
    if (resultProfile is Success<UserModel>) {
      await FirebaseMessaging.instance
          .subscribeToTopic("notifications.${resultProfile.data.id}");
      if (resultProfile.data.role == "customer") {
        Future.microtask(() => navigateToHomeCustomer(context));
      } else {
        Future.microtask(() => navigateToHomeOfficer(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (text) {
                        if (text != null && text.isNotEmpty) {
                          email = text;
                        }
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obsecurePassword = !_obsecurePassword;
                                });
                              },
                              icon: Icon(_obsecurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      onSaved: (text) {
                        if (text != null && text.isNotEmpty) {
                          password = text;
                        }
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                      obscureText: _obsecurePassword,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FormState? state = _formKey.currentState;
                              state?.save();
                              if (state != null &&
                                  state.validate() &&
                                  email.isNotEmpty &&
                                  password.isNotEmpty) {
                                final loginResponse =
                                    await repository.postLogin(email, password);
                                if (loginResponse is Success<AuthData>) {
                                  Future.microtask(() => Util.showSnackbar(context, "Login Berhasil!"));
                                  Future.microtask(() => getProfile(
                                      context, loginResponse.data.token));
                                } else {
                                  final message =
                                      (loginResponse as Failure).message;
                                  Future.microtask(() =>
                                      Util.showSnackbar(context, message));
                                }
                              } else {
                                Util.showSnackbar(context,
                                    'Form login harus diisi dengan lengkap');
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}