import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

import 'tags.dart';

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

@immutable
class Task {
  Task(this.title, this.description, this.startTime, this.endTime,
      {this.id, this.tags});

  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  final List<Tag> tags;

  // not persisted, instead calculated at construction
  Duration get duration => endTime.difference(startTime);

  bool get hasTags => tags != null && tags.isNotEmpty;

  Map<String, dynamic> toMap() => {
        tasksColumnId: id,
        tasksColumnTitle: title,
        tasksColumnDescription: description,
        tasksColumnStartTime: startTime.toIso8601String(),
        tasksColumnEndTime: endTime.toIso8601String(),
      };

  static Task fromMap(Map map, List<Map> tagMap) {
    final tags = tagMap.map((map) => Tag.fromMap(map));
    return new Task(
        map[tasksColumnTitle],
        map[tasksColumnDescription],
        DateTime.parse(map[tasksColumnStartTime]).toUtc(),
        DateTime.parse(map[tasksColumnEndTime]).toUtc(),
        id: map[tasksColumnId],
        tags: new List.unmodifiable(tags));
  }

  Task copy({int id}) =>
      new Task(this.title, this.description, this.startTime, this.endTime,
          id: id, tags: this.tags);

  Task addTag(Tag tag) {
    final List<Tag> list = this.tags == null ? [] : new List.from(this.tags);
    list.add(tag);
    return new Task(this.title, this.description, this.startTime, this.endTime,
        id: this.id, tags: new List.unmodifiable(list));
  }

  Task removeTag(Tag tag) {
    final List<Tag> list = new List.from(this.tags);
    list.removeWhere((current) => current.id == tag.id);
    return new Task(this.title, this.description, this.startTime, this.endTime,
        id: this.id, tags: new List.unmodifiable(list));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          tags == other.tags;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      tags.hashCode;
}

class TasksProvider {
  TasksProvider(this.db);

  final Database db;

  BehaviorSubject<List<Task>> tasksBehaviorSubject;

  // TODO implement map for specific tasks
//  BehaviorSubject<Map<int, Task>> taskBehaviorSubject;

  Future<Task> insert(Task task) async {
    final int id = await db.insert(tasksTable, task.toMap());
    // update listeners
    _broadcastAllTasks();
    return task.copy(id: id);
  }

  Future<Task> get(int id) async {
    final List<Map> maps = await db.query(tasksTable,
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
      final List<Map> tags = await _getTags(maps.first[tasksColumnId]);
      return Task.fromMap(maps.first, tags);
    }
    return null;
  }

  Observable<List<Task>> getAllTasksObservable() {
    if (tasksBehaviorSubject == null) {
      tasksBehaviorSubject = new BehaviorSubject<List<Task>>();
      _broadcastAllTasks();
    }
    return tasksBehaviorSubject.observable;
  }

  Future<int> delete(int id) async {
    final int idAffected = await db
        .delete(tasksTable, where: "$tasksColumnId = ?", whereArgs: [id]);
    _broadcastAllTasks();
    return idAffected;
  }

  Future<int> update(Task task) async {
    final int idAffected = await db.update(tasksTable, task.toMap(),
        where: "$tasksColumnId = ?", whereArgs: [task.id]);
    _broadcastAllTasks();
    return idAffected;
  }

  // ===== internal ============================================================

  void _broadcastAllTasks() {
    // is anyone listening?
    if (tasksBehaviorSubject != null) {
      _getAll().then((tasks) => tasksBehaviorSubject.add(tasks));
    }
  }

  Future<List<Task>> _getAll() async {
    final List<Map> maps = await db.query(tasksTable, columns: [
      tasksColumnId,
      tasksColumnTitle,
      tasksColumnDescription,
      tasksColumnStartTime,
      tasksColumnEndTime
    ]);
    if (maps.length > 0) {
      final List<Task> tasks = <Task>[];
      for (Map map in maps) {
        final List<Map> tags = await _getTags(maps.first[tasksColumnId]);
        tasks.add(Task.fromMap(map, tags));
      }
      return tasks;
    }
    return null;
  }

  // ===== tags ================================================================

  Future<Task> addTag(Task task, Tag tag) async {
    if (task.id == null || tag.id == null) {
      throw new NoModelIdError(
          'Task or Tag do not have an id. task.id = ${task.id} tag.id = ${tag
              .id}');
    }
    await db.insert(tasksTagsTable, {
      tasksTagsColumnTaskId: task.id,
      tasksTagsColumnTagId: tag.id,
    });
    return task.addTag(tag);
  }

  Future<Task> removeTag(Task task, Tag tag) async {
    if (task.id == null || tag.id == null) {
      throw new NoModelIdError(
          'Task or Tag do not have an id. task.id = ${task.id} tag.id = ${tag
              .id}');
    }
    await db.delete(tasksTagsTable,
        where: '$tasksTagsColumnTaskId = ? AND $tasksTagsColumnTagId = ?',
        whereArgs: [task.id, tag.id]);
    return task.removeTag(tag);
  }

  Future<List<Map>> _getTags(int taskId) async {
    try {
      final List<Map> tags = await db.rawQuery(
          'SELECT $tagsColumnId, $tagsColumnTitle '
          'FROM $tagsTable '
          'INNER JOIN $tasksTagsTable '
          'ON $tasksTagsTable.$tasksTagsColumnTagId = $tagsTable.$tagsColumnId '
          'WHERE $tasksTagsTable.$tasksTagsColumnTaskId = $taskId');
      if (tags.length > 0) {
        return tags;
      }
    } on DatabaseException {
      // noop if there's no tags for this tag, it will throw
    }
    return [];
  }
}

class NoModelIdError extends Error {
  final Object message;

  NoModelIdError([this.message]);

  String toString() => "NoModelIdError: $message";
}
