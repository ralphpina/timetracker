import 'package:tasks/tasks.dart';
import 'package:tasks_repository_mobile/tasks_data_interactor.dart';
import 'package:rxdart/rxdart.dart';

BehaviorSubject<TasksDataInteractor> _tasksInteractorSubject =
    new BehaviorSubject();

set tasksDataInteractor(TasksDataInteractor tasksDataInteractor) {
  _tasksInteractorSubject.add(tasksDataInteractor);
}

void insertTask(Task task) => _tasksInteractorSubject.stream.first
    .then((interactor) => interactor.insertTask(task));

void deleteTask(int id) => _tasksInteractorSubject.stream.first
    .then((interactor) => interactor.deleteTask(id));

void updateTask(Task task) {
  if (task != null) {
    _tasksInteractorSubject.stream.first
        .then((interactor) => interactor.updateTask(task));
  }
}

Observable<List<Task>> getAllTasksObservable() => _tasksInteractorSubject.stream
    .flatMap((interactor) => interactor.getAllTasksObservable());
