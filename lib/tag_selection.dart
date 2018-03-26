import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'database_helper.dart' as dbHelper;
import 'design_specs.dart';
import 'tags.dart';
import 'tags_dialog.dart';

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
    tagsInTaskSubscription = await _getTagsForTaskObservable()
        .then((observable) => observable.listen((tags) {
              setState(() {
                _tagsInTask.clear();
                _tagsInTask.addAll(tags);
                _setupOtherTags();
              });
            }));

    allTagsSubscription = await _getAllTagsObservable()
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

  Future<Observable<List<Tag>>> _getTagsForTaskObservable() =>
      dbHelper.taskProvider
          .then((provider) => provider.getAllTagsForTaskObservable(_taskId));

  Future<Observable<List<Tag>>> _getAllTagsObservable() =>
      dbHelper.tagProvider.then((provider) => provider.getAllTagsObservable());

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

  Future<Tag> _addTag() => _tagAddOrEditDialog().then<Tag>((newTag) {
        dbHelper.tagProvider
            .then((provider) => provider.insert(newTag))
            .then((tag) => _addTagToTask(tag));
      });

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
        trailing: new Icon(
          tagged ? Icons.check_circle : Icons.check_circle_outline,
          color: tagged ? Theme.of(context).accentColor : null,
        ),
        onTap: () {
          if (!tagged) {
            _addTagToTask(tag);
          } else {
            _removeTagFromTask(tag);
          }
        },
      );

  Future<Tag> _tagAddOrEditDialog({Tag tag}) async => showDialog<Tag>(
        context: context,
        child: new AddOrEditTagDialog(tag),
      );

  Future<void> _addTagToTask(Tag tag) => dbHelper.taskProvider
      .then((taskProvider) => taskProvider.addTag(_taskId, tag));

  Future<void> _removeTagFromTask(Tag tag) => dbHelper.taskProvider
      .then((taskProvider) => taskProvider.removeTag(_taskId, tag));
}
