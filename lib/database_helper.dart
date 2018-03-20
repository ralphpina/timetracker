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
            create table $tagsTable ( 
            $tagsColumnId integer primary key autoincrement, 
            $tagsColumnTitle text not null)
            ''');
        await db.execute('''
            create table $tasksTable ( 
            $tasksColumnId integer primary key autoincrement, 
            $tasksColumnTitle text not null,
            $tasksColumnDescription text,
            $tasksColumnStartTime text not null,
            $tasksColumnEndTime text not null)
            ''');
        await db.execute('''
            create table $tasksTagsTable ( 
            $tasksTagsColumnId integer primary key autoincrement, 
            $tasksTagsColumnTaskId text not null,
            $tasksTagsColumnTagId text not null)
            ''');
      });
}
