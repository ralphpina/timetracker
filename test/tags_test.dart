import 'package:test/test.dart';
import 'package:timetracker/tags.dart';

void main() {
  test('Convert from a map', () {
    final Map<String, dynamic> map = {
      tagsColumnId: 2,
      tagsColumnTitle: "some title"
    };

    final Tag tag = Tag.fromMap(map);

    expect(tag.id, 2);
    expect(tag.title, "some title");
  });

  test('Convert to map', () {
    final Tag tag = new Tag("some title", id: 1);

    final Map<String, dynamic> map = tag.toMap();

    expect(map[tagsColumnId], 1);
    expect(map[tagsColumnTitle], "some title");
  });

  test('Copy gives you new object', () {
    final Tag tag = new Tag(
        "some title");

    final Tag another = tag.copy(id: 1);

    expect(tag.id, isNull);
    expect(another.id, 1);
    expect(tag.title, another.title);
  });

  // TODO(ralph) find a way to test TagsProvider path_provider.getApplicationDocumentsDirectory()
}
