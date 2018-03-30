import 'package:flutter/material.dart';

import 'date_time.dart';
import 'tasks.dart';

class AddOrEditTaskDialog extends StatefulWidget {
  AddOrEditTaskDialog(this._task);

  final Task _task;

  @override
  createState() => new AddOrEditTaskState(_task);
}

class AddOrEditTaskState extends State<AddOrEditTaskDialog> {
  AddOrEditTaskState(this._task) {
    _title = _task?.title ?? '';
    _description = _task?.description ?? '';
    _startTime = _task?.startTime ?? DateTime.now();
    _startTimeOfDay = new TimeOfDay(hour: _startTime.hour, minute: _startTime.minute);
    _endTime = _task?.endTime ?? DateTime.now();
    _endTimeOfDay = new TimeOfDay(hour: _endTime.hour, minute: _endTime.minute);

    _titleController = new TextEditingController(text: _task?.title);
    _descriptionController = new TextEditingController(text: _task?.description);
  }

  final Task _task;

  String _title;
  String _description;
  DateTime _startTime;
  TimeOfDay _startTimeOfDay;
  DateTime _endTime;
  TimeOfDay _endTimeOfDay;

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(_task != null ? 'Edit task' : 'Create task'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Title',
                labelText: 'Title',
              ),
              controller: _titleController,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(fontSize: 20.0),
              onChanged: (newTitle) => setState(() => _title = newTitle),
            ),
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Description',
                labelText: 'Description',
              ),
              controller: _descriptionController,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1
                  .copyWith(fontSize: 20.0),
              onChanged: (newDescription) => setState(() => _description = newDescription),
            ),
            new DateTimePicker(
              labelText: 'From',
              selectedDate: _startTime,
              selectedTime: _startTimeOfDay,
              selectDate: (DateTime date) {
                setState(() {
                  _startTime = date;
                });
              },
              selectTime: (TimeOfDay time) {
                setState(() {
                  _startTimeOfDay = time;
                });
              },
            ),
            new DateTimePicker(
              labelText: 'To',
              selectedDate: _endTime,
              selectedTime: _endTimeOfDay,
              selectDate: (DateTime date) {
                setState(() {
                  _endTime = date;
                });
              },
              selectTime: (TimeOfDay time) {
                setState(() {
                  _endTimeOfDay = time;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new RaisedButton(
          child: new Text(_task != null ? 'Edit' : 'Create'),
          onPressed: () {
            final DateTime newStartTime = new DateTime(
                _startTime.year,
                _startTime.month,
                _startTime.day,
                _startTimeOfDay.hour,
                _startTimeOfDay.minute);
            final DateTime newEndTime = new DateTime(
                _endTime.year,
                _endTime.month,
                _endTime.day,
                _endTimeOfDay.hour,
                _endTimeOfDay.minute);
            final Task newOrUpdated = new Task(_title, _description, newStartTime, newEndTime, id: _task?.id ?? null);
            Navigator.of(context).pop(newOrUpdated);
          },
        ),
      ],
    );
  }
}
