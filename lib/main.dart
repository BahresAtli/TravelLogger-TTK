import 'dart:async';
import 'package:flutter/material.dart';
import 'core/time_ttk.dart';
import 'core/location_ttk.dart';
import 'database/db_helper.dart';
import 'database/main_table.dart';
import 'database/location_table.dart';

//TODO: App cannot get location data when it runs in background

MainTable mainData = MainTable();
LocationTable locationData  = LocationTable();

LocationTTK locationTTK = LocationTTK();

DatabaseHelper dbHelper = DatabaseHelper.instance;

Map<String, dynamic>? initialItem;

Future<void> initialInsert() async {
  var list = await dbHelper.select('mainTable');
  if (list.isEmpty) {
    locationData.recordID = 1;
    for (int i = 0; i < 1; i++) {
      Map<String, dynamic> row = {
        'recordID': i,
        "startTime": '01-01-2025 12:00:00',
        "endTime": '01-01-2025 13:00:00',
        "elapsedMilisecs": 3600000,
      };
      await dbHelper.insert(row, "mainTable");
    }
  }
}

Future<bool> setLocationPermission() async {
  return locationTTK.locationPermission();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setLocationPermission();
  initialInsert();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isPressed = false;

  Timer? timer;
  TimeTTK timeTTK = TimeTTK();


  void _pressHandler() async {
    // Note that I defined 0th index as test index
    var list = await dbHelper.select('mainTable');
    initialItem = list.first;
    if (initialItem?['recordID'] == 0) {
      dbHelper.delete(0, "mainTable");
    }
    locationData.recordID = list.last['recordID'] + 1;
    

    timeTTK.start();
    mainData.recordID = 0;
    locationData.locationOrder = 0;
    mainData.startTime = DateTime.now().toString();

    //TODO: Interface waits initial location data to update the screen with elapsed time. Fix.
    await locationTTK.getPosition();
    mainData.startLatitude = locationTTK.currentPosition?.latitude.toString();
    mainData.startLongitude = locationTTK.currentPosition?.longitude.toString();

    locationTTK.changeLocation();
    
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
    timer = Timer.periodic(const Duration(seconds:10), (Timer t) async {
      
      locationData.locationOrder++;
      locationData.latitude = locationTTK.currentPosition?.latitude.toString();
      locationData.longitude = locationTTK.currentPosition?.longitude.toString();
      locationData.timeAtInstance = DateTime.now().toString();
      Map<String, dynamic> row = {
          'recordID': locationData.recordID,
          'locationOrder': locationData.locationOrder,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'timeAtInstance': locationData.timeAtInstance
      };
      await dbHelper.insert(row, 'location');
    });
  }

  void _finishHandler() async {
    mainData.endTime = DateTime.now().toString();
    timeTTK.stop();
    timer?.cancel();
    mainData.elapsedMilisecs = timeTTK.lastTime;
    mainData.endLatitude = locationTTK.currentPosition?.latitude.toString();
    mainData.endLongitude = locationTTK.currentPosition?.longitude.toString();
    Map<String, dynamic> row = {
        'startTime': mainData.startTime,
        'endTime': mainData.endTime,
        'elapsedMilisecs': mainData.elapsedMilisecs,
        'startLatitude': mainData.startLatitude,
        'startLongitude': mainData.startLongitude,
        'endLatitude': mainData.endLatitude,
        'endLongitude': mainData.endLongitude
      };
    await dbHelper.insert(row, 'mainTable');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeText(),
              const SizedBox(height: 10),
              _startButton(),
              const SizedBox(height: 10),
              _lastData(),
              const SizedBox(height: 10),
              _currentLocation(),
            ],
          ),
        ),
      ),
    );
  }

  Container _timeText() {
    String textField = '-';
    if (isPressed) {
      textField = timeTTK.formatElapsedToText(null);
    }
    return Container(
      width: 250,
      //padding: isPressed ? const EdgeInsets.only(left: 58) : null,
      alignment: /*isPressed ? null :*/ Alignment.center,
      child: _commonText(textField, 30),
      );
  }

  TextButton _startButton() {
    return TextButton(
      onPressed: () {
        setState(
          () {
            if (isPressed == false) {
              _pressHandler();
            } else {
              _finishHandler();
            }
            isPressed = !isPressed;
          },
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(150, 50),
      ),
      child: isPressed ? _commonText('Finish', 20) : _commonText('Start', 20),
    );
  }

  Container _lastData() {
    String textField = 'Last Measured Time: ${timeTTK.formatElapsedToText(timeTTK.lastTime)}';

    return Container(child: _commonText(textField, 20));
  }

  Container _currentLocation() {
    String textField = 'Press Start to see location!';

    if (isPressed) {
      textField = locationTTK.convertPositionToString();
    }

    return Container(child: _commonText(textField, 20));
  }

  Text _commonText(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
      ),
    );
  }
}
