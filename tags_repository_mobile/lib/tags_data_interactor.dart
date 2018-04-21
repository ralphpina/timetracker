import 'dart:async';

import 'package:tags/tags.dart';
import 'package:rxdart/rxdart.dart';

abstract class TagsDataInteractor {
  Future<Tag> insertTag(Tag tag);

  Future<void> deleteTag(int id);

  Future<void> updateTag(Tag tag);

  Observable<List<Tag>> getAllTagsObservable();
}
