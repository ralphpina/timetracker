import 'package:flutter/material.dart';

import 'home.dart';
import 'shared/strings.dart';

void main() => runApp(new TimeTracker());

class TimeTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: app_name,
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Home(),
    );
  }
}
