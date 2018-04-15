import 'dart:async';
import 'task.dart';

// ignore: public_member_api_docs
abstract class TasksProvider {
  /// insert a task
  Future<Task> insert(Task task);
  /// delete a task
  Future<int> delete(int id);
  /// update a task
  Future<int> update(Task task);
  /// get all tasks
  Future<List<Task>> getAllTasks();
}