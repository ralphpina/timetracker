import 'package:tasks/tasks.dart';
import 'package:test/test.dart';

void main() {
  test('Calculates duration', () {
    // ignore: always_specify_types
    final DateTime now = new DateTime(2017).toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        'some title',
        'some description',
        now,
        nowPlusHour,
        id: 1);

    expect(task.duration, new Duration(hours: 1));
  });

  test('Copy gives you new object', () {
    final DateTime now = new DateTime(2017).toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        'some title',
        'some description',
        now,
        nowPlusHour);

    final Task another = task.copy(id: 1);

    expect(task.id, isNull);
    expect(another.id, 1);
    expect(task.title, another.title);
    expect(task.description, another.description);
    expect(task.startTime, another.startTime);
    expect(task.endTime, another.endTime);
  });

  test('Equals works as expected', () {
    final DateTime now = new DateTime(2017).toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task = new Task(
        'some title',
        'some description',
        now,
        nowPlusHour);

    final Task another = new Task(
        'some title',
        'some description',
        now,
        nowPlusHour);

    expect(task == another, isTrue);
  });
}
