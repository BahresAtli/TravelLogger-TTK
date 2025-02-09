import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isPressed = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  int lastTime = 0;

  @override  
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeText(),
              const SizedBox(height: 10),
              _startButton(),
              const SizedBox(height: 10),
              _lastData(),
            ],
          ),
        ),
      ),
    );
  }

  Container _timeText() {
    String textField = '-'; 
    if (isPressed == true) {
      int time = stopwatch.elapsedMilliseconds; 
      textField = time.toString();
    }
    return Container(
      child: _commonText(textField, 30)
    );
  }

  TextButton _startButton() {
  return TextButton(
      onPressed: () {
        setState((){
          if (isPressed == false) {
            stopwatch.start();
            timer = Timer.periodic(const Duration(milliseconds: 1), (Timer t) {
            setState(() {}); 
            });
          }
          else {
            stopwatch.stop();
            lastTime = stopwatch.elapsedMilliseconds;
            stopwatch.reset();
            timer?.cancel();
          }

          isPressed = !isPressed; 
          },
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(150, 50),
      ),
      child: isPressed ? _commonText('Finish', 20) : _commonText('Start', 20) ,
    );
  }

  Container _lastData() {
    String textField = 'Last Measured Time: ' + lastTime.toString(); 

    return Container(
      child: _commonText(textField, 20)
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
