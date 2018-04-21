import 'package:flutter/material.dart';
import 'package:timetracker/data_interactor.dart';

import 'home.dart';
import 'shared/strings.dart';

DataInteractorImpl _dataInteractor = new DataInteractorImpl();

void main() => runApp(new TimeTracker());

class TimeTracker extends StatelessWidget {
  /// used to inject dependencies
  TimeTracker() {
    _dataInteractor.init();
  }

  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: app_name,
        theme: new ThemeData(
          primaryColor: Colors.white,
        ),
        home: new Home(),
      );
}
