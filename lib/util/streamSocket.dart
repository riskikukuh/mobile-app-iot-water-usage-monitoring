import 'dart:async';

import 'package:iot_water_monitoring/models/updateUsageModel.dart';

class StreamSocket {
  final _socketResponse = StreamController<UpdateUsageModel>();

  void Function(UpdateUsageModel) get addResponse => _socketResponse.sink.add;

  Stream<UpdateUsageModel> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
