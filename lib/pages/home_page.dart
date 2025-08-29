import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/dataclass/base/result_base.dart';
import 'package:ttkapp/core/dataclass/record_data.dart';
import 'package:ttkapp/pages/widgets/common_text.dart';
import 'package:ttkapp/pages/widgets/homepage/distance_speed_text.dart';
import 'package:ttkapp/pages/widgets/homepage/label_text_box.dart';
import 'package:ttkapp/pages/widgets/homepage/location_text.dart';
import 'package:ttkapp/pages/widgets/page_data.dart';
import 'package:ttkapp/pages/widgets/homepage/start_button.dart';
import 'package:ttkapp/pages/widgets/homepage/time_text.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class HomePage extends StatefulWidget {
  final PageData pageData;
  const HomePage({
      super.key,
      required this.pageData,
    });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // initState() → widget ilk kez ekrana geldiğinde 1 kere çalışır.
  // dispose() → widget ekrandan kalkarken çalışır (ör. başka sayfaya gidildiğinde).
  // Bu yüzden timer gibi şeyler initState’de başlatılır, dispose’da kapatılır.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!widget.pageData.isLocationEnabled) {
        _locationInformation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 75), //temporary solution for centering
            TimeText(
              isPressed: widget.pageData.isButtonPressed,
              utilTime: widget.pageData.utilTime
            ),
            const SizedBox(height: 10),
            StartButton(
              isPageStable: widget.pageData.isPageStable,
              isButtonPressed: widget.pageData.isButtonPressed,
              onPressed: startButtonPressed
            ),
            const SizedBox(height: 10),
            DistanceSpeedText(
              isPageStable: widget.pageData.isPageStable,
              isButtonPressed: widget.pageData.isButtonPressed,
              isLocationEnabled: widget.pageData.isLocationEnabled,
              utilLocation: widget.pageData.utilLocation, 
              recordData: widget.pageData.recordData
            ),
            const SizedBox(height: 10),
            LocationText(
              isPageStable: widget.pageData.isPageStable,
              isButtonPressed: widget.pageData.isButtonPressed,
              isLocationEnabled: widget.pageData.isLocationEnabled,
              isStartConfigDone: widget.pageData.isStartConfigDone,
              utilLocation: widget.pageData.utilLocation
            ),
            const SizedBox(height: 10),
            LabelTextBox(
              isButtonPressed: widget.pageData.isButtonPressed,
              textEditingController: widget.pageData.textEditingController
            )
          ],
        ),
      ),
    );
  }

  void startButtonPressed() {
    setState((){});
    if(widget.pageData.isPageStable) {
      if (widget.pageData.isButtonPressed == false) {
        _pressHandler(context);
      } else {
        _finishHandler();
      }
      widget.pageData.isButtonPressed = !widget.pageData.isButtonPressed;
    }
  }

  void _pressHandler(BuildContext context) async {

    AppLocalizations? message = AppLocalizations.of(context);

    //start the operations

    widget.pageData.utilTime.start();
    widget.pageData.recordData.startTime = DateTime.now();
    await widget.pageData.utilLocation.getInitialPosition(widget.pageData.isLocationEnabled);
    widget.pageData.utilLocation.startListeningLocation(widget.pageData.isLocationEnabled);
    WakelockPlus.enable();

    //reset the data
    widget.pageData.locationData.locationOrder = 0;
    widget.pageData.recordData.distance = 0.0;

    //distance calculation setup
    double distanceDifference = 0.0;
    Position? previousPosition = widget.pageData.utilLocation.getPosition();

    widget.pageData.timerState = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState(() {});
      if (previousPosition != null && widget.pageData.utilLocation.getPosition() != null) {
        distanceDifference = await widget.pageData.utilLocation.calculateDistance(previousPosition, widget.pageData.utilLocation.getPosition());
        widget.pageData.recordData.distance = widget.pageData.recordData.distance! + distanceDifference;
      }
      previousPosition = widget.pageData.utilLocation.getPosition();
    });

    widget.pageData.isStartConfigDone = true;


    //wait the app to get location before it starts to save initial data on the mainTable
    widget.pageData.recordData.startLatitude = widget.pageData.utilLocation.getPosition()?.latitude;
    widget.pageData.recordData.startLongitude = widget.pageData.utilLocation.getPosition()?.longitude;
    widget.pageData.recordData.startAltitude = widget.pageData.utilLocation.getPosition()?.altitude;
    widget.pageData.recordData.label = message!.errorMeasure;

    Result<int> insertRecordResult = await widget.pageData.utilRecord.insertRecord(widget.pageData.recordData);
    if (!insertRecordResult.isSuccess) {
      //show error
      print("Error while inserting record: ${insertRecordResult.error}");
    }

    widget.pageData.recordData.recordID = insertRecordResult.data!;

    widget.pageData.locationData.recordID = widget.pageData.recordData.recordID; 

    if(widget.pageData.isLocationEnabled) {
      widget.pageData.timerDatabase =
      Timer.periodic(const Duration(seconds: 1), (Timer t) async { //changed to every sec for debugging
        widget.pageData.locationData.locationOrder = widget.pageData.locationData.locationOrder! + 1;
        widget.pageData.locationData.latitude = widget.pageData.utilLocation.getPosition()?.latitude;
        widget.pageData.locationData.longitude = widget.pageData.utilLocation.getPosition()?.longitude;
        widget.pageData.locationData.altitude = widget.pageData.utilLocation.getPosition()?.altitude;
        widget.pageData.locationData.speed = widget.pageData.utilLocation.getPosition()?.speed;
        widget.pageData.locationData.elapsedDistance = widget.pageData.recordData.distance;
        widget.pageData.locationData.timeAtInstance = DateTime.now();

        Result<int> insertLocationResult = await widget.pageData.utilLocation.insertLocation(widget.pageData.locationData);
        if (!insertLocationResult.isSuccess) {
          //show error
          print("Error while inserting location: ${insertLocationResult.error}");
        }

        widget.pageData.locationData.locationRecordID = insertLocationResult.data!;
      });
    }

  }

  void _finishHandler() async {
    RecordData recordData = RecordData();

    widget.pageData.recordData.endTime = DateTime.now();

    //stop the operations
    widget.pageData.recordData.elapsedMilisecs = widget.pageData.utilTime.stop();
    widget.pageData.timerDatabase?.cancel();
    widget.pageData.timerState?.cancel();
    widget.pageData.utilLocation.stopListeningLocation();

    WakelockPlus.disable();


    //this is for the new session settings, new session overwrites these values and cause to program to update the old row with new session variables.
    widget.pageData.recordData.endLatitude = widget.pageData.utilLocation.getPosition()?.latitude;
    widget.pageData.recordData.endLongitude = widget.pageData.utilLocation.getPosition()?.longitude;
    widget.pageData.recordData.endAltitude = widget.pageData.utilLocation.getPosition()?.altitude;
    widget.pageData.recordData.label = widget.pageData.textEditingController.text;

    recordData = widget.pageData.recordData;
    recordData.recordID = widget.pageData.recordData.recordID;
    recordData.startTime = widget.pageData.recordData.startTime;
    recordData.startLatitude = widget.pageData.recordData.startLatitude;
    recordData.startLongitude = widget.pageData.recordData.startLongitude; 
    recordData.startAltitude = widget.pageData.recordData.startAltitude;
    widget.pageData.textEditingController.clear();

    Result<int> updateRecordResult = await widget.pageData.utilRecord.updateRecord(recordData);
    
    if (!updateRecordResult.isSuccess) {
      //show error
      print("Error while updating record: ${updateRecordResult.error}");
    }
    widget.pageData.isStartConfigDone = false;
    widget.pageData.recordData.distance = 0.0;
  }


  Future<String?> _locationInformation() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 67, 66, 66),
        title: CommonText(text: AppLocalizations.of(context)!.attention, fontSize: 20),
        content: Text(
          AppLocalizations.of(context)!.locationDenyDescription,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        actions: [
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          )
        ]
      ),
    );
  }

  /*
  void _testingFunction() async {
    RecordData recordData = RecordData();
    recordData.label = "jrume";
    Result queryResult = await widget.pageData.utilRecord.selectRecordByProps(recordData);
    if (!queryResult.isSuccess) {
      print("Error: ${queryResult.error}");
      return;
    }
  }
  */

  //Deprecated zone

  /*
  
  //for the old label system, maybe will be used later on
  
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
            controller: widget.pageData.textEditingController,
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
                if (widget.pageData.isButtonPressed == false) {
                  _pressHandler();
                  widget.pageData.isButtonPressed = !widget.pageData.isButtonPressed;
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
                Navigator.of(context).pop(widget.pageData.textEditingController.text);
                widget.pageData.textEditingController.clear();
              },
            ),
          ],
        ),
      );
    

  Container _timeText(BuildContext context) {
    String textField = AppLocalizations.of(context)!.defaultText;
    if (widget.pageData.isButtonPressed) {
      textField = widget.pageData.utilTime.formatElapsedToText(null);
    }
    return Container(
      width: 250,
      //padding: widget.pageData.isButtonPressed ? const EdgeInsets.only(left: 58) : null,
      alignment: /*widget.pageData.isButtonPressed ? null :*/ Alignment.center,
      child: _commonText(textField, 30),
    );
  }
  
    TextButton _startButton(BuildContext context) {
    if(widget.pageData.isPageStable) {
      return TextButton(
        onPressed: () {
          setState((){});
            if(widget.pageData.isPageStable) {
              if (widget.pageData.isButtonPressed == false) {
                _pressHandler(context);
              } else {
                _finishHandler();
              }
              widget.pageData.isButtonPressed = !widget.pageData.isButtonPressed;
            }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(150, 50),
        ),
        child: widget.pageData.isButtonPressed ? _commonText(AppLocalizations.of(context)!.finish, 20) : _commonText(AppLocalizations.of(context)!.start, 20),
      );
    } else {
      return TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(150, 50),
        ),
        child: _commonText(AppLocalizations.of(context)!.pleaseWait, 20),
      );
    }
  }

    Container _distanceAndSpeed(BuildContext context) {
    String textField = AppLocalizations.of(context)!.seeDistanceSpeed;
    if(!widget.pageData.isPageStable) {
      textField = AppLocalizations.of(context)!.appUpdated(constants.appVersion);
    }
    if (widget.pageData.isButtonPressed) {
      double? kmh = widget.pageData.utilLocation.getPosition()?.speed;
      if (kmh != null) {
        kmh = kmh * 3.6;
        textField = '${widget.pageData.recordData.distance?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.meter}, ${kmh.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kmHour}';        
      } else if (widget.pageData.isLocationEnabled) {
        textField = AppLocalizations.of(context)!.waitAvailableLocation;
      } else {
        textField = AppLocalizations.of(context)!.locationDisabled;
      }
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
  
  */
}
