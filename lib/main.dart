import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterForegroundTask.initCommunicationPort();
  runApp(const MaterialApp(home: MainApp())); //for making AlertDialog work
}

