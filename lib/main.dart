import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'core/time_ttk.dart';
import 'core/location_ttk.dart';
import 'database/db_helper.dart';
import 'database/main_table.dart';
import 'database/location_table.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

//TODO: App cannot get location data when it runs in background

final FlutterBackgroundService service = FlutterBackgroundService();
bool isRunning = false;

MainTable mainData = MainTable();
LocationTable locationData = LocationTable();

LocationTTK locationTTK = LocationTTK();

DatabaseHelper dbHelper = DatabaseHelper.instance;

Map<String, dynamic>? initialItem;

Future<void> initialInsert() async {
  dbHelper.addColumn('label',
      'mainTable'); //label column is added (note that it is a temp solution, will be more structured later on)
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

Future<void> setPermissions() async {
  notificationPermission();
  locationTTK.locationPermission();
}
//location permission handler is copy pasted
Future<bool> notificationPermission() async {
  var status = await Permission.notification.status;

  if (status.isDenied) {
    return false;
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPermissions();
  initialInsert();
  await initializeService();
  runApp(const MaterialApp(home: MainApp())); //for making AlertDialog work
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
  );
}

void onStart(ServiceInstance service) async {

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if(!(await FlutterBackgroundService().isRunning())) {
        timer.cancel();
        return;
      }
      locationTTK.getPosition();
      print('Location taken!');
      service.setForegroundNotificationInfo(
        title: 'ttkApp Service',
        content: 'Current Location: ${locationTTK.currentPosition}',
      );
    }
  });
}

class _MainAppState extends State<MainApp> {
  bool isPressed = false;

  Timer? timerLocation;
  Timer? timerState;
  Timer? timerDatabase;
  TimeTTK timeTTK = TimeTTK();
  late TextEditingController controller = TextEditingController();

  void _pressHandler() async {
    // Note that I defined 0th index as test index
    var list = await dbHelper.select('mainTable');
    initialItem = list.first;
    if (initialItem?['recordID'] == 0) {
      dbHelper.delete(0, "mainTable");
    }
    locationData.recordID = list.last['recordID'] + 1;
    mainData.recordID = list.last['recordID'] + 1;

    await service.startService();
    timeTTK.start();
    locationData.locationOrder = 0;
    mainData.startTime = DateTime.now().toString();
    WakelockPlus
        .enable(); //don't turn off the screen, temporary solution for background issue

    timerState = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState(() {});
    });
    timerLocation = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await locationTTK.getPosition();
    });

    await locationTTK.getPosition();
    mainData.startLatitude = locationTTK.currentPosition?.latitude.toString();
    mainData.startLongitude = locationTTK.currentPosition?.longitude.toString();
    mainData.label = "Error: App crashed/Connection lost while measuring";
    Map<String, dynamic> mainRow = {
      //even though app crashes in the middle of a measurement, there is properly connecting ID for location data, since an instance is created at the beginning.
      'startTime': mainData.startTime,
      'startLatitude': mainData.startLatitude,
      'startLongitude': mainData.startLongitude,
      'label': mainData.label,
    };
    await dbHelper.insert(mainRow, 'mainTable');

    timerDatabase =
        Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      locationData.locationOrder++;
      locationData.latitude = locationTTK.currentPosition?.latitude.toString();
      locationData.longitude =
          locationTTK.currentPosition?.longitude.toString();
      locationData.timeAtInstance = DateTime.now().toString();
      Map<String, dynamic> locationRow = {
        'recordID': locationData.recordID,
        'locationOrder': locationData.locationOrder,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'timeAtInstance': locationData.timeAtInstance
      };
      await dbHelper.insert(locationRow, 'location');
    });
  }

  void _finishHandler() async {
    mainData.endTime = DateTime.now().toString();
    timeTTK.stop();
    timerDatabase?.cancel();
    timerLocation?.cancel();
    timerState?.cancel();
    WakelockPlus.disable();
    service.invoke('stopService');
    //this is for the new session settings, new session overwrites these values and cause to program to update the old row with new session variables.
    int? recordID = mainData.recordID;
    String? startTime = mainData.startTime;
    String? startLatitude = mainData.startLatitude;
    String? startLongitude = mainData.startLongitude; 

    mainData.elapsedMilisecs = timeTTK.lastTime;
    mainData.endLatitude = locationTTK.currentPosition?.latitude.toString();
    mainData.endLongitude = locationTTK.currentPosition?.longitude.toString();
    mainData.label = await _labelInputBox();
    Map<String, dynamic> row = {
      'recordID': recordID,
      'startTime': startTime,
      'endTime': mainData.endTime,
      'elapsedMilisecs': mainData.elapsedMilisecs,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': mainData.endLatitude,
      'endLongitude': mainData.endLongitude,
      'label': mainData.label
    };
    await dbHelper.update(row, 'mainTable');
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

  Future<String?> _labelInputBox() => showDialog<String>(
        //does not work at the moment
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
            controller: controller,
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
                if (isPressed == false) {
                  _pressHandler();
                  isPressed = !isPressed;
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
                Navigator.of(context).pop(controller.text);
                controller.clear();
              },
            ),
          ],
        ),
      );

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
    String textField =
        'Last Measured Time: ${timeTTK.formatElapsedToText(timeTTK.lastTime)}';

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
