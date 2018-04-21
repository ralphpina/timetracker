import 'package:tasks/tasks.dart';
import 'package:tasks_repository_mobile/tasks_provider.dart';
import 'package:test/test.dart';

void main() {
  test('Convert from a map', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Map<String, dynamic> map = {
      tasksColumnId: 2,
      tasksColumnTitle: "some title",
      tasksColumnDescription: "some description",
      tasksColumnStartTime: now.toIso8601String(),
      tasksColumnEndTime: nowPlusHour.toIso8601String()
    };

    final Task task = fromMap(map);

    expect(task.id, 2);
    expect(task.title, "some title");
    expect(task.description, "some description");
    expect(task.startTime, now);
    expect(task.endTime, nowPlusHour);
  });

  test('Convert to map', () {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nowPlusHour = now.add(new Duration(hours: 1)).toUtc();

    final Task task =
        new Task("some title", "some description", now, nowPlusHour, id: 1);

    final Map<String, dynamic> map = toMap(task);

    expect(map[tasksColumnId], 1);
    expect(map[tasksColumnTitle], "some title");
    expect(map[tasksColumnDescription], "some description");
    expect(map[tasksColumnStartTime], now.toIso8601String());
    expect(map[tasksColumnEndTime], nowPlusHour.toIso8601String());
  });
}
