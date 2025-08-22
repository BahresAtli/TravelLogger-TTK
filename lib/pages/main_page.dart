import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/functionality/time/time_ttk.dart';
import '../core/functionality/location/location_ttk.dart';
import '../core/database/db_helper.dart';
import '../core/data/main_table.dart';
import '../core/data/location_table.dart';
import '../core/data/result_base.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../core/data/constants.dart' as constants;

class PageData {

  DatabaseHelper dbHelper;
  MainTable mainData;
  LocationTable locationData;
  LocationTTK locationTTK;
  TimeTTK timeTTK;
  bool stable;
  bool isPressed;
  bool isLocationEnabled;
  Timer? initialSetState;
  Timer? timerState;
  Timer? timerDatabase;
  TextEditingController textEditingController;

  PageData() : 
    dbHelper = DatabaseHelper.instance,
    mainData = MainTable(),
    locationData = LocationTable(),
    locationTTK = LocationTTK(),
    timeTTK = TimeTTK(),
    stable = true,
    isPressed = false,
    isLocationEnabled = false,
    textEditingController = TextEditingController();
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  PageData pageData = PageData();

  // initState() → widget ilk kez ekrana geldiğinde 1 kere çalışır.
  // dispose() → widget ekrandan kalkarken çalışır (ör. başka sayfaya gidildiğinde).
  // Bu yüzden timer gibi şeyler initState’de başlatılır, dispose’da kapatılır.
  @override
  void initState() {
    super.initState();
    appInitialization();
    setLocationPermission();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    pageData.initialSetState = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState(() {});
    });
  }

  Future<Result<int>> setLocationPermission() async {

    Result<LocationPermission> permission = await pageData.locationTTK.locationPermission();

    if(!permission.isSuccess) {
      return Result.failure(permission.error);
    }

    pageData.isLocationEnabled = permission.data == LocationPermission.always || permission.data == LocationPermission.whileInUse;

    return Result.success();
  }

  Future<void> appInitialization() async {
    pageData.stable = false;
    final db = await pageData.dbHelper.database;
    await pageData.dbHelper.initializeTable(db, constants.appConfigTable);

    List<Map<String, dynamic>> config = await pageData.dbHelper.select(constants.appConfigTable);
    late Map<String, dynamic> configInfo;
    if (config.isNotEmpty) configInfo = config[0];
    if (config.isEmpty) { //app is just installed to the system
      configInfo = {
        'versionInfo': constants.appVersion,
        'firstBoot': 0,
      };
      await pageData.dbHelper.insert(configInfo, constants.appConfigTable);
      configInfo = {
        // just so the config info is not equal to app version
        // it is going to run the code below in every fresh install regardless,
        // even though it is not needed for fresh installs. 
        // because upgrading from 0.0.0 is looking like first boot to the system,
        // which is not true and tables need to be refreshed, just for this instance
        // better implementation will come in the future
        'versionInfo': "0.0.0", 
        'firstBoot': 0,
      };
    }

    if (configInfo["versionInfo"] != constants.appVersion) {
      await pageData.dbHelper.initializeNewColumns(constants.appVersion);
      Map<String, dynamic> configInfo = {
        'appConfigID': 1,
        'versionInfo': constants.appVersion,
        'firstBoot': 0,
      };
      await pageData.dbHelper.update(configInfo, constants.appConfigTable, "appConfigID");
    }

    //await Future.delayed(const Duration(seconds: 5));

    pageData.stable = true;
    return;
  }

  void _pressHandler() async {

    //start the operations
    pageData.timeTTK.start();
    pageData.mainData.startTime = DateTime.now();
    WakelockPlus.enable();

    pageData.locationTTK.startListeningLocation();
    pageData.locationData.locationOrder = 0;
    pageData.mainData.distance = 0.0;
    double distanceDifference = 0.0;
    late Position? previousPosition;
    previousPosition = pageData.locationTTK.currentPosition;

    pageData.timerState = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState((){});
      if (previousPosition != null && pageData.locationTTK.currentPosition != null) {
        distanceDifference = await pageData.locationTTK.calculateDistance(previousPosition, pageData.locationTTK.currentPosition);
        pageData.mainData.distance = pageData.mainData.distance! + distanceDifference;
      }
      previousPosition = pageData.locationTTK.currentPosition;
    });

    //wait the app to get location before it starts to save initial data on the mainTable
    await pageData.locationTTK.getPosition();
    pageData.mainData.startLatitude = pageData.locationTTK.currentPosition?.latitude;
    pageData.mainData.startLongitude = pageData.locationTTK.currentPosition?.longitude;
    pageData.mainData.startAltitude = pageData.locationTTK.currentPosition?.altitude;
    pageData.mainData.label = "Error: App crashed/Connection lost while measuring";
    Map<String, dynamic> mainRow = {
      //even though app crashes in the middle of a measurement, there is properly connecting ID for location data, since an instance is created at the beginning.
      'startTime': pageData.mainData.startTime.toString(),
      'startLatitude': pageData.mainData.startLatitude,
      'startLongitude': pageData.mainData.startLongitude,
      'startAltitude': pageData.mainData.startAltitude,
      'label': pageData.mainData.label,
    };
    pageData.mainData.recordID = await pageData.dbHelper.insert(mainRow, constants.mainTable);
    pageData.locationData.recordID = pageData.mainData.recordID; 

    if(pageData.isLocationEnabled) {
      pageData.timerDatabase =
      Timer.periodic(const Duration(seconds: 1), (Timer t) async { //changed to every sec for debugging
        pageData.locationData.locationOrder++;
        pageData.locationData.latitude = pageData.locationTTK.currentPosition?.latitude;
        pageData.locationData.longitude = pageData.locationTTK.currentPosition?.longitude;
        pageData.locationData.altitude = pageData.locationTTK.currentPosition?.altitude;
        pageData.locationData.speed = pageData.locationTTK.currentPosition?.speed;
        pageData.locationData.elapsedDistance = pageData.mainData.distance;
        pageData.locationData.timeAtInstance = DateTime.now();
        Map<String, dynamic> locationRow = {
          'recordID': pageData.locationData.recordID,
          'locationOrder': pageData.locationData.locationOrder,
          'latitude': pageData.locationData.latitude,
          'longitude': pageData.locationData.longitude,
          'altitude' : pageData.locationData.altitude,
          'speed': pageData.locationData.speed,
          'elapsedDistance': pageData.locationData.elapsedDistance,
          'timeAtInstance': pageData.locationData.timeAtInstance.toString(),
        };
        pageData.locationData.locationRecordID = await pageData.dbHelper.insert(locationRow, 'location');
      });
    }

  }

  void _finishHandler() async {
    pageData.mainData.endTime = DateTime.now();
    pageData.timeTTK.stop();
    pageData.timerDatabase?.cancel();
    pageData.timerState?.cancel();
    WakelockPlus.disable();
    //this is for the new session settings, new session overwrites these values and cause to program to update the old row with new session variables.
    int? recordID = pageData.mainData.recordID;
    DateTime? startTime = pageData.mainData.startTime;
    double? startLatitude = pageData.mainData.startLatitude;
    double? startLongitude = pageData.mainData.startLongitude; 
    double? startAltitude = pageData.mainData.startAltitude;
    pageData.mainData.elapsedMilisecs = pageData.timeTTK.lastTime;
    pageData.mainData.endLatitude = pageData.locationTTK.currentPosition?.latitude;
    pageData.mainData.endLongitude = pageData.locationTTK.currentPosition?.longitude;
    pageData.mainData.endAltitude = pageData.locationTTK.currentPosition?.altitude;
    //mainData.label = await _labelInputBox();
    pageData.mainData.label = pageData.textEditingController.text;
    pageData.textEditingController.clear();
    Map<String, dynamic> row = {
      'recordID': recordID,
      'startTime': startTime.toString(),
      'endTime': pageData.mainData.endTime.toString(),
      'elapsedMilisecs': pageData.mainData.elapsedMilisecs,
      'distance': pageData.mainData.distance,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'startAltitude': startAltitude,
      'endLatitude': pageData.mainData.endLatitude,
      'endLongitude': pageData.mainData.endLongitude,
      'endAltitude': pageData.mainData.endAltitude,
      'label': pageData.mainData.label
    };
    await pageData.dbHelper.update(row, constants.mainTable, "recordID");
    pageData.mainData.distance = 0.0;
  }
  


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TTK App",
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          outlineBorder: BorderSide(
            color:Colors.red,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color:Colors.red
            )
          )
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.red,
          selectionColor: Colors.red,
          selectionHandleColor: Colors.red,
        )
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 75), //temporary solution for centering
              _timeText(),
              const SizedBox(height: 10),
              _startButton(),
              const SizedBox(height: 10),
              _distanceAndSpeed(),
              const SizedBox(height: 10),
              _currentLocation(),
              const SizedBox(height: 10),
              _labelTextBox(),
              //const SizedBox(height: 10),
              //_dropdownBox(),
            ],
          ),
        ),
      ),
    );
  }
  //for the old label system, maybe will be used later on
  /*
  Future<String?> _labelInputBox() => showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 67, 66, 66),
          title: _commonText('Label the measurement', 20),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter the label',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            controller: pageData.textEditingController,
          ),
          actions: [
            TextButton(
              child: const Text(
                'New session',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                if (pageData.isPressed == false) {
                  _pressHandler();
                  pageData.isPressed = !pageData.isPressed;
                }
              },
            ),
            TextButton(
              child: const Text(
                'Done!',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(pageData.textEditingController.text);
                pageData.textEditingController.clear();
              },
            ),
          ],
        ),
      );
    */

  Container _timeText() {
    String textField = '-';
    if (pageData.isPressed) {
      textField = pageData.timeTTK.formatElapsedToText(null);
    }
    return Container(
      width: 250,
      //padding: pageData.isPressed ? const EdgeInsets.only(left: 58) : null,
      alignment: /*pageData.isPressed ? null :*/ Alignment.center,
      child: _commonText(textField, 30),
    );
  }

  TextButton _startButton() {
    if(pageData.stable) {
      return TextButton(
        onPressed: () {
          setState((){});
            if(pageData.stable) {
              if (pageData.isPressed == false) {
                pageData.initialSetState?.cancel();
                _pressHandler();
              } else {
                _finishHandler();
              }
              pageData.isPressed = !pageData.isPressed;
            }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(150, 50),
        ),
        child: pageData.isPressed ? _commonText('Finish', 20) : _commonText('Start', 20),
      );
    } else {
      return TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(150, 50),
        ),
        child: _commonText('Please Wait', 20),
      );
    }

  }

  Container _distanceAndSpeed() {

    String textField = 'Press Start to see distance and speed.';
    if(!pageData.stable) {
      textField = 'App is updated to ${constants.appVersion}';
    }
    if (pageData.isPressed) {
      double? kmh = pageData.locationTTK.currentPosition?.speed;
      if (kmh != null) {
        kmh = kmh * 3.6;
        textField = ' ${pageData.mainData.distance?.toStringAsFixed(2)} m, ${kmh.toStringAsFixed(2)} km/h';        
      } else {
        textField = 'Location permission is disabled.';
      }
    }

    return Container(child: _commonText(textField, 20));
  }

  Container _currentLocation() {
    String textField = 'Press Start to see location!';

    if(!pageData.stable) {
      textField = 'Please wait for database to adjust itself.';
    }

    if (pageData.isPressed) {
      textField = pageData.locationTTK.convertPositionToString();
    }

    return Container(child: _commonText(textField, 20));
  }

  SizedBox _labelTextBox() {
    return SizedBox(
      width: 300,
      child: TextFormField(
        cursorColor: Colors.white,
        controller: pageData.textEditingController,
        style: const TextStyle(
          color: Colors.white,
        ),
        enabled: pageData.isPressed,
        decoration: const InputDecoration(
          hintText: 'Enter the label',
        ),
      ),
    );
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
