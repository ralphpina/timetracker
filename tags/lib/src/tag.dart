import 'package:meta/meta.dart';

@immutable
class Tag {
  Tag(this.title, {this.id});

  final int id;
  final String title;

  Tag copy({int id}) => new Tag(this.title, id: id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tag &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}