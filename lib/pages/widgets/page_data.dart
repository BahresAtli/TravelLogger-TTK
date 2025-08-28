import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/dataclass/location_table.dart';
import 'package:ttkapp/core/dataclass/main_table.dart';
import 'package:ttkapp/core/database/db_helper.dart';
import 'package:ttkapp/core/utility/location_utility.dart';
import 'package:ttkapp/core/utility/time_utility.dart';

class PageData {

  DatabaseHelper dbHelper;
  MainTable mainData;
  LocationTable locationData;
  LocationUtility utilLocation;
  TimeUtility utilTime;
  bool isPageStable;
  bool isButtonPressed;
  bool isLocationEnabled;
  Timer? initialSetState;
  Timer? timerState;
  Timer? timerDatabase;
  TextEditingController textEditingController;
  AppLocalizations? message;

  PageData() : 
    dbHelper = DatabaseHelper.instance,
    mainData = MainTable(),
    locationData = LocationTable(),
    utilLocation = LocationUtility(),
    utilTime = TimeUtility(),
    isPageStable = true,
    isButtonPressed = false,
    isLocationEnabled = true,
    textEditingController = TextEditingController();
}