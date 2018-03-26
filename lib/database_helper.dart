import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';

import 'tags.dart';
import 'tasks.dart';

const String _DB_PATH = "timetracker.db";

Database _db;
TagsProvider _tagsProvider;
TasksProvider _tasksProvider;

Future<TasksProvider> get taskProvider async {
  await _initDb();
  return _tasksProvider;
}

Future<TagsProvider> get tagProvider async {
  await _initDb();
  return _tagsProvider;
}

Future<Null> _initDb() async {
  if (_db == null) {
    debugPrint("Initing DB");
    _db = await openDb(_DB_PATH);
    _tagsProvider = new TagsProvider(_db);
    _tasksProvider = new TasksProvider(_db);
  }
}

void closeDb() async {
  debugPrint("Closing DB");
  await _db?.close();
  _db = null;
  _tagsProvider = null;
  _tasksProvider = null;
}

@visibleForTesting
Future<Database> openDb(String dbPath) async {
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String path = join(documentsDirectory.path, dbPath);

  debugPrint("Opening DB");
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
            $tasksTagsColumnTagId INTEGER),
            FOREIGN KEY(tasksTagsColumnTaskId) REFERENCES $tasksTable($tasksColumnId) ON DELETE CASCADE,
            FOREIGN KEY(tasksTagsColumnTagId) REFERENCES $tagsTable($tagsColumnId) ON DELETE CASCADE
            ''');
      });
}
