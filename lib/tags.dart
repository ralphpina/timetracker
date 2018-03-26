import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

const String tagsTable = "tags";
const String tagsColumnId = "_id";
const String tagsColumnTitle = "title";

@immutable
class Tag {
  Tag(this.title, {this.id});

  final int id;
  final String title;

  Map<String, dynamic> toMap() => {tagsColumnId: id, tagsColumnTitle: title};

  static Tag fromMap(Map map) =>
      new Tag(map[tagsColumnTitle], id: map[tagsColumnId]);

  Tag copy({int id}) => new Tag(this.title, id: id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

class TagsProvider {
  TagsProvider(this.db);

  final Database db;

  BehaviorSubject<List<Tag>> tagsBehaviorSubject;

  Future<Tag> insert(Tag tag) async =>
      await db.insert(tagsTable, tag.toMap()).then((tagId) {
        _broadcastAllTags();
        return tag.copy(id: tagId);
      });

  Future<int> delete(int id) async => await db.delete(tagsTable,
          where: "$tagsColumnId = ?", whereArgs: [id]).then((rowsAffected) {
        // broadcast any changes
        _broadcastAllTags();
        return rowsAffected;
      });

  Future<int> update(Tag tag) async => await db.update(tagsTable, tag.toMap(),
          where: "$tagsColumnId = ?", whereArgs: [tag.id]).then((rowsAffected) {
        // broadcast any changes
        _broadcastAllTags();
        return rowsAffected;
      });

  Observable<List<Tag>> getAllTagsObservable() {
    if (tagsBehaviorSubject == null) {
      tagsBehaviorSubject = new BehaviorSubject<List<Tag>>();
      // broadcast any changes
      _broadcastAllTags();
    }
    return tagsBehaviorSubject.observable;
  }

// TODO return an Observable with tag
//  Future<Tag> getTag(int id) async => await db
//          .query(tagsTable,
//              columns: [tagsColumnId, tagsColumnTitle],
//              where: "$tagsColumnId = ?",
//              whereArgs: [id])
//          .then((maps) {
//        if (maps.length > 0) {
//          return Tag.fromMap(maps.first);
//        }
//        return null;
//      });

  // ===== internal ============================================================

  void _broadcastAllTags() {
    // is anyone listening?
    if (tagsBehaviorSubject != null) {
      _getAllTags().then((tasks) => tagsBehaviorSubject.add(tasks));
    }
  }

  Future<List<Tag>> _getAllTags() async {
    final List<Map> maps =
        await db.query(tagsTable, columns: [tagsColumnId, tagsColumnTitle]);
    if (maps.length > 0) {
      return new List.unmodifiable(maps.map((map) => Tag.fromMap(map)));
    }
    return [];
  }
}
