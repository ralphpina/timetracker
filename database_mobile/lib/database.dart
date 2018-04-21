library database_mobile;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tags_repository_mobile/tags_provider.dart';
import 'package:tasks_repository_mobile/tasks_provider.dart';
import 'package:tags_in_task_repository_mobile/tags_in_task_provider.dart';

const String _DB_PATH = "timetracker.db";

Database _db;
TagsProvider _tagsProvider;
TasksProvider _tasksProvider;
TagsInTaskProvider _tagsInTaskProvider;

Future<TagsProvider> get tagsProvider async => await _initDb().then((_) => _tagsProvider);
Future<TasksProvider> get tasksProvider async => await _initDb().then((_) => _tasksProvider);
Future<TagsInTaskProvider> get tagsInTaskProvider async => await _initDb().then((_) => _tagsInTaskProvider);

Future<void> _initDb() async {
  if (_db == null) {
    print("Initing DB");
    _db = await _openDb(_DB_PATH);
    _tagsProvider = new TagsProviderImpl(_db);
    _tasksProvider = new TasksProviderImpl(_db);
    _tagsInTaskProvider = new TagsInTaskProviderImpl(_db);
  }
}

void closeDb() async {
  print("Closing DB");
  await _db?.close();
  _db = null;
  _tagsProvider = null;
  _tasksProvider = null;
  _tagsInTaskProvider = null;
}

Future<Database> _openDb(String dbPath) async {
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String path = join(documentsDirectory.path, dbPath);

  print("Opening DB");
  return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
            CREATE TABLE $tagsTable ( 
            $tagsColumnId INTEGER PRIMARY KEY AUTOINCREMENT, 
            $tagsColumnTitle TEXT NOT NULL)
            ''');
        await db.execute('''
            CREATE TABLE $tasksTable ( 
            $tasksColumnId INTEGER PRIMARY KEY AUTOINCREMENT, 
            $tasksColumnTitle TEXT NOT NULL,
            $tasksColumnDescription TEXT,
            $tasksColumnStartTime TEXT NOT NULL,
            $tasksColumnEndTime TEXT NOT NULL)
            ''');
        await db.execute('''
            CREATE TABLE $tasksTagsTable ( 
            $tasksTagsColumnId INTEGER PRIMARY KEY AUTOINCREMENT, 
            $tasksTagsColumnTaskId INTEGER,
            $tasksTagsColumnTagId INTEGER,
            FOREIGN KEY($tasksTagsColumnTaskId) REFERENCES $tasksTable($tasksColumnId) ON DELETE CASCADE,
            FOREIGN KEY($tasksTagsColumnTagId) REFERENCES $tagsTable($tagsColumnId) ON DELETE CASCADE)
            ''');
      });
}
