import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/call_log_model.dart';

class CallLogDB {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'call_logs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE call_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contactId TEXT,
            callType TEXT,
            mediaType TEXT,
            timestamp INTEGER,
            duration INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertCallLog(CallLogModel callLog) async {
    final db = await database;
    await db.insert('call_logs', callLog.toMap());
  }

  Future<List<CallLogModel>> getAllCallLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'call_logs',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => CallLogModel.fromMap(maps[i]));
  }

  Future<List<CallLogModel>> getCallLogsByContact(String contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'call_logs',
      where: 'contactId = ?',
      whereArgs: [contactId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => CallLogModel.fromMap(maps[i]));
  }

  Future<void> deleteCallLog(int id) async {
    final db = await database;
    await db.delete('call_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllCallLogs() async {
    final db = await database;
    await db.delete('call_logs');
  }
}
