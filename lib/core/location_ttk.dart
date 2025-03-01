import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationTTK {
  LocationPermission? permission;
  Position? currentPosition;

  Future<bool> locationPermission() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false; //Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false; //Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false; //Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }



  Future<Position> getPosition() async {
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
        currentPosition = await Geolocator.getCurrentPosition();
      return await Geolocator.getCurrentPosition();
    }
    currentPosition = null;
    return Future.error('location denied');
  }
  //not really used currently
  void changeLocation(bool run) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await getPosition();
    });

  }

  String convertPositionToString() {
    
    return '${currentPosition?.latitude.toString()} ${currentPosition?.longitude.toString()}';
  }

}
