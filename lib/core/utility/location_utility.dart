import 'package:ttkapp/core/constants.dart' as constants;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/database/db_helper.dart';
import 'package:ttkapp/core/dataclass/location_data.dart';
import 'dart:async';
import '../dataclass/base/result_base.dart';

class LocationUtility {

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  LocationPermission permission = LocationPermission.denied;
  Position? currentPosition;
  StreamSubscription? subscription;
  bool isLocationEnabled = false;

  Future<Result<List<LocationData>>> selectLocation() async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> queryResult;
    List<LocationData> locationList = List<LocationData>.empty(growable: true);

    List<String> columns = [
      "locationRecordID",
      "recordID",
      "locationOrder",
      "latitude",
      "longitude",
      "altitude",
      "speed",
      "elapsedDistance",
      "timeAtInstance"
    ];

    try {
      queryResult = await db.query(
        constants.locationTable,
        columns: columns,
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    Iterator<Map<String, dynamic>> it = queryResult.iterator;

    while (it.moveNext()) {
      LocationData locationData = LocationData();

      locationData.locationRecordID = it.current["locationRecordID"];
      locationData.recordID = it.current["recordID"];
      locationData.locationOrder = it.current["locationOrder"];
      locationData.latitude = it.current["latitude"];
      locationData.longitude = it.current["longitude"];
      locationData.altitude = it.current["altitude"];
      locationData.speed = it.current["speed"];
      locationData.elapsedDistance = it.current["elapsedDistance"];
      locationData.timeAtInstance = it.current["timeAtInstance"] != null ? DateTime.parse(it.current["timeAtInstance"]) : null;

      locationList.add(locationData);
    }

    return Result.success(locationList);
  }

  Future<Result<List<LocationData>>> selectLocationByProps(LocationData locationData) async {
    final db = await dbHelper.database;

    List<Map<String, dynamic>> queryResult;
    List<LocationData> locationList = List<LocationData>.empty(growable: true);
    
    Map<String, dynamic> props = {};
    String where = "";
    List<dynamic> whereArgs = [];

    List<String> columns = [
      "locationRecordID",
      "recordID",
      "locationOrder",
      "latitude",
      "longitude",
      "altitude",
      "speed",
      "elapsedDistance",
      "timeAtInstance"
    ];

    props["locationRecordID"] = locationData.locationRecordID;
    props["recordID"] = locationData.recordID;
    props["locationOrder"] = locationData.locationOrder;
    props["latitude"] = locationData.latitude;
    props["longitude"] = locationData.longitude;
    props["altitude"] = locationData.altitude;
    props["speed"] = locationData.speed;
    props["elapsedDistance"] = locationData.elapsedDistance;
    props["timeAtInstance"] = locationData.timeAtInstance?.toString();

    Iterator<String> cit = columns.iterator;

    while(cit.moveNext()) {
      String col = cit.current;
      if (col == "locationRecordID") continue;
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
      LocationData locationData = LocationData();

      locationData.locationRecordID = it.current["locationRecordID"];
      locationData.recordID = it.current["recordID"];
      locationData.locationOrder = it.current["locationOrder"];
      locationData.latitude = it.current["latitude"];
      locationData.longitude = it.current["longitude"];
      locationData.altitude = it.current["altitude"];
      locationData.speed = it.current["speed"];
      locationData.elapsedDistance = it.current["elapsedDistance"];
      locationData.timeAtInstance = it.current["timeAtInstance"] != null ? DateTime.parse(it.current["timeAtInstance"]) : null;

      locationList.add(locationData);
    }

    return Result.success(locationList);
  }

  Future<Result<LocationData>> selectLocationByID(int locationRecordID) async {
    final db = await dbHelper.database;

    List<Map<String, dynamic>> queryResult;
    LocationData locationData = LocationData();

    List<String> columns = [
      "locationRecordID",
      "recordID",
      "locationOrder",
      "latitude",
      "longitude",
      "altitude",
      "speed",
      "elapsedDistance",
      "timeAtInstance"
    ];

    try {
      queryResult = await db.query(
        constants.locationTable,
        columns: columns,
        where: "locationRecordID = ?",
        whereArgs: [locationRecordID],
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    Iterator<Map<String, dynamic>> it = queryResult.iterator;

    if (it.moveNext()) {
      locationData.locationRecordID = it.current["locationRecordID"];
      locationData.recordID = it.current["recordID"];
      locationData.locationOrder = it.current["locationOrder"];
      locationData.latitude = it.current["latitude"];
      locationData.longitude = it.current["longitude"];
      locationData.altitude = it.current["altitude"];
      locationData.speed = it.current["speed"];
      locationData.elapsedDistance = it.current["elapsedDistance"];
      locationData.timeAtInstance = it.current["timeAtInstance"] != null ? DateTime.parse(it.current["timeAtInstance"]) : null;
    }

    return Result.success(locationData);
  }

  Future<Result<int>> insertLocation(LocationData locationData) async {
    final db = await dbHelper.database;
    int locationRecordID;

    Map<String, dynamic> row = {
      "recordID": locationData.recordID,
      "locationOrder": locationData.locationOrder,
      "latitude": locationData.latitude,
      "longitude": locationData.longitude,
      "altitude": locationData.altitude,
      "speed": locationData.speed,
      "elapsedDistance": locationData.elapsedDistance,
      "timeAtInstance": locationData.timeAtInstance?.toString(),
    };

    try {
      locationRecordID = await db.insert(constants.locationTable, row);
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    return Result.success(locationRecordID);
  }

  Future<Result<int>> updateLocation(LocationData locationData) async {
    final db = await dbHelper.database;
    int count;

    Map<String, dynamic> row = {
      "recordID": locationData.recordID,
      "locationOrder": locationData.locationOrder,
      "latitude": locationData.latitude,
      "longitude": locationData.longitude,
      "altitude": locationData.altitude,
      "speed": locationData.speed,
      "elapsedDistance": locationData.elapsedDistance,
      "timeAtInstance": locationData.timeAtInstance?.toString(),
    };

    try {
      count = await db.update(
        constants.locationTable,
        row,
        where: "locationRecordID = ?",
        whereArgs: [locationData.locationRecordID],
      );
    }
    on Exception catch (e) {
      return Result.failure(e.toString());
    }

    return Result.success(count);
  }

  Future<Result<LocationPermission>> locationPermission() async {

    bool serviceEnabled;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Result.success(LocationPermission.denied);
    }

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.unableToDetermine) {
      return Result.failure("Unable to determine location status.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    isLocationEnabled = permission == LocationPermission.always || permission == LocationPermission.whileInUse;

    return Result.success(permission);
  }

  void startListeningLocation() {
    if(isLocationEnabled) {
      subscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
          intervalDuration: const Duration(seconds:1),
        )
      ).listen((event) async {
        currentPosition = event;
      });

    } else {
      return;
    }

  }

  Future<Position?> getPosition() async {
    if (isLocationEnabled) {
        currentPosition = await Geolocator.getCurrentPosition();
      return await Geolocator.getCurrentPosition();
    }
    return null;
  }

  Future<double> calculateDistance(Position? prev, Position? curr) async { 
    if (prev == null || curr == null) return 0.0;
    
    double distance = Geolocator.distanceBetween(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );

    return distance;
  }

  String convertPositionToString(AppLocalizations? message) {

    if (!isLocationEnabled) {
      return message!.locationDisabled;
    }

    if (currentPosition == null) {
      return message!.waitAvailableLocation;
    }

    return '${currentPosition?.latitude.toStringAsFixed(7)}, ${currentPosition?.longitude.toStringAsFixed(7)}, ${currentPosition?.altitude.toStringAsFixed(2)}';
  }

  //deprecated
  void changeLocation(bool run) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await getPosition();
    });

  }

}
