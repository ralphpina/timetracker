import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(new TimeTracker());

class TimeTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Time Tracker',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Home(),
    );
  }
}
