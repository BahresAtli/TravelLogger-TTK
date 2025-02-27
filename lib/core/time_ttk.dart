import 'dart:async';

class TimeTTK {
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  int lastTime = 0;

  void start() {
    stopwatch.start();
  }

  void stop() {
    stopwatch.stop();
    lastTime = stopwatch.elapsedMilliseconds;
    stopwatch.reset();
  }

  Duration getElapsedAsDuration(int? milliSeconds) {
    if (milliSeconds != null) return Duration(milliseconds: milliSeconds);
    return Duration(milliseconds: stopwatch.elapsedMilliseconds);
  }

  String formatElapsedToText(int? milliseconds) {
    Duration currentTime = getElapsedAsDuration(milliseconds);

    String padding(int n) => n.toString().padLeft(2, "0");
    //String padMsec(int n) => n.toString().padLeft(3, "0");


    String hours = padding(currentTime.inHours.remainder(24).abs());
    String minutes = padding(currentTime.inMinutes.remainder(60).abs());
    String seconds = padding(currentTime.inSeconds.remainder(60).abs());
    //String milliSeconds = padMsec(currentTime.inMilliseconds.remainder(1000).abs());
    return "$hours:$minutes:$seconds";

  }
}