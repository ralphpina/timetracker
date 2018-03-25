import 'package:flutter/material.dart';

import 'tasks.dart';


class TagSelection extends StatefulWidget {
  TagSelection(this._task);

  final Task _task;

  @override
  State<StatefulWidget> createState() => new TagSelectionState(_task);
}

class TagSelectionState extends State<TagSelection> {
  TagSelectionState(this._task);

  Task _task;

  @override
  Widget build(BuildContext context) {
//    _task.tags.contains(element)
    return null;
  }

}