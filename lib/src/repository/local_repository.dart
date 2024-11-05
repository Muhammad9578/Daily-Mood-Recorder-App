import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String behaviourHistoryTable = 'behaviour_history';
  String colId = 'id';
  String colMood = 'mood';
  String colActivity = 'activity';
  String colEmotion = 'emotion';
  String colTimestamp = 'timestamp';
  String colYear = 'year';
  String colMonth = 'month';
  String colDay = 'day';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'behaviour_history.db');
    var behaviourHistoryDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return behaviourHistoryDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE $behaviourHistoryTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colMood TEXT,
        $colActivity TEXT,
        $colEmotion TEXT,
        $colTimestamp INTEGER,
        $colYear INTEGER,
        $colMonth INTEGER,
        $colDay INTEGER
      )
    ''');
  }

  Future<int> insertBehaviourHistory(BehaviourHistory behaviourHistory) async {
    Database db = await database;
    var result =
        await db.insert(behaviourHistoryTable, behaviourHistory.toJson());
    return result;
  }

  Future<int> insertBehaviourHistoryInMap(
      Map<String, Object?> behaviourHistory) async {
    Database db = await database;
    // debugLog("insertBehaviourHistoryInMap: $behaviourHistory");
    var result = await db.insert(behaviourHistoryTable, behaviourHistory);
    return result;
  }

  Future<int> deleteBehaviourHistory(int id) async {
    Database db = await database;
    var result = await db
        .delete(behaviourHistoryTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getBehaviourHistoryByTime(
      DateTime start, DateTime end) async {
    Database db = await database;

    //   String query = '''
    //   SELECT * FROM $behaviourHistoryTable
    //   WHERE
    //     ($colYear = ? AND $colMonth > ? OR ($colMonth = ? AND $colDay >= ?))
    //     AND ($colYear = ? AND $colMonth < ? OR ($colMonth = ? AND $colDay <= ?))
    // ''';
    String query = ''' 
    SELECT * FROM $behaviourHistoryTable
    ''';
    debugLog("Query: $query"); // Debugging: Print the constructed query

    List<Map<String, dynamic>> result = await db.rawQuery(query
        // ,
        //  [
        //   start.year,
        //   start.month,
        //   start.month,
        //   start.day,
        //   end.year,
        //   end.month,
        //   end.month,
        //   end.day
        // ]
        );

    debugLog(
        "Result Length: ${result.length}"); // Debugging: Print the number of rows returned
    debugLog("result: $result");
    return result;
    // List<BehaviourHistory> behaviourHistoryList = [];
    // for (Map<String, dynamic> item in result) {
    //   behaviourHistoryList.add(BehaviourHistory.fromJson(item));
    // }

    // return behaviourHistoryList;
  }

  Future<List<Map<String, dynamic>>> getAllBehaviours() async {
    Database db = await database;

    String query = ''' 
    SELECT * FROM $behaviourHistoryTable
  ''';

    // debugLog("Query: $query"); // Debugging: Print the constructed query

    List<Map<String, dynamic>> result = await db.rawQuery(query);

    return result;
  }

  Future<bool> doesTableExist() async {
    Database db = await database;

    final List<Map<String, dynamic>> tables =
        await db.rawQuery("SELECT * from $behaviourHistoryTable");
    if (tables.isNotEmpty) {
      return true;
    } else {
      return false;
    }
    // return tables.isNotEmpty;
  }

  Future<void> deleteAllFromTable() async {
    Database db = await database;

    await db.rawDelete('DELETE FROM $behaviourHistoryTable');
  }
}
