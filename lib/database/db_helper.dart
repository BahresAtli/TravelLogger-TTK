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


  Future<int> delete(int id, String table) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    return await db.delete(table, where: 'recordID = ?' , whereArgs: [id]);
  }


}
