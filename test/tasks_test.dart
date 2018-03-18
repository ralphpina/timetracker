//import 'dart:io';
//import 'package:flutter/services.dart';

import 'package:test/test.dart';
import 'package:timetracker/tasks.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:timetracker/database_helper.dart';

void main() {
  test('Convert from a map', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Map<String, dynamic> map = {
      tasksColumnId: 2,
      tasksColumnTitle: "some title",
      tasksColumnDescription: "some description",
      tasksColumnStartTime: now.toIso8601String(),
      tasksColumnEndTime: nowPlusHour.toIso8601String()
    };

    final Task task = Task.fromMap(map);

    expect(task.id, 2);
    expect(task.title, "some title");
    expect(task.description, "some description");
    expect(task.startTime, now);
    expect(task.endTime, nowPlusHour);
  });

  test('Convert to map', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        "some title",
        "some description",
        now,
        nowPlusHour,
        id: 1);

    final Map<String, dynamic> map = task.toMap();

    expect(map[tasksColumnId], 1);
    expect(map[tasksColumnTitle], "some title");
    expect(map[tasksColumnDescription], "some description");
    expect(map[tasksColumnStartTime], now.toIso8601String());
    expect(map[tasksColumnEndTime], nowPlusHour.toIso8601String());
  });

  test('Calculates duration', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        "some title",
        "some description",
        now,
        nowPlusHour,
        id: 1);

    expect(task.duration, new Duration(hours: 1));
  });

  test('Copy gives you new object', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        "some title",
        "some description",
        now,
        nowPlusHour);

    final Task another = task.copy(id: 1);

    expect(task.id, isNull);
    expect(another.id, 1);
    expect(task.title, another.title);
    expect(task.description, another.description);
    expect(task.startTime, another.startTime);
    expect(task.endTime, another.endTime);
  });

  // TODO(ralph) find a way to test path_provider.getApplicationDocumentsDirectory()
//  group('Test TaskProvider', () {
//    Directory directory;
//    Database db;
//    TasksProvider tasksProvider;
//
//    setUpAll(() async {
//
//      // Create a temporary directory to work with
//      directory = await Directory.systemTemp.createTemp();
//
//      // Mock out the MethodChannel for the path_provider plugin
//      const MethodChannel('plugins.flutter.io/path_provider')
//          .setMockMethodCallHandler((MethodCall methodCall) async {
//        // If we're getting the apps documents directory, return the path to the
//        // temp directory on our test environment instead.
//        if (methodCall.method == 'getApplicationDocumentsDirectory') {
//          return directory.path;
//        }
//        return null;
//      });
//
//      // Connects to the db
//      db = await openDb(directory.path);
//      tasksProvider = new TasksProvider(db);
//    });
//
//    tearDownAll(() async {
//      if (db != null) {
//        // Closes the connection
//        await db.close();
//        db = null;
//        await deleteDatabase(directory.path);
//      }
//    });
//
//
//    test('Copy gives you new object', () async {
//      final DateTime now = DateTime.now().toUtc();
//      final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();
//
//      final Task task = new Task(
//          "some title",
//          "some description",
//          now,
//          nowPlusHour);
//
//      final Task newTask = await tasksProvider.insert(task);
//
//      expect(task.id, isNull);
//      expect(newTask.id, 1);
//      expect(task.title, newTask.title);
//      expect(task.description, newTask.description);
//      expect(task.startTime, newTask.startTime);
//      expect(task.endTime, newTask.endTime);
//    });
//  });
}
