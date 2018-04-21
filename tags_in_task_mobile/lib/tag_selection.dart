library tags_mobile;

import 'dart:async';

import 'package:design_mobile/design_specs.dart';
import 'package:flutter/material.dart';
import 'package:tags/tags.dart';
import 'package:tags_in_task/tags_in_task.dart';
import 'package:tags_mobile/tags_dialog.dart';
import 'package:ui_elements_mobile/ui_elements.dart';
import 'package:tags_mobile/tags_data_interactor_impl.dart';

import 'tags_in_task_data_interactor_impl.dart';

class TagSelection extends StatefulWidget {
  TagSelection(this._taskId);

  final int _taskId;

  @override
  State<StatefulWidget> createState() => new TagSelectionState(_taskId);
}

class TagSelectionState extends State<TagSelection> {
  TagSelectionState(this._taskId);

  final int _taskId;

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text('Manage Tags'),
        ),
        body: _getTagsList(),
        floatingActionButton: new FloatingActionButton(
          onPressed: _addTag,
          tooltip: 'Add tag',
          child: new Icon(Icons.add),
        ),
      );

  Widget _getTagsList() => new StreamBuilder<List<TagInTask>>(
      stream: getAllTagsForTaskObservable(_taskId).stream,
      builder: (context, snapshot) {
        return new ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.hasData ? snapshot.data.length : 0,
          itemBuilder: (context, i) {
            return _buildRow(snapshot.data[i].tag, snapshot.data[i].inTask);
          },
        );
      });

  Widget _buildRow(Tag tag, bool tagged) => new ListTile(
        title: new Text(
          tag.title,
          style: biggerFont,
        ),
        leading: new Icon(
          tagged ? Icons.check_circle : Icons.check_circle_outline,
          color: tagged ? Theme.of(context).accentColor : null,
        ),
        trailing: new PopupMenuButton<MenuItem<Tag>>(
          // overflow menu
          onSelected: _onMenuSelection,
          itemBuilder: (BuildContext context) {
            return MenuAction.values.map((action) {
              return new PopupMenuItem<MenuItem<Tag>>(
                value: new MenuItem<Tag>(tag, action),
                child: new Text(menuItemName(action)),
              );
            }).toList();
          },
        ),
        onTap: () {
          if (!tagged) {
            addTagToTask(_taskId, tag.id);
          } else {
            removeTagFromTask(_taskId, tag.id);
          }
        },
      );

  Future<Tag> _addTag() => _tagAddOrEditDialog().then<Tag>((newTag) {
        insertTag(newTag).then((tag) => addTagToTask(_taskId, tag.id));
      });

  void _onMenuSelection(MenuItem<Tag> menuItem) {
    switch (menuItem.action) {
      case MenuAction.Delete:
        deleteTag(menuItem.item.id);
        break;
      case MenuAction.Edit:
        _editItem(menuItem.item);
        break;
    }
  }

  void _editItem(Tag tag) =>
      _tagAddOrEditDialog(tag: tag).then<Tag>((updatedTag) {
        updateTag(updatedTag);
      });

  Future<Tag> _tagAddOrEditDialog({Tag tag}) async => showDialog<Tag>(
        context: context,
        builder: (BuildContext context) => new AddOrEditTagDialog(tag),
      );
}
