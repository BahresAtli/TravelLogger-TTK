import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper();

  static Database? _database;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initializeDB();

  Future<Database> _initializeDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "TTK.db");
    return await openDatabase(path, version: 1, onCreate: initializeTables);
  }

  Future<void> initializeTables(Database db, int version) async {

    String sqlCommand = await rootBundle.loadString("lib/core/database/sql/init/foreign_keys.sql");
    await db.execute(sqlCommand);

    await initializeTable(db, "mainTable");
    await initializeTable(db, "location");

  }

  Future<void> initializeTable(Database db, String table) async {
      String sqlCommand = await rootBundle.loadString('lib/core/database/sql/create/$table.sql');
      await db.execute(sqlCommand);
  }

  Future<void> initializeNewColumns() async {
    //new column handling will be automated in the future.

    //columns for altitude and speed update
    await addColumn("startAltitude", "mainTable");
    await addColumn("endAltitude", "mainTable");
    await addColumn("altitude", "location");
    await addColumn("speed", "location");

    
  }

  Future<List<Map<String, dynamic>>> select(String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    return await db.query(table);
  }

  Future<int> insert(Map<String, dynamic> row, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    return await db.insert(table, row);
  }

  Future<int> update(Map<String, dynamic> row, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    int id = row['recordID'];
    return await db.update(table, row, where: 'recordID = ?', whereArgs: [id]);
  }


  Future<int> delete(int id, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    return await db.delete(table, where: 'recordID = ?' , whereArgs: [id]);
  }

  Future<void> addColumn(String rowName, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    bool doesExist = true;
    final result = await db.rawQuery('PRAGMA table_info($table)');
    for (var column in result) {
      if (column['name'] != rowName) {
        doesExist = false;
      } else {
        doesExist = true;
        break;
      }
    }
    if (!doesExist) {
        await db.execute('''
          ALTER TABLE $table ADD COLUMN $rowName;
          ''');
    }
  }

  Future<void> addTable(String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    bool doesExist = true;
    final result = await db.rawQuery('PRAGMA table_list');
    for (var column in result) {
      if (column['name'] != table) {
        doesExist = false;
      } else {
        doesExist = true;
        break;
      }
    }
    if (!doesExist) {
      String sqlCommand = await rootBundle.loadString('lib/core/database/sql/create/$table.sql');
      await db.execute(sqlCommand);
    }
  }
}

