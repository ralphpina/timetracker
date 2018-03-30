import 'dart:async';

import 'package:meta/meta.dart';
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

abstract class TagsProvider {
  Future<Tag> insert(Tag tag);

  Future<int> delete(int id);

  Future<int> update(Tag tag);

  Future<List<Tag>> getAllTags();
}

class TagsProviderImpl implements TagsProvider {
  TagsProviderImpl(this.db);

  final Database db;

  @override
  Future<Tag> insert(Tag tag) async =>
      db.insert(tagsTable, tag.toMap()).then((tagId) {
        return tag.copy(id: tagId);
      });

  @override
  Future<int> delete(int id) async =>
      db.delete(tagsTable, where: "$tagsColumnId = ?", whereArgs: [id]);

  @override
  Future<int> update(Tag tag) async => db.update(tagsTable, tag.toMap(),
      where: "$tagsColumnId = ?", whereArgs: [tag.id]);

  @override
  Future<List<Tag>> getAllTags() async => db.query(tagsTable,
          columns: [tagsColumnId, tagsColumnTitle]).then((maps) {
        if (maps.length > 0) {
          return new List.unmodifiable(maps.map((map) => Tag.fromMap(map)));
        }
        return [];
      });

// TODO return an Observable with tag
//  Future<Tag> getTag(int id) async => db
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
}
