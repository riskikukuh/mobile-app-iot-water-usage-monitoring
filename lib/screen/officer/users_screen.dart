import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';

class UsersScreen extends StatefulWidget {
  final String token;
  const UsersScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final repository = MainRepository();
  final List<UserModel> _users = [];

  final pricePerMeterController = TextEditingController();

  Future<List<UserModel>> _getUsers() async {
    final List<UserModel> result = [];

    final usersResponse = await repository.getOfficerUsers(widget.token);
    if (usersResponse is Success<List<UserModel>>) {
      result.addAll(usersResponse.data);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    List<UserModel> temp = await _getUsers();
    setState(() {
      _users.clear();
      _users.addAll(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: _users.isNotEmpty
          ? ListView.separated(
              itemCount: _users.length,
              itemBuilder: (context, i) {
                final data = _users[i];
                return InkWell(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4)),
                            color:
                                data.isActive ? Colors.green : Colors.redAccent,
                          ),
                          child: Text(
                            data.isActive ? 'ACTIVE' : 'NOT ACTIVE',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.yellow,
                          ),
                          title: Text(
                            data.firstname,
                            style: TextStyle(),
                          ),
                          // subtitle: Text(
                          //   data.address,
                          // ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.address,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${data.pricePerMeter} / meter",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Treshold System ${data.tresholdSystem ? 'Active' : 'Not Active'}",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Treshold ${data.treshold}",
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'editPricePerMeter') {
                                pricePerMeterController.value =
                                    TextEditingValue(
                                        text: data.pricePerMeter.toString());
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            12,
                                            12,
                                            12,
                                            MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "New Price Per Meter",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              autofocus: true,
                                              controller:
                                                  pricePerMeterController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                suffix: Text('Meter'),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MaterialButton(
                                                    child: Text(
                                                      "Save",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    color: Colors.blue,
                                                    onPressed: () async {
                                                      await repository
                                                          .postConfigurationOfficer(
                                                        widget.token,
                                                        userId: data.id,
                                                        pricePerMeter: int.parse(
                                                            pricePerMeterController
                                                                .value.text),
                                                      );
                                                      setState(() {
                                                        data.pricePerMeter =
                                                            int.parse(
                                                                pricePerMeterController
                                                                    .value
                                                                    .text);
                                                      });
                                                      Future.microtask(() =>
                                                          Navigator.of(context)
                                                              .pop());
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'editPricePerMeter',
                                child: Text('Edit Price Per Meter'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text("Nama : ${data.owner?.firstname}"),
                              // Text("Alamat: ${data.owner?.address}"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, i) {
                return const SizedBox(height: 10);
              },
            )
          : const Text("Users is empty!"),
    );
  }
}
