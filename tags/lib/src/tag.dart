import 'package:meta/meta.dart';

@immutable
// ignore: public_member_api_docs
class Tag {
  // ignore: public_member_api_docs
  const Tag(this.title, {this.id});

  /// database id of tag
  final int id;
  /// title of tag
  final String title;

  /// return a new tag with the updated id
  Tag copy({int id}) => new Tag(title, id: id);

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