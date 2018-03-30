import 'dart:async';

import 'package:flutter/material.dart';

import 'data_interactor.dart';
import 'design_specs.dart';
import 'tag_selection.dart';
import 'tags.dart';
import 'tasks.dart';
import 'tasks_dialog.dart';
import 'ui_elements.dart';

class Home extends StatefulWidget {
  @override
  createState() => new HomeState();
}

class HomeState extends State<Home> {
  final _tasks = <Task>[];
  final _tagsInTasks = <int, List<Tag>>{};

  StreamSubscription<List<Task>> allTasksSubscription;
  StreamSubscription<Map<int, List<Tag>>> allTagsForAllTasksSubscription;

  @override
  void initState() {
    super.initState();
    _initTasksSubscription();
  }

  void _initTasksSubscription() async {
    allTasksSubscription = await getAllTasksObservable()
        .then((allTasksObservable) => allTasksObservable.listen((tasks) {
              setState(() {
                _tasks.clear();
                _tasks.addAll(tasks);
              });
            }));

    allTagsForAllTasksSubscription = await getAllTagsForAllTasksObservable()
        .then((observable) => observable.listen((tagsForTasks) {
              setState(() {
                _tagsInTasks.clear();
                _tagsInTasks.addAll(tagsForTasks);
              });
            }));
  }

  @override
  void dispose() {
    super.dispose();
    allTasksSubscription?.cancel();
    allTagsForAllTasksSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text('Time Tracker'),
        ),
        body: _getTasksList(),
        floatingActionButton: new FloatingActionButton(
          onPressed: _addTask,
          tooltip: 'Add task',
          child: new Icon(Icons.add),
        ),
      );

  Future<Task> _addTask() =>
      _taskAddOrEditDialog().then<Task>((newTask) => insertTask(newTask));

  Widget _getTasksList() => new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, i) {
          return _buildRow(_tasks[i]);
        },
      );

  Widget _buildRow(Task task) => new Container(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(
                task.title,
                style: biggerFont,
              ),
              trailing: new PopupMenuButton<MenuItem<Task>>(
                // overflow menu
                onSelected: _onMenuSelection,
                itemBuilder: (BuildContext context) {
                  return MenuAction.values.map((action) {
                    return new PopupMenuItem<MenuItem<Task>>(
                      value: new MenuItem<Task>(task, action),
                      child: new Text(menuItemName(action)),
                    );
                  }).toList();
                },
              ),
              onTap: () => _editItem(task),
            ),
            new Row(
              children: _getTagsForTask(task),
            )
          ],
        ),
      );

  List<Widget> _getTagsForTask(Task task) {
    final List<Widget> tagsChips = _getTagsInChips(task.id);
    if (tagsChips.isNotEmpty) {
      tagsChips.add(new IconButton(
          icon: new Icon(Icons.add),
          onPressed: () => _manageTagsForTask(task.id)));
    } else {
      tagsChips.add(
        new Container(
          padding: const EdgeInsets.only(right: 12.0),
          child: new Chip(label: new Text('Add Task')),
        ),
      );
    }
    return tagsChips;
  }

  List<Widget> _getTagsInChips(int taskId) {
    final List<Widget> tags = <Widget>[];
    if (_tagsInTasks.containsKey(taskId)) {
      for (final tag in _tagsInTasks[taskId]) {
        tags.add(new Container(
          padding: const EdgeInsets.only(right: 12.0),
          child: new Chip(
            label: new Text(tag.title),
            onDeleted: () => removeTagFromTask(taskId, tag.id),
          ),
        ));
      }
    }
    return tags;
  }

  void _onMenuSelection(MenuItem<Task> menuItem) {
    switch (menuItem.action) {
      case MenuAction.Delete:
        _deleteItem(menuItem.item.id);
        break;
      case MenuAction.Edit:
        _editItem(menuItem.item);
        break;
    }
  }

  void _editItem(Task task) =>
      _taskAddOrEditDialog(task: task).then<Task>((updatedTask) {
        updateTask(updatedTask);
      });

  Future<void> _deleteItem(int taskId) => deleteTask(taskId);

  Future<Task> _taskAddOrEditDialog({Task task}) async => showDialog<Task>(
        context: context,
        child: new AddOrEditTaskDialog(task),
      );

  void _manageTagsForTask(int tagId) => Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => new TagSelection(tagId),
        ),
      );
}
