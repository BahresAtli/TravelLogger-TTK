class TimeUtility {
  
  final Stopwatch _stopwatch = Stopwatch();

  void start() {
    _stopwatch.start();
  }

  int stop() {
    _stopwatch.stop();
    int lastTime = _stopwatch.elapsedMilliseconds;
    _stopwatch.reset();
    return lastTime;
  }

  Duration _getElapsedAsDuration(int? milliSeconds) {
    if (milliSeconds != null) return Duration(milliseconds: milliSeconds);
    return Duration(milliseconds: _stopwatch.elapsedMilliseconds);
  }

  String formatElapsedToText(int? milliseconds) {
    Duration currentTime = _getElapsedAsDuration(milliseconds);

    String padding(int n) => n.toString().padLeft(2, "0");


    String hours = padding(currentTime.inHours.remainder(24).abs());
    String minutes = padding(currentTime.inMinutes.remainder(60).abs());
    String seconds = padding(currentTime.inSeconds.remainder(60).abs());
    
    return "$hours:$minutes:$seconds";

  }
}