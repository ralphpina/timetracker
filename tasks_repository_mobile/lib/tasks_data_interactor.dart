import 'dart:async';

import 'package:tasks/tasks.dart';
import 'package:rxdart/rxdart.dart';

abstract class TasksDataInteractor {
  Future<Task> insertTask(Task task);

  Future<void> deleteTask(int id);

  Future<void> updateTask(Task task);

  Observable<List<Task>> getAllTasksObservable();
}