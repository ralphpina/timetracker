import 'package:test/test.dart';
import '../../tags_repository_mobile/lib/tags_provider.dart';
import 'package:tags/tags.dart';

void main() {
  test('Convert from a map', () {
    final Map<String, dynamic> map = {
      tagsColumnId: 2,
      tagsColumnTitle: "some title"
    };

    final Tag tag = fromMap(map);

    expect(tag.id, 2);
    expect(tag.title, "some title");
  });

  test('Convert to map', () {
    final Tag tag = new Tag("some title", id: 1);

    final Map<String, dynamic> map = toMap(tag);

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

  test('Equality works as expected', () {
    final Tag tag = new Tag("some title");
    final Tag another = new Tag("some title");

    expect(tag == another, isTrue);

    final Tag yetAgain = tag.copy(id: 1);

    expect(tag == yetAgain, isFalse);
  });
}
