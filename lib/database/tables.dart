import 'package:sqflite/sqflite.dart';

Future<void> createTables(Database db, int version) async {
  await db.execute('''
          PRAGMA foreign_keys = ON;
          ''');

  await db.execute('''
          CREATE TABLE mainTable (
            recordID INTEGER PRIMARY KEY,
            startTime TEXT,
            endTime TEXT,
            elapsedMilisecs INTEGER,
            startLatitude TEXT,
            startLongitude TEXT,
            endLatitude TEXT,
            endLongitude TEXT
          )
          ''');

  await db.execute('''
          CREATE TABLE location (
            locationRecordID INTEGER PRIMARY KEY,
            recordID INTEGER,
            locationOrder INTEGER,
            latitude TEXT,
            longitude TEXT,
            timeAtInstance TEXT,
            FOREIGN KEY(recordID) REFERENCES recordsTTK(recordID)
          )
          ''');
}
