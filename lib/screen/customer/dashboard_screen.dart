import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_water_monitoring/config/result.dart';
import 'package:iot_water_monitoring/models/updateUsageModel.dart';
import 'package:iot_water_monitoring/models/userModel.dart';
import 'package:iot_water_monitoring/models/waterUsageModel.dart';
import 'package:iot_water_monitoring/repository/mainRepository.dart';
import 'package:iot_water_monitoring/util/streamSocket.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _maxUsage = 1;
  int _endDate = 0;
  UserModel? _user;
  final repository = MainRepository();
  final streamSocket = StreamSocket();
  var _isLoading = true;
  final List<WaterUsageModel> todayUsages = [];
  io.Socket? socket;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  void connectAndListen() async {
    socket = io.io(
        '${MainRepository.host}/updateWaterUsage',
        io.OptionBuilder()
            .setPath('/updateWaterUsage')
            .enableForceNew()
            .setTransports(['websocket']).setExtraHeaders(
                {'X-Authorization': widget.token}).build());

    socket?.onConnect((_) {
      print('# User Connecting socket server');
    });

    //When an event recieved from server, data is added to the stream
    socket?.on('updateUsages', (data) {
      print(data);
      final updateModel = UpdateUsageModel.fromJson(data);
      streamSocket.addResponse(updateModel);
      // final lastUsage = todayUsages.last;
      final lastUsage = todayUsages.first;
      if (lastUsage.startDate != null &&
          lastUsage.endDate != null &&
          updateModel.usageAt != null) {
        if (updateModel.usageAt! >= lastUsage.startDate! &&
            updateModel.usageAt! <= lastUsage.endDate!) {
          setState(() {
            todayUsages.removeAt(0);
            lastUsage.usage = lastUsage.usage! + updateModel.usage!;
            if (lastUsage.usage! > _maxUsage) {
              _maxUsage = lastUsage.usage!;
              if (_maxUsage < 1) {
                _maxUsage = 1;
              } 
              
            }
            _endDate = lastUsage.endDate!;
            todayUsages.insert(0, lastUsage);

            final tempLastChartData = chartDatas.last;
            chartDatas.removeLast();
            chartDatas.add(FlSpot(tempLastChartData.x,
                tempLastChartData.y + updateModel.usage!.toDouble()));
          });
        } else {
          setState(() {
            final newData = WaterUsageModel(
              startDate: lastUsage.endDate,
              endDate: lastUsage.endDate! +
                  (lastUsage.endDate! - lastUsage.startDate!),
              unit: lastUsage.unit,
              usage: updateModel.usage,
            );
            String simpleStartDate = dateFormatTodayUsage.format(
                DateTime.fromMillisecondsSinceEpoch(newData.startDate!));
            String simpleEndDate = dateFormatTodayUsage
                .format(DateTime.fromMillisecondsSinceEpoch(newData.endDate!));
            newData.simpleStartDate = simpleStartDate;
            newData.simpleEndDate = simpleEndDate;
            todayUsages.insert(0, newData);
            if (updateModel.usage! > _maxUsage) {
              _maxUsage = updateModel.usage!;
              if (_maxUsage < 1) {
                _maxUsage = 1;
              }
            }
            _endDate = lastUsage.endDate! +
                (lastUsage.endDate! - lastUsage.startDate!);

            chartDatas.clear();
            final temp = todayUsages
                .getRange(0, todayUsages.length > 10 ? 10 : todayUsages.length)
                .toList()
                .reversed
                .toList();
            for (var i = 0; i < temp.length; i++) {
              chartDatas
                  .add(FlSpot(i.toDouble(), temp[i].usage?.toDouble() ?? 0));
            }
          });
        }
      }
    });
    socket?.on('error', (data) {
      print("# on Error: $data");
    });
    socket?.onDisconnect((_) => print('# User disconnected'));
    socket?.onError((data) => print("# Got error: $data"));

    socket?.connect();
  }

  void getData() async {
    connectAndListen();
    var response = await repository.getTodayUsage();
    final responseUserProfile = await repository.getProfile(widget.token);
    if (response is Success<List<WaterUsageModel>>) {
      setState(() {
        todayUsages.clear();
        todayUsages.addAll(response.data);
        _endDate = todayUsages.first.endDate!;
      });
      List<double> usages = [];
      for (var usage in response.data) {
        usages.add(usage.usage ?? 0);
      }
      usages.sort();
      setState(() {
        _maxUsage = usages.last;
        if (_maxUsage < 1) {
          _maxUsage = 1;
        }
      });
    }

    if (responseUserProfile is Success<UserModel>) {
      setState(() {
        _user = responseUserProfile.data;
      });
    }

    setState(() {
      chartDatas.clear();
      final temp = todayUsages
          .getRange(0, todayUsages.length > 10 ? 10 : todayUsages.length)
          .toList()
          .reversed
          .toList();
      for (var i = 0; i < temp.length; i++) {
        chartDatas.add(FlSpot(i.toDouble(), temp[i].usage?.toDouble() ?? 0));
      }
      _isLoading = false;
    });
  }

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  DateFormat dateFormat = DateFormat("mm:ss");
  DateFormat dateFormatTodayUsage = DateFormat("HH:mm:ss");

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    int valueAsInt = value.toInt();

    List<double> threeDatas = chartDatas.map((data) => data.x).toList();

    if (threeDatas.contains(valueAsInt)) {
      final temp = todayUsages
          .getRange(0, chartDatas.length)
          .toList()
          .reversed
          .toList()[valueAsInt]
          .startDate;
      text =
          Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(temp!)));
    } else {
      text = const Text('');
    }
    return SideTitleWidget(
      angle: 1.53,
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    print(value);
    if (value == 0.0) {
      text = '0 meter';
    } else if (value == _maxUsage / 2) {
      text = "${_maxUsage / 2} meter";
    } else if (value == 0.2) {
      text = "0.2 meter";
    } else if (value == 0.7) {
      text = "0.7 meter";
    } else if (value > 0.9 && value < 1) {
      text = "0.9 meter";
    } else {
    // } else if (value == _maxUsage) {
    //   text = "$_maxUsage meter";
    // } else {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  List<FlSpot> chartDatas = [];

  Widget _myChart() {
    return StreamBuilder(
      stream: streamSocket.getResponse,
      builder: (context, snapshot) {
        return SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: true),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                verticalInterval: 1,
                horizontalInterval: 1,
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: bottomTitleWidgets,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: leftTitleWidgets,
                    reservedSize: 42,
                    interval: .1,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: chartDatas.length - 1,
              minY: 0,
              maxY: _maxUsage.toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: chartDatas,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 5,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        ColorTween(
                                begin: gradientColors[0],
                                end: gradientColors[1])
                            .lerp(0.2)!
                            .withOpacity(0.1),
                        ColorTween(
                                begin: gradientColors[0],
                                end: gradientColors[1])
                            .lerp(0.2)!
                            .withOpacity(0.1),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: !_isLoading
              ? Column(
                  children: [
                    const Text(
                      "Statistics usages",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${DateFormat("dd MMMM yyyy, hh:mm:ss").format(DateTime.now())}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    _myChart(),
                    const SizedBox(height: 14),
                    Card(
                      child: ListTile(
                        title: const Text(
                          "This Month Usage",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          "${_user?.monthlyUsage?.toStringAsFixed(10) ?? 0} meter³",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: todayUsages.length,
                      itemBuilder: (context, i) {
                        final usage = todayUsages[i];
                        return Card(
                          child: ListTile(
                            title: Row(children: [
                              Text(usage.simpleStartDate),
                              const Text(" - "),
                              Text(usage.simpleEndDate),
                            ]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                usage.usage?.toStringAsFixed(4) ?? "0",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(" "),
                              Text(
                                usage.unit.toString() + (usage.unit.toString() == 'meter' ? "³" : ""),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                    // FutureBuilder(
                    //   future: repository.getTodayUsage(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.hasData) {
                    //       final data = snapshot.data;
                    //       if (data is Success<List<WaterUsageModel>>) {
                    //         final usages = data.data;
                    //         return
                    //       } else {
                    //         return const Text(
                    //             "Gagal mengambil data pemakaian hari ini, silahkan coba lagi nanti");
                    //       }
                    //     } else {
                    //       return Center(
                    //         child: CircularProgressIndicator(),
                    //       );
                    //     }
                    //   },
                    // )
                  ],
                )
              : Column(
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
          //     child: FutureBuilder(
          //   future: repository.getTodayUsage(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       final data = snapshot.data;
          //       if (data is Success<List<WaterUsageModel>>) {
          //         final usages = data.data;
          //         return Expanded(
          //           child: Column(
          //             mainAxisSize: MainAxisSize.max,
          //             children: [
          //               Container(
          //                 child: Text("Grafik"),
          //               ),
          //               const SizedBox(height: 15),
          //               ListView.separated(
          //                 itemBuilder: (context, i) {
          //                   final usage = usages[i];
          //                   return Card(
          //                     child: Container(
          //                         child: Text("Pemakaian ${usages[i].usage}")),
          //                   );
          //                 },
          //                 separatorBuilder: (context, i) {
          //                   return const SizedBox(height: 15);
          //                 },
          //                 itemCount: usages.length,
          //               ),
          //             ],
          //           ),
          //         );
          //       } else {
          //         return const Text(
          //             "Gagal mengambil data pemakaian hari ini, silahkan coba lagi nanti");
          //       }
          //     }
          //     return const CircularProgressIndicator();
          //   },
          // )),
        ));
  }
}
