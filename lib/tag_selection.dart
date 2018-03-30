import 'dart:async';

import 'package:flutter/material.dart';

import 'data_interactor.dart';
import 'design_specs.dart';
import 'tags.dart';
import 'tags_dialog.dart';
import 'ui_elements.dart';

class TagSelection extends StatefulWidget {
  TagSelection(this._taskId);

  final int _taskId;

  @override
  State<StatefulWidget> createState() => new TagSelectionState(_taskId);
}

class TagSelectionState extends State<TagSelection> {
  TagSelectionState(this._taskId);

  final int _taskId;
  final _tagsInTask = <Tag>[];
  final _otherTags = <Tag>[];
  final _allTags = <Tag>[];

  StreamSubscription<List<Tag>> tagsInTaskSubscription;
  StreamSubscription<List<Tag>> allTagsSubscription;

  @override
  void initState() {
    super.initState();
    _initTagsSubscription();
  }

  void _initTagsSubscription() async {
    tagsInTaskSubscription = await getAllTagsForTaskObservable(_taskId)
        .then((observable) => observable.listen((tags) {
              setState(() {
                _tagsInTask.clear();
                _tagsInTask.addAll(tags);
                _setupOtherTags();
              });
            }));

    allTagsSubscription = await getAllTagsObservable()
        .then((observable) => observable.listen((tags) {
              setState(() {
                _allTags.clear();
                _allTags.addAll(tags);
                _setupOtherTags();
              });
            }));
  }

  void _setupOtherTags() {
    _otherTags.clear();
    for (final Tag tag in _allTags) {
      if (!_tagsInTask.contains(tag)) {
        _otherTags.add(tag);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    tagsInTaskSubscription?.cancel();
    allTagsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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

  Widget _getTagsList() => new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tagsInTask.length + _otherTags.length,
        itemBuilder: (context, i) {
          if (i < _tagsInTask.length) {
            return _buildRow(_tagsInTask[i], true);
          } else {
            return _buildRow(_otherTags[i - _tagsInTask.length], false);
          }
        },
      );

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
        child: new AddOrEditTagDialog(tag),
      );
}
