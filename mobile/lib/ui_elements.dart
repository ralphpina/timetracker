import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@immutable
class MenuItem<T> {
  MenuItem(this.item, this.action);

  final T item;
  final MenuAction action;
}

enum MenuAction { Edit, Delete }

String menuItemName(MenuAction action) => _capitalizeMenuItemName(
    action.toString().substring(action.toString().indexOf('.') + 1));

String _capitalizeMenuItemName(String s) => '${s[0].toUpperCase()}${s.substring(1)}';