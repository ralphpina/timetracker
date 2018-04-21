import 'package:tags/tags.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tags_in_task/tags_in_task.dart';
import 'package:tags_in_task_repository_mobile/tags_in_task_data_interactor.dart';

BehaviorSubject<TagsInTaskDataInteractor> _tagsInTaskInteractorSubject =
    new BehaviorSubject();

Observable<TagsInTaskDataInteractor> _tagsInTaskInteratorObservable =
    _tagsInTaskInteractorSubject.stream;

set tagsInTaskDataInteractor(
        TagsInTaskDataInteractor tagsInTaskDataInteractor) =>
    _tagsInTaskInteractorSubject.add(tagsInTaskDataInteractor);

void addTagToTask(int taskId, int tagId) => _tagsInTaskInteratorObservable.first
    .then((interactor) => interactor.addTagToTask(taskId, tagId));

void removeTagFromTask(int taskId, int tagId) =>
    _tagsInTaskInteratorObservable.first
        .then((interactor) => interactor.removeTagFromTask(taskId, tagId));

Observable<List<TagInTask>> getAllTagsForTaskObservable(int taskId) =>
    _tagsInTaskInteratorObservable.first.asObservable().flatMap(
        (interactor) => interactor.getAllTagsForTaskObservable(taskId));

Observable<Map<int, List<Tag>>> getAllTagsForAllTasksObservable() =>
    _tagsInTaskInteratorObservable.first
        .asObservable()
        .flatMap((interactor) => interactor.getAllTagsForAllTasksObservable());
