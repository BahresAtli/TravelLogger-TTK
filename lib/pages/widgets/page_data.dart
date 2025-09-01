import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:ttkapp/core/dataclass/location_data.dart';
import 'package:ttkapp/core/dataclass/record_data.dart';
import 'package:ttkapp/core/database/db_helper.dart';
import 'package:ttkapp/core/utility/location_utility.dart';
import 'package:ttkapp/core/utility/record_utility.dart';
import 'package:ttkapp/core/utility/time_utility.dart';

class PageData {

  DatabaseHelper dbHelper;
  RecordData recordData;
  RecordUtility utilRecord;
  LocationData locationData;
  LocationUtility utilLocation;
  TimeUtility utilTime;
  bool isPageStable;
  bool isButtonPressed;
  bool isLocationEnabled;
  bool isStartConfigDone;
  Timer? timerSetState;
  Timer? timerState;
  Timer? timerDatabase;
  TextEditingController textEditingController;
  AppLocalizations? message;
  Logger logger;

  PageData() : 
    dbHelper = DatabaseHelper.instance,
    recordData = RecordData(),
    utilRecord = RecordUtility(),
    locationData = LocationData(),
    utilLocation = LocationUtility(),
    utilTime = TimeUtility(),
    isPageStable = true,
    isButtonPressed = false,
    isLocationEnabled = true,
    isStartConfigDone = false,
    textEditingController = TextEditingController(),
    logger = Logger('HomePage');
}