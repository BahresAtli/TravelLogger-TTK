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
    await initializeTable(db, "appConfig");

  }

  Future<void> initializeTable(Database db, String table) async {
      String sqlCommand = await rootBundle.loadString('lib/core/database/sql/create/$table.sql');
      await db.execute(sqlCommand);
  }

  Future<void> initializeNewColumns(String version) async {
    //new column handling will be automated in the future.
    switch(version){
      case '0.0.1':
        await refreshTable("mainTable");
        await refreshTable("location");

        await initializeNewColumns('0.0.0');
        break;
      case '0.0.0':
        break;
      default:
        break;
    }


    //columns for altitude and speed update


    //columns for travel type
    //await addColumn("travelType", "mainTable", "INT");

    
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

  Future<int> update(Map<String, dynamic> row, String table, String idName) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    int id = row[idName];
    return await db.update(table, row, where: '$idName = ?', whereArgs: [id]);
  }


  Future<int> delete(int id, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    return await db.delete(table, where: 'recordID = ?' , whereArgs: [id]);
  }

  Future<void> addColumn(String columnName, String table, String type) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    bool doesExist = true;
    final result = await db.rawQuery('PRAGMA table_info($table)');
    for (var column in result) {
      if (column['name'] != columnName) {
        doesExist = false;
      } else {
        doesExist = true;
        break;
      }
    }
    if (!doesExist) {
        await db.execute('''
          ALTER TABLE $table ADD COLUMN $columnName $type;
          ''');
    }
  }

  Future<void> addTable(String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    bool doesExist = await doesTableExist(db, table);

    if (!doesExist) {
      String sqlCommand = await rootBundle.loadString('lib/core/database/sql/create/$table.sql');
      await db.execute(sqlCommand);
    }
  }

  Future<bool> doesTableExist(Database db, String table) async {
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
    return doesExist;
  }

  Future<void> refreshTable(String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    bool doesExist = await doesTableExist(db, table);

    if(!doesExist) {
      print("The specified table $table does not exist.");
      return;
    }
    String sqlCommand = await rootBundle.loadString('lib/core/database/sql/refresh/refresh_$table.sql');
    await executeMultipleQueries(db, sqlCommand);
    print("Table refreshing finished for the table $table");
    return;
  }

  Future<void> executeMultipleQueries(Database db, String multipleQueryString) async {
    List<String> queries = multipleQueryString.split(';');
    for (int i = 0; i < queries.length - 1; i++) {
      await db.execute(queries[i]);
    }

    return;
  }
}


