import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import 'tags.dart';

const String tasksTable = "tasks";
const String tasksColumnId = "_id";
const String tasksColumnTitle = "title";
const String tasksColumnDescription = "description";
const String tasksColumnStartTime = "start_time";
const String tasksColumnEndTime = "end_time";

@immutable
class Task {
  Task(this.title, this.description, this.startTime, this.endTime, {this.id});

  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  // not persisted, instead calculated at construction
  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() => {
        tasksColumnId: id,
        tasksColumnTitle: title,
        tasksColumnDescription: description,
        tasksColumnStartTime: startTime.toIso8601String(),
        tasksColumnEndTime: endTime.toIso8601String(),
      };

  static Task fromMap(Map map) {
    return new Task(
        map[tasksColumnTitle],
        map[tasksColumnDescription],
        DateTime.parse(map[tasksColumnStartTime]).toUtc(),
        DateTime.parse(map[tasksColumnEndTime]).toUtc(),
        id: map[tasksColumnId]);
  }

  Task copy({int id}) =>
      new Task(this.title, this.description, this.startTime, this.endTime,
          id: id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
}

abstract class TasksProvider {
  Future<Task> insert(Task task);

  Future<int> delete(int id);

  Future<int> update(Task task);

  Future<List<Task>> getAllTasks();
}

class TasksProviderImpl implements TasksProvider {
  TasksProviderImpl(this.db);

  final Database db;

  @override
  Future<Task> insert(Task task) async =>
      db.insert(tasksTable, task.toMap()).then((id) => task.copy(id: id));

  @override
  Future<int> delete(int id) async =>
      db.delete(tasksTable, where: "$tasksColumnId = ?", whereArgs: [id]);

  @override
  Future<int> update(Task task) async => db.update(tasksTable, task.toMap(),
      where: "$tasksColumnId = ?", whereArgs: [task.id]);

  @override
  Future<List<Task>> getAllTasks() async => db.query(tasksTable, columns: [
        tasksColumnId,
        tasksColumnTitle,
        tasksColumnDescription,
        tasksColumnStartTime,
        tasksColumnEndTime
      ]).then((maps) {
        if (maps.length > 0) {
          return new List.unmodifiable(maps.map((map) => Task.fromMap(map)));
        }
        return new List.unmodifiable([]);
      });

// TODO return an Observable with task
//  Future<Task> getTask(int id) async {
//    final List<Map> maps = await db.query(tasksTable,
//        columns: [
//          tasksColumnId,
//          tasksColumnTitle,
//          tasksColumnDescription,
//          tasksColumnStartTime,
//          tasksColumnEndTime
//        ],
//        where: "$tasksColumnId = ?",
//        whereArgs: [id]);
//    if (maps.length > 0) {
//      return Task.fromMap(maps.first);
//    }
//    return null;
//  }
}
