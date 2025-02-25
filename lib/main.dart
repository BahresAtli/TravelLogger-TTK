import 'dart:async';
import 'package:flutter/material.dart';
import 'core/time_ttk.dart';
import 'core/location_ttk.dart';
//import 'package:flutter_foreground_task/flutter_foreground_task.dart';
//import 'database/db_helper.dart';
//import 'package:geolocator/geolocator.dart';

LocationTTK locationTTK = LocationTTK();

/*Future<void> getDatabase() async {
  DatabaseHelper db = DatabaseHelper.instance;
  for (int i = 5; i < 15; i++) {
    Map<String, dynamic> dersRow = {
      'recordID': i,
      "startTime": '01-01-2025 12:00:00',
      "endTime": '01-01-2025 13:00:00',
      "elapsedMilisecs": 3600000,
    };
    await db.insert(dersRow, "mainTable");
  }

  Map<String, dynamic> dersRow = {
    'recordID': 0,
    "startTime": '01-01-2025 12:00:00',
    "endTime": '01-01-2025 13:00:00',
    "elapsedMilisecs": 3600000,
  };
  await db.insert(dersRow, "mainTable");
}*/

Future<bool> setLocationPermission() async {
  return locationTTK.locationPermission();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterForegroundTask.initCommunicationPort();
  setLocationPermission();
  //getDatabase();
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

  int? recordID;
  String? startTime;
  String? endTime;
  int? elapsedMilisecs;
  String? startLatitude;
  String? startLongitude;
  String? endLatitude;
  String? endLongitude;

  void _pressHandler() async {
    timeTTK.start();
    timer = Timer.periodic(const Duration(milliseconds: 10), (Timer t) {
      setState(() {});
    });
    Timer.periodic(const Duration (seconds: 1), (Timer t) {
      locationTTK.getPosition();
    });
  }

  void _finishHandler() {
    timeTTK.stop();
    timer?.cancel();
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
    if (isPressed == true) {
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
    String textField =
        'Last Measured Time: ${timeTTK.formatElapsedToText(timeTTK.lastTime)}';

    return Container(child: _commonText(textField, 20));
  }

  Container _currentLocation() {
    String textField =
        locationTTK.convertPositionToString();

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
