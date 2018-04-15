import 'package:meta/meta.dart';

/// task
@immutable
class Task {
  /// make a task
  const Task(this.title, this.description, this.startTime, this.endTime, {this.id});
  /// id
  final int id;
  /// title
  final String title;
  /// description
  final String description;
  /// start time
  final DateTime startTime;
  /// end time
  final DateTime endTime;

  /// not persisted, instead calculated at construction
  Duration get duration => endTime.difference(startTime);

  /// copy this task and get a new instance with id
  Task copy({int id}) =>
      new Task(title, description, startTime, endTime,
          id: id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              description == other.description &&
              startTime == other.startTime &&
              endTime == other.endTime;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;

  @override
  String toString() => 'Task{id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime}';
}