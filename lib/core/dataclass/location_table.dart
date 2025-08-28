
import 'package:ttkapp/core/dataclass/base/object_base.dart';

class LocationTable extends ObjectBase {
  late int locationRecordID;
  late int recordID;
  late int locationOrder;
  late double? latitude;
  late double? longitude;
  late double? altitude;
  late double? speed;
  late double? elapsedDistance;
  late DateTime? timeAtInstance;

  LocationTable() {
    locationRecordID = 0;
    recordID = 0;
    locationOrder = 0;
  }

}
