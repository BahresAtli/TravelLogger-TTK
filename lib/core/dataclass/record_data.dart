import 'package:ttkapp/core/dataclass/base/object_base.dart';

class RecordData extends ObjectBase {
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

  RecordData() {
    recordID = 0;
    startTime = null;
    endTime = null;
    elapsedMilisecs = null;
    distance = null;
    startLatitude = null;
    startLongitude = null;
    startAltitude = null;
    endLatitude = null;
    endLongitude = null;
    endAltitude = null;
    label = null;
    travelType = null;
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
