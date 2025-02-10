import 'dart:async';
import 'package:flutter/material.dart';
import 'core/time_ttk.dart';

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
  Timer? timer;
  TimeTTK timeTTK = TimeTTK();

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
      textField = timeTTK.formatElapsedToText(null);
    }
    return Container(
      width: 250,
      //padding: isPressed ? const EdgeInsets.only(left: 58) : null,
      alignment: /*isPressed ? null :*/ Alignment.center,
      child: _commonText(textField, 30),
      );
  }

  TextButton _startButton() {
    return TextButton(
      onPressed: () {
        setState(
          () {
            if (isPressed == false) {
              timeTTK.start();
              timer =
                  Timer.periodic(const Duration(milliseconds: 1), (Timer t) {
                setState(() {});
              });
            } else {
              timeTTK.stop();
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
      child: isPressed ? _commonText('Finish', 20) : _commonText('Start', 20),
    );
  }

  Container _lastData() {
    String textField = 'Last Measured Time: ${timeTTK.formatElapsedToText(timeTTK.lastTime)}';

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
}
