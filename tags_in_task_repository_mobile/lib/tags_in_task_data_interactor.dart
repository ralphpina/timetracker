import 'dart:async';

import 'package:tags/tags.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tags_in_task/tags_in_task.dart';

abstract class TagsInTaskDataInteractor {
  Future<void> addTagToTask(int taskId, int tagId);

  Future<void> removeTagFromTask(int taskId, int tagId);

  Observable<List<TagInTask>> getAllTagsForTaskObservable(int taskId);

  Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable();
}