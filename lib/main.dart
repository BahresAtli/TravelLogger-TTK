import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:logging/logging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL; // hangi seviyeden itibaren loglansın?
  Logger.root.onRecord.listen((record) {
    //ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
  runApp(const MaterialApp(home: MainApp()));
}

