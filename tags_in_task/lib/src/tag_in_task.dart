import 'package:tags/tags.dart';

/// Whether ot not a tag is in a specfic task
class TagInTask {
  /// constructor
  /// [inTask] marks whether ot not
  // ignore: avoid_positional_boolean_parameters
  TagInTask(this.tag, this.inTask);

  /// tag
  final Tag tag;
  /// whether or not is selected in task
  final bool inTask;
}
