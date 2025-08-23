import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import '../../data/result_base.dart';

class LocationTTK {

  LocationPermission permission = LocationPermission.denied;
  Position? currentPosition;
  StreamSubscription? subscription;
  bool isLocationEnabled = false;

  Future<Result<LocationPermission>> locationPermission() async {

    bool serviceEnabled;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Result.success(LocationPermission.denied);
    }

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.unableToDetermine) {
      return Result.failure("Unable to determine location status.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    isLocationEnabled = permission == LocationPermission.always || permission == LocationPermission.whileInUse;

    return Result.success(permission);
  }

  void startListeningLocation() {
    if(isLocationEnabled) {
      subscription = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
          intervalDuration: const Duration(seconds:1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'ttkApp', 
            notificationText: 'ttkapp is getting the Location',
            enableWakeLock: true,
            )
        )
      ).listen((event) async {
        currentPosition = event;
      });

    } else {
      return;
    }

  }


  Future<Position?> getPosition() async {
    if (isLocationEnabled) {
        currentPosition = await Geolocator.getCurrentPosition();
      return await Geolocator.getCurrentPosition();
    }
    return null;
  }

  //deprecated
  void changeLocation(bool run) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await getPosition();
    });

  }

  Future<double> calculateDistance(Position? prev, Position? curr) async { 
    if (prev == null || curr == null) return 0.0;
    
    double distance = Geolocator.distanceBetween(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );

    return distance;
  }

  String convertPositionToString(AppLocalizations? message) {

    if (!isLocationEnabled) {
      return message!.locationDisabled;
    }

    if (currentPosition == null) {
      return message!.waitAvailableLocation;
    }

    return '${currentPosition?.latitude.toStringAsFixed(7)}, ${currentPosition?.longitude.toStringAsFixed(7)}, ${currentPosition?.altitude.toStringAsFixed(2)}';
  }

}
