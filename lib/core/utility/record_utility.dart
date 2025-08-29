import 'package:ttkapp/core/constants.dart' as constants;
import 'package:ttkapp/core/database/db_helper.dart';
import 'package:ttkapp/core/dataclass/base/result_base.dart';
import 'package:ttkapp/core/dataclass/record_data.dart';

class RecordUtility {

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  RecordUtility();

  Future<Result<List<RecordData>>> selectRecord() async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> queryResult;
    List<RecordData> recordList = List<RecordData>.empty(growable: true);

    List<String> columns = [
      "recordID",
      "startTime",
      "endTime",
      "elapsedMilisecs",
      "distance",
      "startLatitude",
      "startLongitude",
      "startAltitude",
      "endLatitude",
      "endLongitude",
      "endAltitude",
      "label"
    ];

    try {
      queryResult = await db.query(
        constants.mainTable,
        columns: columns,
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    Iterator<Map<String, dynamic>> it = queryResult.iterator;

    while (it.moveNext()) {
      RecordData recordData = RecordData();

      recordData.recordID = it.current["recordID"];
      recordData.startTime = it.current["startTime"] != null ? DateTime.parse(it.current["startTime"]) : null;
      recordData.endTime = it.current["endTime"] != null ? DateTime.parse(it.current["endTime"]) : null;
      recordData.elapsedMilisecs = it.current["elapsedMilisecs"];
      recordData.distance = it.current["distance"];
      recordData.startLatitude = it.current["startLatitude"];
      recordData.startLongitude = it.current["startLongitude"];
      recordData.startAltitude = it.current["startAltitude"];
      recordData.endLatitude = it.current["endLatitude"];
      recordData.endLongitude = it.current["endLongitude"];
      recordData.endAltitude = it.current["endAltitude"];
      recordData.label = it.current["label"];

      recordList.add(recordData);
    }

    return Result.success(recordList);
  }

  Future<Result<List<RecordData>>> selectRecordByProps(RecordData recordData) async {
    final db = await dbHelper.database;

    List<Map<String, dynamic>> queryResult;
    List<RecordData> recordList = List<RecordData>.empty(growable: true);
    
    Map<String, dynamic> props = {};
    String where = "";
    List<dynamic> whereArgs = [];

    List<String> columns = [
      "recordID",
      "startTime",
      "endTime",
      "elapsedMilisecs",
      "distance",
      "startLatitude",
      "startLongitude",
      "startAltitude",
      "endLatitude",
      "endLongitude",
      "endAltitude",
      "label"
    ];

    props["startTime"] = recordData.startTime?.toString();
    props["endTime"] = recordData.endTime?.toString();
    props["elapsedMilisecs"] = recordData.elapsedMilisecs;
    props["distance"] = recordData.distance;
    props["startLatitude"] = recordData.startLatitude;
    props["startLongitude"] = recordData.startLongitude;
    props["startAltitude"] = recordData.startAltitude;
    props["endLatitude"] = recordData.endLatitude;
    props["endLongitude"] = recordData.endLongitude;
    props["endAltitude"] = recordData.endAltitude;
    props["label"] = recordData.label;

    Iterator<String> cit = columns.iterator;

    while(cit.moveNext()) {
      String col = cit.current;
      if (col == "recordID") continue;
      if (props[col] == null) continue;
      where += (where == "" ? "" : " AND ") + ("$col = ?");
      whereArgs.add(props[col]);
    }

    try {
      queryResult = await db.query(
        constants.mainTable,
        columns: columns,
        where: where == "" ? null : where,
        whereArgs: whereArgs,
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    Iterator<Map<String, dynamic>> it = queryResult.iterator;

    while (it.moveNext()) {
      RecordData recordData = RecordData();

      recordData.recordID = it.current["recordID"];
      recordData.startTime = it.current["startTime"] != null ? DateTime.parse(it.current["startTime"]) : null;
      recordData.endTime = it.current["endTime"] != null ? DateTime.parse(it.current["endTime"]) : null;
      recordData.elapsedMilisecs = it.current["elapsedMilisecs"];
      recordData.distance = it.current["distance"];
      recordData.startLatitude = it.current["startLatitude"];
      recordData.startLongitude = it.current["startLongitude"];
      recordData.startAltitude = it.current["startAltitude"];
      recordData.endLatitude = it.current["endLatitude"];
      recordData.endLongitude = it.current["endLongitude"];
      recordData.endAltitude = it.current["endAltitude"];
      recordData.label = it.current["label"];

      recordList.add(recordData);
    }

    return Result.success(recordList);
  }

  Future<Result<RecordData>> selectRecordByID(int recordID) async {
    final db = await dbHelper.database;

    List<Map<String, dynamic>> queryResult;
    RecordData recordData = RecordData();

    List<String> columns = [
      "recordID",
      "startTime",
      "endTime",
      "elapsedMilisecs",
      "distance",
      "startLatitude",
      "startLongitude",
      "startAltitude",
      "endLatitude",
      "endLongitude",
      "endAltitude",
      "label"
    ];

    try {
      queryResult = await db.query(
        constants.mainTable,
        columns: columns,
        where: "recordID = ?",
        whereArgs: [recordID],
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    Iterator<Map<String, dynamic>> it = queryResult.iterator;

    if (it.moveNext()) {
      recordData.recordID = it.current["recordID"];
      recordData.startTime = it.current["startTime"] != null ? DateTime.parse(it.current["startTime"]) : null;
      recordData.endTime = it.current["endTime"] != null ? DateTime.parse(it.current["endTime"]) : null;
      recordData.elapsedMilisecs = it.current["elapsedMilisecs"];
      recordData.distance = it.current["distance"];
      recordData.startLatitude = it.current["startLatitude"];
      recordData.startLongitude = it.current["startLongitude"];
      recordData.startAltitude = it.current["startAltitude"];
      recordData.endLatitude = it.current["endLatitude"];
      recordData.endLongitude = it.current["endLongitude"];
      recordData.endAltitude = it.current["endAltitude"];
      recordData.label = it.current["label"];
    }

    return Result.success(recordData);
  }

  Future<Result<int>> insertRecord(RecordData recordData) async {
    final db = await dbHelper.database;
    int recordID;

    Map<String, dynamic> row = {
      "startTime": recordData.startTime?.toString(),
      "endTime": recordData.endTime?.toString(),
      "elapsedMilisecs": recordData.elapsedMilisecs,
      "distance": recordData.distance,
      "startLatitude": recordData.startLatitude,
      "startLongitude": recordData.startLongitude,
      "startAltitude": recordData.startAltitude,
      "endLatitude": recordData.endLatitude,
      "endLongitude": recordData.endLongitude,
      "endAltitude": recordData.endAltitude,
      "label": recordData.label
    };

    try {
      recordID = await db.insert(constants.mainTable, row);
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    return Result.success(recordID);
  }

  Future<Result<int>> updateRecord(RecordData recordData) async {
    final db = await dbHelper.database;
    int count;

    Map<String, dynamic> row = {
      "startTime": recordData.startTime?.toString(),
      "endTime": recordData.endTime?.toString(),
      "elapsedMilisecs": recordData.elapsedMilisecs,
      "distance": recordData.distance,
      "startLatitude": recordData.startLatitude,
      "startLongitude": recordData.startLongitude,
      "startAltitude": recordData.startAltitude,
      "endLatitude": recordData.endLatitude,
      "endLongitude": recordData.endLongitude,
      "endAltitude": recordData.endAltitude,
      "label": recordData.label
    };

    try {
      count = await db.update(
        constants.mainTable,
        row,
        where: "recordID = ?",
        whereArgs: [recordData.recordID],
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    return Result.success(count);
  }

}