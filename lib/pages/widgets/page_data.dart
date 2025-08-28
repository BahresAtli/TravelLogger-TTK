import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/core/data/location_table.dart';
import 'package:ttkapp/core/data/main_table.dart';
import 'package:ttkapp/core/database/db_helper.dart';
import 'package:ttkapp/core/functionality/location/location_ttk.dart';
import 'package:ttkapp/core/functionality/time/time_ttk.dart';

class PageData {

  DatabaseHelper dbHelper;
  MainTable mainData;
  LocationTable locationData;
  LocationTTK locationTTK;
  TimeTTK timeTTK;
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
    locationTTK = LocationTTK(),
    timeTTK = TimeTTK(),
    isPageStable = true,
    isButtonPressed = false,
    isLocationEnabled = true,
    textEditingController = TextEditingController();
}