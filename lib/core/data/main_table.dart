import 'package:ttkapp/core/data/object_base.dart';

class MainTable extends ObjectBase {
  late int? recordID;
  late String? startTime;
  late String? endTime;
  late int? elapsedMilisecs;
  late double? distance;
  late String? startLatitude;
  late String? startLongitude;
  late String? startAltitude;
  late String? endLatitude;
  late String? endLongitude;
  late String? endAltitude;
  late String? label;
  late TravelType? travelType;

  MainTable() {
    distance = 0.0;
    travelType = TravelType.other;
  }

}

enum TravelType {
  bus,
  car,
  walk,
  bike,
  intercityBus,
  tram,
  metroDescent,
  metro,
  metroAscent,
  ferry,
  other,
  test,
}
