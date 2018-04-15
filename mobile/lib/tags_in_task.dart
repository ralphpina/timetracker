import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:tags/tags.dart';

import 'tags_provider_impl.dart';

Iterable<Tag> tagsListFromMaps(List<Map> tagMap) =>
    tagMap.map((map) => fromMap(map));

const String tasksTagsTable = "tasks_tags";
const String tasksTagsColumnId = "_id";
const String tasksTagsColumnTaskId = "task_id";
const String tasksTagsColumnTagId = "tag_id";

abstract class TagsInTaskProvider {
  Future<void> addTag(int taskId, int tagId);

  Future<void> removeTag(int taskId, int tagId);

  Future<List<Tag>> getTagsInTask(int taskId);

  Future<Map<int, List<Tag>>> getTagsInAllTasks();
}

class TagsInTaskProviderImpl implements TagsInTaskProvider {
  TagsInTaskProviderImpl(this.db);

  final Database db;

  @override
  Future<void> addTag(int taskId, int tagId) async {
    if (taskId == null || tagId == null) {
      throw new NoModelIdError(
          'Task or Tag do not have an id. task.id = $taskId tag.id = $tagId');
    }
    db.insert(tasksTagsTable, {
      tasksTagsColumnTaskId: taskId,
      tasksTagsColumnTagId: tagId,
    });
  }

  @override
  Future<void> removeTag(int taskId, int tagId) async {
    if (taskId == null || tagId == null) {
      throw new NoModelIdError(
          'Task or Tag do not have an id. task.id = $taskId tag.id = $tagId');
    }
    db.delete(tasksTagsTable,
        where: '$tasksTagsColumnTaskId = ? AND $tasksTagsColumnTagId = ?',
        whereArgs: [taskId, tagId]);
  }

  @override
  Future<List<Tag>> getTagsInTask(int taskId) async => db
          .rawQuery(
              'SELECT $tagsTable.$tagsColumnId, $tagsTable.$tagsColumnTitle '
              'FROM $tagsTable '
              'INNER JOIN $tasksTagsTable '
              'ON $tasksTagsTable.$tasksTagsColumnTagId = $tagsTable.$tagsColumnId '
              'WHERE $tasksTagsTable.$tasksTagsColumnTaskId = $taskId')
          .then((tags) {
        if (tags.length > 0) {
          return new List.unmodifiable(tagsListFromMaps(tags));
        }
        return [];
      });

  @override
  Future<Map<int, List<Tag>>> getTagsInAllTasks() async => db
          .rawQuery(
              'SELECT $tasksTagsTable.$tasksTagsColumnTaskId, '
              '$tagsTable.$tagsColumnId, '
              '$tagsTable.$tagsColumnTitle '
              'FROM $tagsTable '
              'INNER JOIN $tasksTagsTable '
              'ON $tasksTagsTable.$tasksTagsColumnTagId = $tagsTable.$tagsColumnId')
          .then((data) {
        if (data.length > 0) {
          final Map<int, List<Tag>> tagMap = {};
          for (final row in data) {
            if (tagMap[row[tasksTagsColumnTaskId]] == null) {
              tagMap[row[tasksTagsColumnTaskId]] = <Tag>[];
            }
            tagMap[row[tasksTagsColumnTaskId]].add(fromMap(row));
          }
          return tagMap;
        }
        return {};
      });
}

class NoModelIdError extends Error {
  final Object message;

  NoModelIdError([this.message]);

  String toString() => "NoModelIdError: $message";
}
