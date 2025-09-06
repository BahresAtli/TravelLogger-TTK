import 'package:flutter/material.dart';
import 'package:ttkapp/pages/widgets/common_text.dart';

class CommonSnackbar {

  static SnackBar create(String text) {
    return SnackBar(
      content: CommonText(text: text, fontSize: 16),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 70, 70, 70),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}