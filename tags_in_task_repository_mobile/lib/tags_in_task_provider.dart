import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:tags/tags.dart';
import 'package:tags_repository_mobile/tags_provider.dart';
import 'package:base/base.dart';

Iterable<Tag> tagsListFromMaps(List<Map> tagMap) =>
    tagMap.map((map) => fromMap(map));

const String tasksTagsTable = "tasks_tags";
const String tasksTagsColumnId = "_id";
const String tasksTagsColumnTaskId = "task_id";
const String tasksTagsColumnTagId = "tag_id";

/// tags in task provider
abstract class TagsInTaskProvider {
  /// add a tag to a task
  Future<void> addTag(int taskId, int tagId);
  /// remove a tag from a task
  Future<void> removeTag(int taskId, int tagId);
  /// get the tags in a task
  Future<List<Tag>> getTagsInTask(int taskId);
  /// get all tags and map it to their task
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
