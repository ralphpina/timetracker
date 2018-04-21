library tags_mobile;

import 'package:flutter/material.dart';
import 'package:tags/tags.dart';

class AddOrEditTagDialog extends StatefulWidget {
  AddOrEditTagDialog(this._tag);

  final Tag _tag;

  @override
  createState() => new AddOrEditTagState(_tag);
}

class AddOrEditTagState extends State<AddOrEditTagDialog> {
  AddOrEditTagState(this._tag) {
    _title = _tag?.title ?? '';

    _titleController = new TextEditingController(text: _tag?.title);
  }

  final Tag _tag;

  String _title;

  TextEditingController _titleController;

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(_tag != null ? 'Edit task' : 'Create task'),
      content: new TextField(
        decoration: new InputDecoration(
          hintText: 'Title',
          labelText: 'Title',
        ),
        controller: _titleController,
        style: Theme
            .of(context)
            .textTheme
            .display1
            .copyWith(fontSize: 20.0),
        onChanged: (newTitle) => setState(() => _title = newTitle),
      ),
      actions: <Widget>[
        new RaisedButton(
          child: new Text(_tag != null ? 'Edit' : 'Create'),
          onPressed: () {
            final Tag newOrUpdated = new Tag(_title, id: _tag?.id ?? null);
            Navigator.of(context).pop(newOrUpdated);
          },
        ),
      ],
    );
  }
}
