import 'package:flutter/material.dart';

class TimeSlotSelector extends StatefulWidget {
  final ValueChanged<List<TimeOfDay>> onSelectionChanged;
  final List<TimeOfDay> initialTimes;

  const TimeSlotSelector({super.key, required this.onSelectionChanged, this.initialTimes = const []});

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  late List<TimeOfDay> _selectedTimes;

  @override
  void initState() {
    super.initState();
    _selectedTimes = List<TimeOfDay>.from(widget.initialTimes);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !_selectedTimes.contains(picked)) {
      setState(() {
        _selectedTimes.add(picked);
        _selectedTimes.sort((a, b) {
          if (a.hour != b.hour) {
            return a.hour.compareTo(b.hour);
          }
          return a.minute.compareTo(b.minute);
        });
        widget.onSelectionChanged(_selectedTimes);
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
      widget.onSelectionChanged(_selectedTimes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Slots',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: List<Widget>.generate(_selectedTimes.length, (index) {
            return Chip(
              label: Text(_selectedTimes[index].format(context)),
              onDeleted: () => _removeTime(index),
            );
          }),
        ),
        OutlinedButton.icon(
          onPressed: () => _selectTime(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Time'),
        ),
      ],
    );
  }
}
