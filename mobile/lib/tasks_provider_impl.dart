import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:tasks/tasks.dart';

const String tasksTable = "tasks";
const String tasksColumnId = "_id";
const String tasksColumnTitle = "title";
const String tasksColumnDescription = "description";
const String tasksColumnStartTime = "start_time";
const String tasksColumnEndTime = "end_time";

Map<String, dynamic> toMap(Task task) => {
      tasksColumnId: task.id,
      tasksColumnTitle: task.title,
      tasksColumnDescription: task.description,
      tasksColumnStartTime: task.startTime.toIso8601String(),
      tasksColumnEndTime: task.endTime.toIso8601String(),
    };

Task fromMap(Map map) {
  return new Task(
      map[tasksColumnTitle],
      map[tasksColumnDescription],
      DateTime.parse(map[tasksColumnStartTime]).toUtc(),
      DateTime.parse(map[tasksColumnEndTime]).toUtc(),
      id: map[tasksColumnId]);
}

class TasksProviderImpl implements TasksProvider {
  TasksProviderImpl(this.db);

  final Database db;

  @override
  Future<Task> insert(Task task) async =>
      db.insert(tasksTable, toMap(task)).then((id) => task.copy(id: id));

  @override
  Future<int> delete(int id) async =>
      db.delete(tasksTable, where: "$tasksColumnId = ?", whereArgs: [id]);

  @override
  Future<int> update(Task task) async => db.update(tasksTable, toMap(task),
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
          return new List.unmodifiable(maps.map((map) => fromMap(map)));
        }
        return new List.unmodifiable([]);
      });
}
