import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

const String tasksTable = "tasks";
const String tasksColumnId = "_id";
const String tasksColumnTitle = "title";
const String tasksColumnDescription = "description";
const String tasksColumnStartTime = "start_time";
const String tasksColumnEndTime = "end_time";

// tasks_tags table
const String tasksTagsTable = "tasks_tags";
const String tasksTagsColumnId = "_id";
const String tasksTagsColumnTaskId = "task_id";
const String tasksTagsColumnTagId = "tag_id";

// TODO(ralph) support adding/removing tags
//const String tasksTagsValues = "task_tag_values";

@immutable
class Task {
  Task(this.title, this.description, this.startTime, this.endTime, {this.id})
      : duration = endTime.difference(startTime);

  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
//  final List<Tag> tags;

  // not persisted, instead calculated at construction
  final Duration duration;

  Map<String, dynamic> toMap() =>
      {
        tasksColumnId: id,
        tasksColumnTitle: title,
        tasksColumnDescription: description,
        tasksColumnStartTime: startTime.toIso8601String(),
        tasksColumnEndTime: endTime.toIso8601String(),
      };

  static Task fromMap(Map map) =>
      new Task(
          map[tasksColumnTitle],
          map[tasksColumnDescription],
          DateTime.parse(map[tasksColumnStartTime]).toUtc(),
          DateTime.parse(map[tasksColumnEndTime]).toUtc(),
          id: map[tasksColumnId]);

  Task copy({int id}) =>
      new Task(
          this.title, this.description, this.startTime, this.endTime, id: id);
}

class TasksProvider {
  TasksProvider(this.db);

  final Database db;

  Future<Task> insert(Task task) async {
    final int id = await db.insert(tasksTable, task.toMap());
    return task.copy(id: id);
  }

//  Future<Task> _insertTags(Task task) async {
//    final StringBuffer buffer = new StringBuffer();
//    for
//    final int id = await db.insert(tasksTable, task.toMap());
//    return task.copy(id: id);
//  }

  Future<Task> get(int id) async {
    List<Map> maps = await db.query(tasksTable,
        columns: [
          tasksColumnId,
          tasksColumnTitle,
          tasksColumnDescription,
          tasksColumnStartTime,
          tasksColumnEndTime
        ],
        where: "$tasksColumnId = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> getAll() async {
    List<Map> maps = await db.query(tasksTable,
        columns: [
          tasksColumnId,
          tasksColumnTitle,
          tasksColumnDescription,
          tasksColumnStartTime,
          tasksColumnEndTime
        ]);
    if (maps.length > 0) {
      List<Task> tasks = <Task>[];
      
      maps.forEach((map) => tasks.add(Task.fromMap(map)));
      return tasks;
    }
    return null;
  }

  Future<int> delete(int id) async =>
      await db.delete(tasksTable, where: "$tasksColumnId = ?", whereArgs: [id]);

  // TODO(ralph) this method will need to be deleted ot changed to keep immutability
  Future<int> update(Task task) async =>
      await db.update(tasksTable, task.toMap(),
          where: "$tasksColumnId = ?", whereArgs: [task.id]);

  // TODO(ralph) support adding/removing tags
  // ===== tags ================================================================

}
