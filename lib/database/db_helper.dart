import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class DBHelper {

  static Database? _db;

  Future<Database> get db async {

    if (_db != null) return _db!;

    _db = await initDb();
    return _db!;
  }

  initDb() async {

    String path = join(await getDatabasesPath(), "contacts.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
        CREATE TABLE contacts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          uniqueId TEXT,
          image TEXT
        )
        ''');
      },
    );
  }

  Future insert(ContactModel contact) async {
    final dbClient = await db;
    await dbClient.insert("contacts", contact.toMap());
  }

  Future<List<ContactModel>> getContacts() async {
    final dbClient = await db;

    final maps = await dbClient.query("contacts");

    return maps.map((e) => ContactModel.fromMap(e)).toList();
  }

  Future update(ContactModel contact) async {
    final dbClient = await db;

    await dbClient.update(
      "contacts",
      contact.toMap(),
      where: "id=?",
      whereArgs: [contact.id],
    );
  }

  Future delete(int id) async {
    final dbClient = await db;

    await dbClient.delete(
      "contacts",
      where: "id=?",
      whereArgs: [id],
    );
  }
}