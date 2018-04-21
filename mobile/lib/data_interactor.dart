import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tags/tags.dart';
import 'package:tags_in_task/tags_in_task.dart';
import 'package:tags_in_task_mobile/tags_in_task_data_interactor_impl.dart';
import 'package:tags_in_task_repository_mobile/tags_in_task_data_interactor.dart';
import 'package:tags_mobile/tags_data_interactor_impl.dart';
import 'package:tags_repository_mobile/tags_data_interactor.dart';
import 'package:tasks/tasks.dart';
import 'package:tasks_mobile/tasks_data_interactor_impl.dart';
import 'package:tasks_repository_mobile/tasks_data_interactor.dart';
import 'package:database_mobile/database.dart';

// ===== IMPLEMENTATION ========================================================

class DataInteractorImpl
    implements TagsDataInteractor, TasksDataInteractor, TagsInTaskDataInteractor {

  BehaviorSubject<List<Task>> tasksBehaviorSubject;
  BehaviorSubject<List<Tag>> tagsBehaviorSubject;
  BehaviorSubject<Map<int, List<Tag>>> allTagsForAllTasksBehaviorSubjectMap;
  final Map<int, BehaviorSubject<List<TagInTask>>>
      tagsForTaskBehaviorSubjectMap = <int, BehaviorSubject<List<TagInTask>>>{};

  init() {
    print("Initing DataInteractorImpl and injecting implemenation");
    tagsDataInteractor = this;
    tasksDataInteractor = this;
    tagsInTaskDataInteractor = this;
  }

  // ===== Tasks ===============================================================

  @override
  Future<Task> insertTask(Task task) async {
    final Task newTask =
        await tasksProvider.then((provider) => provider.insert(task));
    // tell UI about new tasks
    _broadcastAllTasks();
    return newTask;
  }

  @override
  Future<void> deleteTask(int id) async => await tasksProvider
          .then((provider) => provider.delete(id))
          .then((_) {
        _broadcastAllTasks();
        _broadcastAllTagsForTask(id);
        // a stale task id here might be OK. But to
        // be on the safe side, lets kick off the query.
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTask(Task task) async => await tasksProvider
      .then((provider) => provider.update(task))
      .then((_) => _broadcastAllTasks());

  @override
  Observable<List<Task>> getAllTasksObservable() {
    if (tasksBehaviorSubject == null) {
      tasksBehaviorSubject = new BehaviorSubject<List<Task>>(seedValue: []);
      _broadcastAllTasks();
    }
    return tasksBehaviorSubject.observable;
  }

  void _broadcastAllTasks() {
    // is anyone listening?
    if (tasksBehaviorSubject != null) {
      tasksProvider
          .then((provider) => provider.getAllTasks())
          .then((tasks) {
            print("=== tasks = " + tasks.toString());
            tasksBehaviorSubject.add(tasks);
      });
    }
  }

  // ===== Tags ================================================================

  @override
  Future<Tag> insertTag(Tag tag) async {
    final Tag newTag =
        await tagsProvider.then((provider) => provider.insert(tag));
    _broadcastAllTags();
    return newTag;
  }

  @override
  Future<void> deleteTag(int id) async =>
      await tagsProvider.then((provider) => provider.delete(id)).then((_) {
        _broadcastAllTags();
        // maybe we deleted a tag attached to a task. this would delete it from the task
        _broadcastAllTagsForTasks();
        // maybe that tag is tied to some task, like above
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTag(Tag tag) async =>
      await tagsProvider.then((provider) => provider.update(tag)).then((_) {
        // broadcast any changes
        _broadcastAllTags();
        // maybe we deleted a tag attached to a task. this would delete it from the task
        _broadcastAllTagsForTasks();
        // maybe some tags changed names or whatnot
        _broadcastAllTagsForAllTasks();
      });

  @override
  Observable<List<Tag>> getAllTagsObservable() {
    if (tagsBehaviorSubject == null) {
      tagsBehaviorSubject = new BehaviorSubject<List<Tag>>(seedValue: []);
      // broadcast any changes
      _broadcastAllTags();
    }
    return tagsBehaviorSubject.observable;
  }

  void _broadcastAllTags() {
    // is anyone listening?
    if (tagsBehaviorSubject != null) {
      tagsProvider
          .then((provider) => provider.getAllTags())
          .then((tasks) => tagsBehaviorSubject.add(tasks));
    }
  }

  // ===== Tags In Tasks =======================================================

  @override
  Future<void> addTagToTask(int taskId, int tagId) async =>
      await tagsInTaskProvider
          .then((provider) => provider.addTag(taskId, tagId))
          .then((_) {
        _broadcastAllTagsForTask(taskId);
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> removeTagFromTask(int taskId, int tagId) async =>
      await tagsInTaskProvider
          .then((provider) => provider.removeTag(taskId, tagId))
          .then((_) {
        _broadcastAllTagsForTask(taskId);
        _broadcastAllTagsForAllTasks();
      });

  @override
  Observable<List<TagInTask>> getAllTagsForTaskObservable(int taskId) {
    if (tagsForTaskBehaviorSubjectMap[taskId] == null) {
      tagsForTaskBehaviorSubjectMap[taskId] =
          new BehaviorSubject<List<TagInTask>>(seedValue: []);
      _broadcastAllTagsForTask(taskId);
    }
    return tagsForTaskBehaviorSubjectMap[taskId].observable;
  }

  @override
  Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable() {
    if (allTagsForAllTasksBehaviorSubjectMap == null) {
      allTagsForAllTasksBehaviorSubjectMap =
          new BehaviorSubject<Map<int, List<Tag>>>(seedValue: {});
      // broadcast any changes
      _broadcastAllTagsForAllTasks();
    }
    return allTagsForAllTasksBehaviorSubjectMap.observable;
  }

  void _broadcastAllTagsForTasks() {
    tagsForTaskBehaviorSubjectMap
        .forEach((taskId, _) => _broadcastAllTagsForTask(taskId));
  }

  void _broadcastAllTagsForTask(int taskId) {
    // is anyone listening?
    if (tagsForTaskBehaviorSubjectMap[taskId] != null) {
      tagsInTaskProvider.then((provider) async {
        final List<TagInTask> tagsInTaskAndOthers = <TagInTask>[];
        final List<Tag> tagsInTask = await provider.getTagsInTask(taskId);
        for (Tag tag in tagsInTask) {
          tagsInTaskAndOthers.add(new TagInTask(tag, true));
        }
        final List<Tag> allTags =
            await tagsProvider.then((provider) => provider.getAllTags());
        for (Tag tag in allTags) {
          if (!tagsInTask.contains(tag))
            tagsInTaskAndOthers.add(new TagInTask(tag, false));
        }
        tagsForTaskBehaviorSubjectMap[taskId]
            .add(new List.unmodifiable(tagsInTaskAndOthers));
      });
    }
  }

  void _broadcastAllTagsForAllTasks() {
    if (allTagsForAllTasksBehaviorSubjectMap != null) {
      tagsInTaskProvider
          .then((provider) => provider.getTagsInAllTasks())
          .then((tagMap) => allTagsForAllTasksBehaviorSubjectMap.add(tagMap));
    }
  }
}
