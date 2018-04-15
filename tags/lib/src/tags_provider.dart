import 'dart:async';
import 'tag.dart';

abstract class TagsProvider {
  Future<Tag> insert(Tag tag);

  Future<int> delete(int id);

  Future<int> update(Tag tag);

  Future<List<Tag>> getAllTags();
}