import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'database_helper.dart' as dbHelper;
import 'tags.dart';
import 'tasks.dart';

class TagInTask {
  TagInTask(this.tag, this.inTask);

  final Tag tag;
  final bool inTask;
}

// ==== Syntatic sugar to call the methods "statically" ========================

// ===== Tasks =================================================================

void insertTask(Task task) => dbHelper.dataInteractor.insertTask(task);

void deleteTask(int id) => dbHelper.dataInteractor.deleteTask(id);

void updateTask(Task task) {
  if (task != null) {
    dbHelper.dataInteractor.updateTask(task);
  }
}

Observable<List<Task>> getAllTasksObservable() =>
    dbHelper.dataInteractor.getAllTasksObservable();

// ===== Tags ==================================================================

Future<Tag> insertTag(Tag tag) => dbHelper.dataInteractor.insertTag(tag);

void deleteTag(int id) => dbHelper.dataInteractor.deleteTag(id);

void updateTag(Tag tag) {
  if (tag != null) {
    dbHelper.dataInteractor.updateTag(tag);
  }
}

Observable<List<Tag>> getAllTagsObservable() =>
    dbHelper.dataInteractor.getAllTagsObservable();

// ===== Tags In Tasks =========================================================

void addTagToTask(int taskId, int tagId) =>
    dbHelper.dataInteractor.addTagToTask(taskId, tagId);

void removeTagFromTask(int taskId, int tagId) =>
    dbHelper.dataInteractor.removeTagFromTask(taskId, tagId);

Observable<List<TagInTask>> getAllTagsForTaskObservable(int taskId) =>
    dbHelper.dataInteractor.getAllTagsForTaskObservable(taskId);

Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable() =>
    dbHelper.dataInteractor.getAllTagsForAllTasksObservable();

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

  Observable<List<TagInTask>> getAllTagsForTaskObservable(int taskId);

  Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable();
}

class DataInteractorImpl implements DataInteractor {
  BehaviorSubject<List<Task>> tasksBehaviorSubject;
  BehaviorSubject<List<Tag>> tagsBehaviorSubject;
  BehaviorSubject<Map<int, List<Tag>>> allTagsForAllTasksBehaviorSubjectMap;
  final Map<int, BehaviorSubject<List<TagInTask>>>
      tagsForTaskBehaviorSubjectMap = <int, BehaviorSubject<List<TagInTask>>>{};

  // ===== Tasks ===============================================================

  @override
  Future<Task> insertTask(Task task) async {
    final Task newTask =
        await dbHelper.tasksProvider.then((provider) => provider.insert(task));
    // tell UI about new tasks
    _broadcastAllTasks();
    return newTask;
  }

  @override
  Future<void> deleteTask(int id) async => await dbHelper.tasksProvider
          .then((provider) => provider.delete(id))
          .then((_) {
        _broadcastAllTasks();
        _broadcastAllTagsForTask(id);
        // a stale task id here might be OK. But to
        // be on the safe side, lets kick off the query.
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTask(Task task) async => await dbHelper.tasksProvider
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
      dbHelper.tasksProvider
          .then((provider) => provider.getAllTasks())
          .then((tasks) => tasksBehaviorSubject.add(tasks));
    }
  }

  // ===== Tags ================================================================

  @override
  Future<Tag> insertTag(Tag tag) async {
    final Tag newTag =
        await dbHelper.tagsProvider.then((provider) => provider.insert(tag));
    _broadcastAllTags();
    return newTag;
  }

  @override
  Future<void> deleteTag(int id) async => await dbHelper.tagsProvider
          .then((provider) => provider.delete(id))
          .then((_) {
        _broadcastAllTags();
        // maybe we deleted a tag attached to a task. this would delete it from the task
        _broadcastAllTagsForTasks();
        // maybe that tag is tied to some task, like above
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> updateTag(Tag tag) async => await dbHelper.tagsProvider
          .then((provider) => provider.update(tag))
          .then((_) {
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
      dbHelper.tagsProvider
          .then((provider) => provider.getAllTags())
          .then((tasks) => tagsBehaviorSubject.add(tasks));
    }
  }

  // ===== Tags In Tasks =======================================================

  @override
  Future<void> addTagToTask(int taskId, int tagId) async =>
      await dbHelper.tagsInTaskProvider
          .then((provider) => provider.addTag(taskId, tagId))
          .then((_) {
        _broadcastAllTagsForTask(taskId);
        _broadcastAllTagsForAllTasks();
      });

  @override
  Future<void> removeTagFromTask(int taskId, int tagId) async =>
      await dbHelper.tagsInTaskProvider
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
      dbHelper.tagsInTaskProvider.then((provider) async {
        final List<TagInTask> tagsInTaskAndOthers = <TagInTask>[];
        final List<Tag> tagsInTask = await provider.getTagsInTask(taskId);
        for (Tag tag in tagsInTask) {
          tagsInTaskAndOthers.add(new TagInTask(tag, true));
        }
        final List<Tag> allTags = await dbHelper.tagsProvider
            .then((provider) => provider.getAllTags());
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
      dbHelper.tagsInTaskProvider
          .then((provider) => provider.getTagsInAllTasks())
          .then((tagMap) => allTagsForAllTasksBehaviorSubjectMap.add(tagMap));
    }
  }
}
