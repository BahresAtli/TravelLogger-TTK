import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final String text;
  final double fontSize;

  const CommonText({
    super.key,
    required this.text,
    required this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
      ),
      textAlign: TextAlign.center,
    );
  }
}