import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'database_helper.dart' as dbHelper;
import 'tasks.dart';
import 'tasks_dialog.dart';

enum MenuAction { Edit, Delete }

@immutable
class MenuItem {
  MenuItem(this.task, this.action);

  final Task task;
  final MenuAction action;
}

class Home extends StatefulWidget {
  @override
  createState() => new HomeState();
}

class HomeState extends State<Home> {
  final _tasks = <Task>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    dbHelper.taskProvider
        .then((provider) => provider.getAll())
        .then((tasks) => setState(() => _tasks.addAll(tasks)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Time Tracker'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: null)
        ],
      ),
      body: _getTasksList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: new Icon(Icons.add),
      ),
    );
  }

  Future<Task> _addTask() => _taskAddOrEditDialog().then<Task>((newTask) {
    dbHelper.taskProvider
        .then((provider) => provider.insert(newTask))
        .then((task) => setState(() => _tasks.add(task)));
  });

  Widget _getTasksList() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _tasks.length,
      itemBuilder: (context, i) {
        return _buildRow(_tasks[i]);
      },
    );
  }

  Widget _buildRow(Task task) {
    return new ListTile(
      title: new Text(
        task.title,
        style: _biggerFont,
      ),
      trailing: new PopupMenuButton<MenuItem>(
        // overflow menu
        onSelected: _onMenuSelection,
        itemBuilder: (BuildContext context) {
          return MenuAction.values.map((action) {
            return new PopupMenuItem<MenuItem>(
              value: new MenuItem(task, action),
              child: new Text(_menuItemName(action)),
            );
          }).toList();
        },
      ),
      onTap: () => _editItem(task),
    );
  }

  String _menuItemName(MenuAction action) => _capitalize(
      action.toString().substring(action.toString().indexOf('.') + 1));

  String _capitalize(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

  void _onMenuSelection(MenuItem menuItem) {
    switch (menuItem.action) {
      case MenuAction.Delete:
        _deleteItem(menuItem.task.id);
        break;
      case MenuAction.Edit:
        _editItem(menuItem.task);
        break;
    }
  }

  void _editItem(Task task) {
    _taskAddOrEditDialog(task: task).then<Task>((updatedTask) {
      dbHelper.taskProvider
          .then((provider) => provider.update(updatedTask))
          .then((ignore) => setState(() {
        for (int i = 0; i < _tasks.length; i++) {
          if (_tasks[i].id == updatedTask.id) {
            _tasks[i] = updatedTask;
            break;
          }
        }
      }));
    });
  }

  Future<void> _deleteItem(int taskId) {
    return dbHelper.taskProvider
        .then((provider) => provider.delete(taskId))
        .then((ignore /* num rows affected, always 1 */) =>
            setState(() => _tasks.removeWhere((task) => task.id == taskId)));
  }

  Future<Task> _taskAddOrEditDialog({Task task}) async {
    return showDialog<Task>(
      context: context,
      child: new AddOrEditTaskDialog(task),
    );
  }
}
