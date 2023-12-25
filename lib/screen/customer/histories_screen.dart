import 'package:flutter/material.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/historyModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';

class HistoriesScreen extends StatefulWidget {
  const HistoriesScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _HistoriesScreenState createState() => _HistoriesScreenState();
}

class _HistoriesScreenState extends State<HistoriesScreen> {
  final repository = MainRepository();
  final List<HistoryModel> _history = [];

  Future<List<HistoryModel>> _getHistory() async {
    final List<HistoryModel> result = [];

    final historiesResponse = await repository.getHistories(widget.token);
    if (historiesResponse is Success<List<HistoryModel>>) {
      result.addAll(historiesResponse.data);
    }
    return result;
  }

  getData() async {
    List<HistoryModel> temp = await _getHistory();
    setState(() {
      _history.clear();
      _history.addAll(temp);
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
      child: _history.isNotEmpty ? ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        itemBuilder: (context, i) {
          final data = _history[i];
          return Card(
            child: ListTile(
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
                    data.simpleDateHistory,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                "${data.waterUsage.toStringAsFixed(8)} ${data.unit}³",
              ),
              trailing: Text(
                "Rp ${data.idrFormat}",
              ),
            ),
          );
        },
        separatorBuilder: (context, i) {
          return const SizedBox(height: 10);
        },
        itemCount: _history.length,
      ) : const Text('History usage is empty!'),
    );
  }
}
