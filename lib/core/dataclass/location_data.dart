
import 'package:ttkapp/core/dataclass/base/object_base.dart';

class LocationData extends ObjectBase {
  late int locationRecordID;
  late int? recordID;
  late int? locationOrder;
  late double? latitude;
  late double? longitude;
  late double? altitude;
  late double? speed;
  late double? elapsedDistance;
  late DateTime? timeAtInstance;

  LocationData() {
    locationRecordID = 0;
    recordID = null;
    locationOrder = null;
    latitude = null;
    longitude = null;
    altitude = null;
    speed = null;
    elapsedDistance = null;
    timeAtInstance = null;
  }

}
