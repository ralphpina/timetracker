import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:tags/tags.dart';

const String tagsTable = "tags";
const String tagsColumnId = "_id";
const String tagsColumnTitle = "title";

abstract class TagsProvider {
  Future<Tag> insert(Tag tag);

  Future<int> delete(int id);

  Future<int> update(Tag tag);

  Future<List<Tag>> getAllTags();
}

Map<String, dynamic> toMap(Tag tag) => {tagsColumnId: tag.id, tagsColumnTitle: tag.title};

Tag fromMap(Map map) => new Tag(map[tagsColumnTitle], id: map[tagsColumnId]);

class TagsProviderImpl implements TagsProvider {
  TagsProviderImpl(this.db);

  final Database db;

  @override
  Future<Tag> insert(Tag tag) async =>
      db.insert(tagsTable, toMap(tag)).then((tagId) {
        return tag.copy(id: tagId);
      });

  @override
  Future<int> delete(int id) async =>
      db.delete(tagsTable, where: "$tagsColumnId = ?", whereArgs: [id]);

  @override
  Future<int> update(Tag tag) async => db.update(tagsTable, toMap(tag),
      where: "$tagsColumnId = ?", whereArgs: [tag.id]);

  @override
  Future<List<Tag>> getAllTags() async => db.query(tagsTable,
          columns: [tagsColumnId, tagsColumnTitle]).then((maps) {
        if (maps.length > 0) {
          return new List.unmodifiable(maps.map((map) => fromMap(map)));
        }
        return [];
      });
}
