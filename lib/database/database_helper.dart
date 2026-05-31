import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tarefa.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tarefas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTarefa(Tarefa tarefa) async {
    final db = await instance.database;

    return await db.insert(
      'tarefas',
      tarefa.toMap(),
    );
  }

  Future<List<Tarefa>> getTarefas() async {
    final db = await instance.database;

    final result = await db.query('tarefas');

    return result.map((json) => Tarefa.fromMap(json)).toList();
  }

  Future<int> deleteTarefa(int id) async {
    final db = await instance.database;

    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTarefa(Tarefa tarefa) async {
    final db = await instance.database;

    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }
}