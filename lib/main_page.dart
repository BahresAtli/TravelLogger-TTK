import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttkapp/pages/home_page.dart';
import 'package:ttkapp/pages/widgets/initializing_page.dart';
import 'package:ttkapp/pages/widgets/page_data.dart';
import 'core/dataclass/base/result_base.dart';
import 'package:geolocator/geolocator.dart';
import 'core/constants.dart' as constants;


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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TTK App",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
      home: Builder(
        builder: (context) {
          if (!pageData.isPageStable) {
            return const InitializingPage();
          } else {
            return HomePage(pageData: pageData);
          }
        }
      ),
    );
  }

  Future<Result<int>> setLocationPermission() async {

    Result<LocationPermission> permission = await pageData.utilLocation.locationPermission();

    if(!permission.isSuccess) {
      return Result.failure(permission.error);
    }

    pageData.isLocationEnabled = permission.data == LocationPermission.always || permission.data == LocationPermission.whileInUse;


    return Result.success();
  }

  Future<void> appInitialization() async {
    pageData.isPageStable = false;

    await setLocationPermission();

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
    setState(() {
      pageData.isPageStable = true;      
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    return;
  }
}
