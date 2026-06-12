import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/game_session.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'math_quest_kids.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            month TEXT NOT NULL,
            correctAnswers INTEGER NOT NULL,
            totalQuestions INTEGER NOT NULL,
            difficulty TEXT NOT NULL,
            rate REAL NOT NULL,
            basePoints REAL NOT NULL,
            bonus REAL NOT NULL,
            finalScore REAL NOT NULL,
            dateCreated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertSession(GameSession session) async {
    final db = await database;
    return db.insert('sessions', session.toMap()..remove('id'));
  }

  Future<List<GameSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('sessions', orderBy: 'id DESC');
    return maps.map((m) => GameSession.fromMap(m)).toList();
  }

  Future<int> updateSession(GameSession session) async {
    final db = await database;
    return db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}
