import 'package:date_time_picker_mobile/date_time_picker.dart';
import 'package:design_mobile/design_specs.dart';
import 'package:flutter/material.dart';
import 'package:tasks/tasks.dart';
import 'tasks_data_interactor_impl.dart';

class CreateTaskView extends StatefulWidget {
  CreateTaskView(this._task);

  final Task _task;

  @override
  createState() => new CreateTaskViewState(_task);
}

class CreateTaskData {
  String title;
  String description;
  DateTime startTime;
  TimeOfDay startTimeOfDay;
  DateTime endTime;
  TimeOfDay endTimeOfDay;
}

class CreateTaskViewState extends State<CreateTaskView> {
  CreateTaskViewState(this._task) {
    _createTaskData.title = _task?.title ?? '';
    _createTaskData.description = _task?.description ?? '';

    _createTaskData.startTime = _task?.startTime ?? DateTime.now();
    _createTaskData.startTimeOfDay = new TimeOfDay(
        hour: _createTaskData.startTime.hour,
        minute: _createTaskData.startTime.minute);

    _createTaskData.endTime = _task?.endTime ?? DateTime.now();
    _createTaskData.endTimeOfDay = new TimeOfDay(
        hour: _createTaskData.endTime.hour,
        minute: _createTaskData.endTime.minute);

    _titleController = new TextEditingController(text: _task?.title);
    _descriptionController = new TextEditingController(text: _task?.description);
  }

  final Task _task;
  final CreateTaskData _createTaskData = new CreateTaskData();

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState.validate()) {
      final DateTime newStartTime = new DateTime(
          _createTaskData.startTime.year,
          _createTaskData.startTime.month,
          _createTaskData.startTime.day,
          _createTaskData.startTimeOfDay.hour,
          _createTaskData.startTimeOfDay.minute);
      final DateTime newEndTime = new DateTime(
          _createTaskData.endTime.year,
          _createTaskData.endTime.month,
          _createTaskData.endTime.day,
          _createTaskData.endTimeOfDay.hour,
          _createTaskData.endTimeOfDay.minute);

      if (newEndTime.isBefore(newStartTime)) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text('End time cannot be before start time.')));
      } else {
        _formKey.currentState.save();
      }

      final Task newOrUpdated = new Task(_createTaskData.title,
          _createTaskData.description, newStartTime, newEndTime,
          id: _task?.id ?? null);

      if (_task != null) {
        updateTask(newOrUpdated);
      } else {
        insertTask(newOrUpdated);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ArgumentError.notNull("some");
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Create Task'),
      ),
      body: new Form(
        key: _formKey,
        child: new SingleChildScrollView(
          padding: normalPadding,
          child: new ListBody(
            children: <Widget>[
              new TextFormField(
                decoration: new InputDecoration(
                  hintText: 'Title',
                  labelText: 'Title',
                ),
                controller: _titleController,
                style:
                    Theme.of(context).textTheme.title.copyWith(fontSize: 20.0),
                validator: (title) =>
                    title.trim().isEmpty ? 'No title entered.' : null,
                onSaved: (newTitle) => _createTaskData.title = newTitle,
              ),
              new TextFormField(
                keyboardType: TextInputType.multiline,
                decoration: new InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                ),
                controller: _descriptionController,
                style: Theme.of(context).textTheme.display1.copyWith(
                      fontSize: 20.0,
                    ),
                onSaved: (newDescription) =>
                    _createTaskData.description = newDescription,
              ),
              new DateTimePicker(
                labelText: 'From',
                selectedDate: _createTaskData.startTime,
                selectedTime: _createTaskData.startTimeOfDay,
                selectDate: (DateTime date) {
                  setState(() {
                    _createTaskData.startTime = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _createTaskData.startTimeOfDay = time;
                  });
                },
              ),
              new DateTimePicker(
                labelText: 'To',
                selectedDate: _createTaskData.endTime,
                selectedTime: _createTaskData.endTimeOfDay,
                selectDate: (DateTime date) {
                  setState(() {
                    _createTaskData.endTime = date;
                  });
                },
                selectTime: (TimeOfDay time) {
                  setState(() {
                    _createTaskData.endTimeOfDay = time;
                  });
                },
              ),
              new Container(
                margin: EdgeInsets.only(top: 20.0),
                child: new RaisedButton(
                  child: new Text(_task != null ? 'Edit' : 'Create'),
                  onPressed: _submit,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
