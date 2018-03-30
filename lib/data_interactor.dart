import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'database_helper.dart' as dbHelper;
import 'tags.dart';
import 'tags_in_task.dart';
import 'tasks.dart';

// ==== Syntatic Sugar to call the methods "statically" ========================

// ===== Tasks =================================================================

Future<Task> insertTask(Task task) =>
    dbHelper.dataInteractor.then((interactor) => interactor.insertTask(task));

Future<void> deleteTask(int id) =>
    dbHelper.dataInteractor.then((interactor) => interactor.deleteTask(id));

Future<void> updateTask(Task task) =>
    dbHelper.dataInteractor.then((interactor) {
      if (task != null) {
        interactor.updateTask(task);
      }
    });

Future<Observable<List<Task>>> getAllTasksObservable() =>
    dbHelper.dataInteractor
        .then((interactor) => interactor.getAllTasksObservable());

// ===== Tags ==================================================================

Future<Tag> insertTag(Tag tag) => dbHelper.dataInteractor
    .then((dataInteractor) => dataInteractor.insertTag(tag));

Future<void> deleteTag(int id) => dbHelper.dataInteractor
    .then((dataInteractor) => dataInteractor.deleteTag(id));

Future<void> updateTag(Tag tag) =>
    dbHelper.dataInteractor.then((dataInteractor) {
      if (tag != null) {
        dataInteractor.updateTag(tag);
      }
    });

Future<Observable<List<Tag>>> getAllTagsObservable() => dbHelper.dataInteractor
    .then((dataInteractor) => dataInteractor.getAllTagsObservable());

// ===== Tags In Tasks =========================================================

Future<void> addTagToTask(int taskId, int tagId) => dbHelper.dataInteractor
    .then((dataInteractor) => dataInteractor.addTagToTask(taskId, tagId));

Future<void> removeTagFromTask(int taskId, int tagId) => dbHelper.dataInteractor
    .then((dataInteractor) => dataInteractor.removeTagFromTask(taskId, tagId));

Future<Observable<List<Tag>>> getAllTagsForTaskObservable(int taskId) =>
    dbHelper.dataInteractor.then(
        (dataInteractor) => dataInteractor.getAllTagsForTaskObservable(taskId));

Future<Observable<Map<int, List<Tag>>>> getAllTagsForAllTasksObservable() =>
    dbHelper.dataInteractor.then(
        (dataInteractor) => dataInteractor.getAllTagsForAllTasksObservable());

// ===== IMPLEMENTATION ========================================================

abstract class DataInteractor {
  Future<Task> insertTask(Task task);

  Future<void> deleteTask(int id);

  Future<void> updateTask(Task task);

  Observable<List<Task>> getAllTasksObservable();

  Future<Tag> insertTag(Tag tag);

  Future<void> deleteTag(int id);

  Future<void> updateTag(Tag tag);

  Observable<List<Tag>> getAllTagsObservable();

  Future<void> addTagToTask(int taskId, int tagId);

  Future<void> removeTagFromTask(int taskId, int tagId);

  Observable<List<Tag>> getAllTagsForTaskObservable(int taskId);

  Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable();
}

class DataInteractorImpl implements DataInteractor {
  DataInteractorImpl(
      this._tasksProvider, this._tagsProvider, this._tagsInTasksProvider);

  final TasksProvider _tasksProvider;
  final TagsProvider _tagsProvider;
  final TagsInTaskProvider _tagsInTasksProvider;

  BehaviorSubject<List<Task>> tasksBehaviorSubject;
  BehaviorSubject<List<Tag>> tagsBehaviorSubject;
  BehaviorSubject<Map<int, List<Tag>>> allTagsForAllTasksBehaviorSubjectMap;
  final Map<int, BehaviorSubject<List<Tag>>> tagsForTaskBehaviorSubjectMap =
      <int, BehaviorSubject<List<Tag>>>{};

  // ===== Tasks ===============================================================

  @override
  Future<Task> insertTask(Task task) async {
    final Task newTask = await _tasksProvider.insert(task);
    // tell UI about new tasks
    _broadcastAllTasks();
    return newTask;
  }

  @override
  Future<void> deleteTask(int id) async => _tasksProvider.delete(id).then((_) {
        _broadcastAllTasks();
        _broadcastAllTagsForTask(id);
        // a stale task id here might be OK. But to
        // be on the safe side, lets kick off the query.
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTask(Task task) async =>
      _tasksProvider.update(task).then((_) => _broadcastAllTasks());

  @override
  Observable<List<Task>> getAllTasksObservable() {
    if (tasksBehaviorSubject == null) {
      tasksBehaviorSubject = new BehaviorSubject<List<Task>>();
      _broadcastAllTasks();
    }
    return tasksBehaviorSubject.observable;
  }

  void _broadcastAllTasks() {
    // is anyone listening?
    if (tasksBehaviorSubject != null) {
      _tasksProvider
          .getAllTasks()
          .then((tasks) => tasksBehaviorSubject.add(tasks));
    }
  }

  // ===== Tags ================================================================

  @override
  Future<Tag> insertTag(Tag tag) async {
    final Tag newTag = await _tagsProvider.insert(tag);
    _broadcastAllTags();
    return newTag;
  }

  @override
  Future<void> deleteTag(int id) async => _tagsProvider.delete(id).then((_) {
        _broadcastAllTags();
        // maybe we deleted a tag attached to a task. this would delete it from the task
        _broadcastAllTagsForTasks();
        // maybe that tag is tied to some task, like above
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTag(Tag tag) async => _tagsProvider.update(tag).then((_) {
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
      tagsBehaviorSubject = new BehaviorSubject<List<Tag>>();
      // broadcast any changes
      _broadcastAllTags();
    }
    return tagsBehaviorSubject.observable;
  }

  void _broadcastAllTags() {
    // is anyone listening?
    if (tagsBehaviorSubject != null) {
      _tagsProvider
          .getAllTags()
          .then((tasks) => tagsBehaviorSubject.add(tasks));
    }
  }

  // ===== Tags In Tasks =======================================================

  @override
  Future<void> addTagToTask(int taskId, int tagId) async =>
      _tagsInTasksProvider.addTag(taskId, tagId).then((_) {
        _broadcastAllTagsForTask(taskId);
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> removeTagFromTask(int taskId, int tagId) async =>
      _tagsInTasksProvider.removeTag(taskId, tagId).then((_) {
        _broadcastAllTagsForTask(taskId);
        _broadcastAllTagsForAllTasks();
      });

  @override
  Observable<List<Tag>> getAllTagsForTaskObservable(int taskId) {
    if (tagsForTaskBehaviorSubjectMap[taskId] == null) {
      tagsForTaskBehaviorSubjectMap[taskId] = new BehaviorSubject<List<Tag>>();
      _broadcastAllTagsForTask(taskId);
    }
    return tagsForTaskBehaviorSubjectMap[taskId].observable;
  }

  @override
  Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable() {
    if (allTagsForAllTasksBehaviorSubjectMap == null) {
      allTagsForAllTasksBehaviorSubjectMap =
          new BehaviorSubject<Map<int, List<Tag>>>();
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
      _tagsInTasksProvider.getTagsInTask(taskId).then((tags) =>
          tagsForTaskBehaviorSubjectMap[taskId]
              .add(new List.unmodifiable(tags)));
    }
  }

  void _broadcastAllTagsForAllTasks() {
    if (allTagsForAllTasksBehaviorSubjectMap != null) {
      _tagsInTasksProvider
          .getTagsInAllTasks()
          .then((tagMap) => allTagsForAllTasksBehaviorSubjectMap.add(tagMap));
    }
  }
}
