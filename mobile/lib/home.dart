import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tags/tags.dart';
import 'package:tasks/tasks.dart';

import 'data_interactor.dart';
import 'design_specs.dart';
import 'tag_selection.dart';
import 'tasks_dialog.dart';
import 'ui_elements.dart';

class Home extends StatefulWidget {
  @override
  createState() => new HomeState();
}

class HomeState extends State<Home> {
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

  void _addTask() =>
      _taskAddOrEditDialog().then((newTask) => insertTask(newTask));

  Widget _getTasksList() => new StreamBuilder<List<Task>>(
      stream: getAllTasksObservable().stream,
      builder: (context, snapshot) {
        return new ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.hasData ? snapshot.data.length : 0,
          itemBuilder: (context, i) {
            return _buildRow(snapshot.data[i]);
          },
        );
      });

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
            _getTagsForTask(task)
          ],
        ),
      );

  Widget _getTagsForTask(Task task) => new StreamBuilder<Map<int, List<Tag>>>(
        stream: getAllTagsForAllTasksObservable().stream,
        builder: (context, snapshot) {
          return new Row(
            children: _buildTagChips(snapshot, task),
          );
        },
      );

  List<Widget> _buildTagChips(
      AsyncSnapshot<Map<int, List<Tag>>> snapshot, Task task) {
    if (snapshot.hasData && snapshot.data.containsKey(task.id)) {
      return _getChipsForTask(snapshot, task);
    } else {
      return <Widget>[
        new GestureDetector(
          child: new Container(
            padding: const EdgeInsets.only(right: 12.0),
            child: new Chip(label: new Text('Add Tag')),
          ),
          onTap: () => _manageTagsForTask(task.id),
        )
      ];
    }
  }

  List<Widget> _getChipsForTask(
      AsyncSnapshot<Map<int, List<Tag>>> snapshot, Task task) {
    final List<Widget> tagsChips = <Widget>[];
    for (final tag in snapshot.data[task.id]) {
      tagsChips.add(new Container(
        padding: const EdgeInsets.only(right: 12.0),
        child: new Chip(
          label: new Text(tag.title),
          onDeleted: () => removeTagFromTask(task.id, tag.id),
        ),
      ));
    }
    // add the + button last
    tagsChips.add(new IconButton(
        icon: new Icon(Icons.add),
        onPressed: () => _manageTagsForTask(task.id)));

    return tagsChips;
  }

  void _onMenuSelection(MenuItem<Task> menuItem) {
    switch (menuItem.action) {
      case MenuAction.Delete:
        deleteTask(menuItem.item.id);
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

  Future<Task> _taskAddOrEditDialog({Task task}) async => showDialog<Task>(
        context: context,
        builder: (context) => new AddOrEditTaskDialog(task),
      );

  void _manageTagsForTask(int tagId) => Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => new TagSelection(tagId),
        ),
      );
}
