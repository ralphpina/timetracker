import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tags/tags.dart';
import 'package:tags_repository_mobile/tags_data_interactor.dart';

BehaviorSubject<TagsDataInteractor> _tagsInteractorSubject =
    new BehaviorSubject();

Observable<TagsDataInteractor> _tagsDataInteratorObservable =
    _tagsInteractorSubject.stream;

set tagsDataInteractor(TagsDataInteractor tagsDataInteractor) =>
    _tagsInteractorSubject.add(tagsDataInteractor);

Future<Tag> insertTag(Tag tag) => _tagsDataInteratorObservable.first
    .then((interactor) => interactor.insertTag(tag));

void deleteTag(int id) => _tagsDataInteratorObservable.first
    .then((interactor) => interactor.deleteTag(id));

void updateTag(Tag tag) {
  if (tag != null) {
    _tagsDataInteratorObservable.first
        .then((interactor) => interactor.updateTag(tag));
  }
}

Observable<List<Tag>> getAllTagsObservable() =>
    _tagsDataInteratorObservable.first
        .asObservable()
        .flatMap((interactor) => interactor.getAllTagsObservable());
