import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/billModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/screen/officer/payment_bill_screen.dart';

class UnpaidBillScreen extends StatefulWidget {
  final String token;
  const UnpaidBillScreen({super.key, required this.token});

  @override
  State<UnpaidBillScreen> createState() => _UnpaidBillScreenState();
}

class _UnpaidBillScreenState extends State<UnpaidBillScreen> {
  final repository = MainRepository();
  final List<BillModel> _bills = [];

  Future<List<BillModel>> _getUnpaidBills() async {
    final List<BillModel> result = [];

    final unpaidBillResponse =
        await repository.getOfficerUnpaidBill(widget.token);
    if (unpaidBillResponse is Success<List<BillModel>>) {
      result.addAll(unpaidBillResponse.data);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    List<BillModel> temp = await _getUnpaidBills();
    setState(() {
      _bills.clear();
      _bills.addAll(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: _bills.isNotEmpty ? ListView.separated(
        itemCount: _bills.length,
        itemBuilder: (context, i) {
          final data = _bills[i];
          return InkWell(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PaymentBillScreen(bill: data, token: widget.token)));
              getData();
            },
            child: Card(
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
                      data.status,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.simpleDateBill,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${data.waterUsage} ${data.unit}",
                    ),
                    trailing: Text(
                      "Rp ${data.idrFormat}",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama : ${data.owner?.firstname}"),
                        Text("Alamat: ${data.owner?.address}"),
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
      ) : const Text("Unpaid Bill is empty!"),
    );
  }
}
