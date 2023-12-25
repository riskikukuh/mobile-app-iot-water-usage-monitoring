import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/billModel.dart';
import 'package:iot_water_monitoring/models/historyModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final repository = MainRepository();
  final List<BillModel> _bills = [];

  Future<List<BillModel>> _getBills() async {
    final List<BillModel> result = [];

    final billsResponse = await repository.getBills(widget.token);
    if (billsResponse is Success<List<BillModel>>) {
      result.addAll(billsResponse.data.reversed);
    }
    return result;
  }

  getData() async {
    List<BillModel> temp = await _getBills();
    setState(() {
      _bills.clear();
      _bills.addAll(temp);
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
      child: _bills.isNotEmpty ? ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        itemBuilder: (context, i) {
          final data = _bills[i];
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(4)),
                    color: data.status == 'UNPAID'
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                  child: Text(
                    data.paidAt != null
                        ? "${data.status} - ${data.simplePaidAt}"
                        : data.status,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                // const SizedBox(height: 4),
                ListTile(
                  leading: const Icon(
                    Icons.water_drop,
                    color: Colors.yellow,
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Per Meter: Rp${data.convertedPricePerMeter}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.simpleDateBill,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "${data.waterUsage} ${data.unit}³",
                  ),
                  trailing: Text(
                    "Rp ${data.idrFormat}",
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, i) {
          return const SizedBox(height: 10);
        },
        itemCount: _bills.length,
      ) : const Text("Bills is empty!"),
    );
  }
}
