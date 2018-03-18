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
}

class TagsProvider {
  TagsProvider(this.db);

  final Database db;

  Future<Tag> insert(Tag tag) async {
    final int id = await db.insert(tagsTable, tag.toMap());
    return tag.copy(id: id);
  }

  Future<Tag> getTag(int id) async {
    List<Map> maps = await db.query(tagsTable,
        columns: [tagsColumnId, tagsColumnTitle],
        where: "$tagsColumnId = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Tag.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async =>
      await db.delete(tagsTable, where: "$tagsColumnId = ?", whereArgs: [id]);

  // TODO(ralph) this method will need to be deleted ot changed to keep immutability
  Future<int> update(Tag tag) async => await db.update(tagsTable, tag.toMap(),
      where: "$tagsColumnId = ?", whereArgs: [tag.id]);
}
