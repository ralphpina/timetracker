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

  StreamSubscription<List<Task>> allTasksSubscription;

  @override
  void initState() {
    super.initState();
    initTasksSubscription();
  }

  void initTasksSubscription() async {
    allTasksSubscription = await dbHelper.taskProvider
        .then((provider) => provider.getAllTasksObservable())
        .then((allTasksObservable) => allTasksObservable
        .listen((tasks) {
          setState(() {
            _tasks.clear();
            _tasks.addAll(tasks);
          });
    }));
  }

  @override
  void dispose() {
    super.dispose();
    allTasksSubscription?.cancel();
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
            .then((provider) => provider.insert(newTask));
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
    return new Container(
      child: new Column(
        children: <Widget>[
          new ListTile(
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
          ),
          new Row(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(right: 12.0),
                child: new Chip(
                  label: new Text('Design'),
                  onDeleted: () => _pushSaved,
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(right: 12.0),
                child: new Chip(
                  label: new Text('Product'),
                  onDeleted: () => _pushSaved,
                ),
              ),
              new IconButton(icon: new Icon(Icons.add), onPressed: _pushSaved),
            ],
          )
        ],
      ),
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
          .then((provider) {
            if (updatedTask != null) {
              provider.update(updatedTask);
            }
      });
    });
  }

  Future<void> _deleteItem(int taskId) {
    return dbHelper.taskProvider
        .then((provider) => provider.delete(taskId));
  }

  Future<Task> _taskAddOrEditDialog({Task task}) async {
    return showDialog<Task>(
      context: context,
      child: new AddOrEditTaskDialog(task),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = ['some', 'other'].map(
            (title) {
              return new ListTile(
                title: new Text(
                  title,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
                context: context,
                tiles: tiles,
              )
              .toList();

          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }
}
