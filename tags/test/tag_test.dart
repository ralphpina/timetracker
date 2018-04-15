import 'package:test/test.dart';
import 'package:tags/tags.dart';

void main() {
  test('Copy gives you new object', () {
    final tag = new Tag('some title');

    final another = tag.copy(id: 1);

    expect(tag.id, isNull);
    expect(another.id, 1);
    expect(tag.title, another.title);
  });

  test('Equality works as expected', () {
    final tag = new Tag('some title');
    final another = new Tag('some title');

    expect(tag == another, isTrue);

    final Tag yetAgain = tag.copy(id: 1);

    expect(tag == yetAgain, isFalse);
  });
}
