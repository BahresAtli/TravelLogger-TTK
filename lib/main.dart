import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'core/functionality/time/time_ttk.dart';
import 'core/functionality/location/location_ttk.dart';
import 'core/database/db_helper.dart';
import 'core/data/main_table.dart';
import 'core/data/location_table.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


MainTable mainData = MainTable();
LocationTable locationData = LocationTable();

LocationTTK locationTTK = LocationTTK();

DatabaseHelper dbHelper = DatabaseHelper.instance;

Future<bool> setLocationPermission() async {
  return locationTTK.locationPermission();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterForegroundTask.initCommunicationPort();
  setLocationPermission();
  runApp(const MaterialApp(home: MainApp())); //for making AlertDialog work
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isPressed = false;

  Timer? timerLocation;
  Timer? timerState;
  Timer? timerDatabase;
  TimeTTK timeTTK = TimeTTK();
  late TextEditingController controller = TextEditingController();

  void _pressHandler() async {
    var list = await dbHelper.select('mainTable');

    if (list.isEmpty) {
      locationData.recordID = 1;
      mainData.recordID = 1;
    } else {
      locationData.recordID = list.last['recordID'] + 1;
      mainData.recordID = list.last['recordID'] + 1;
    }

    timeTTK.start();
    locationTTK.startListeningLocation();
    locationData.locationOrder = 0;
    mainData.startTime = DateTime.now().toString();
    WakelockPlus
        .enable(); //don't turn off the screen, temporary solution for background issue

    timerState = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState(() {});
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
    //this is for the new session settings, new session overwrites these values and cause to program to update the old row with new session variables.
    int? recordID = mainData.recordID;
    String? startTime = mainData.startTime;
    String? startLatitude = mainData.startLatitude;
    String? startLongitude = mainData.startLongitude; 

    mainData.elapsedMilisecs = timeTTK.lastTime;
    mainData.endLatitude = locationTTK.currentPosition?.latitude.toString();
    mainData.endLongitude = locationTTK.currentPosition?.longitude.toString();
    //mainData.label = await _labelInputBox();
    mainData.label = controller.text;
    controller.clear();
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
              const SizedBox(height: 60), //temporary solution for centering
              _timeText(),
              const SizedBox(height: 10),
              _startButton(),
              const SizedBox(height: 10),
              _lastData(),
              const SizedBox(height: 10),
              _currentLocation(),
              const SizedBox(height: 10),
              _labelTextBox(),
            ],
          ),
        ),
      ),
    );
  }

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

  Container _labelTextBox() {
    return Container(
      width: 300,
      child: TextFormField(
        cursorColor: Colors.white,
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        enabled: isPressed,
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
