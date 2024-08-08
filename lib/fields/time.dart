import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class DayNightTimePickerComponent extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const DayNightTimePickerComponent({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  _DayNightTimePickerComponentState createState() => _DayNightTimePickerComponentState();
}

class _DayNightTimePickerComponentState extends State<DayNightTimePickerComponent> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  void _onTimeChanged(Time newTime) {
    final newTimeOfDay = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
    setState(() {
      _selectedTime = newTimeOfDay;
    });
    widget.onTimeChanged(newTimeOfDay);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          showPicker(
            context: context,
            value: Time(hour: _selectedTime.hour, minute: _selectedTime.minute),
            onChange: _onTimeChanged,
            is24HrFormat: false,
            accentColor: Theme.of(context).colorScheme.secondary,
            unselectedColor: Colors.grey,
            okText: 'OK',
            cancelText: 'Cancel',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            Icon(
              Icons.access_time,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
