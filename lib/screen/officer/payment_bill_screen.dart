import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/billModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';

class PaymentBillScreen extends StatefulWidget {
  final BillModel bill;
  final String token;
  const PaymentBillScreen({
    Key? key,
    required this.bill,
    required this.token,
  }) : super(key: key);

  @override
  _PaymentBillScreenState createState() => _PaymentBillScreenState();
}

class _PaymentBillScreenState extends State<PaymentBillScreen> {
  final repository = MainRepository();
  String payStatus = "UNPAID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text("BIll ID"),
                    subtitle: Text(widget.bill.id),
                  ),
                  ListTile(
                    title: Text("Status"),
                    subtitle: Text(widget.bill.status),
                  ),
                  ListTile(
                    title: Text("Start Usage"),
                    subtitle: Text(widget.bill.simpleStartDate),
                  ),
                  ListTile(
                    title: Text("End Usage"),
                    subtitle: Text(widget.bill.simpleEndDate),
                  ),
                  ListTile(
                    title: Text("Usage"),
                    subtitle:
                        Text("${widget.bill.waterUsage} ${widget.bill.unit}"),
                  ),
                  ListTile(
                    title: Text("Price"),
                    subtitle: Text("Rp ${widget.bill.idrFormat}"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        "PAY",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        final response = await repository.postOfficerPayBill(
                            widget.token, widget.bill.id, "PAID");
                        if (response is Success<bool>) {
                          if (response.data) {
                            Future.microtask(() => Navigator.of(context).pop());
                            Future.microtask(() => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Pembayaran berhasil!'))));
                          } else {
                            Future.microtask(() => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Pembayaran tidak berhasil, silahkan coba kembali!'))));
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
