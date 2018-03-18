import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'database_helper.dart' as dbHelper;
import 'tasks.dart';

class Home extends StatefulWidget {
  @override
  createState() => new HomeState();
}

class HomeState extends State<Home> {
  HomeState() {
    dbHelper.getTaskProvider()
        .then((provider) => provider.getAll())
        .then((tasks) => setState(() => _tasks.addAll(tasks)));
  }

  final _tasks = <Task>[];

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Time Tracker'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: null)
        ],
      ),
      body: _buildSuggestions(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Add task',
        child: new Icon(Icons.add),
      ),
    );
  }

  Future<void> _incrementCounter() {
    print("_incrementCounter");
    final Task task = Task(
        "some title",
        "some description",
        DateTime.now().toUtc(),
        DateTime.now().add(new Duration(hours: 1)).toUtc());

    return dbHelper.getTaskProvider()
        .then((provider) => provider.insert(task))
        .then((task) => setState(() => _tasks.add(task)));
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _tasks.length,
      itemBuilder: (context, i) {
//        if (i.isOdd) return new Divider();
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
      trailing: new Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      onTap: () {
        debugPrint("Tapped heart");
        setState(() {},);
      },
    );
  }
}
