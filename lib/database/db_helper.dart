import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

class DatabaseHelper {
  DatabaseHelper();

  static Database? _database;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initializeDB();

  Future<Database> _initializeDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "TTK.db");
    return await openDatabase(path, version: 1, onCreate: createTables);
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

}
