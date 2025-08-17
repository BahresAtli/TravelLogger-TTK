import 'package:ttkapp/core/data/object_base.dart';

class MainTable extends ObjectBase {
  late int recordID;
  late DateTime? startTime;
  late DateTime? endTime;
  late int? elapsedMilisecs;
  late double? distance;
  late double? startLatitude;
  late double? startLongitude;
  late double? startAltitude;
  late double? endLatitude;
  late double? endLongitude;
  late double? endAltitude;
  late String? label;
  late TravelType? travelType;

  MainTable() {
    recordID = 0;
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
