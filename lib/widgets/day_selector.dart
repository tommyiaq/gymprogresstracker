import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final ValueChanged<List<int>> onSelectionChanged;
  final List<int> initialDays;

  const DaySelector({super.key, required this.onSelectionChanged, this.initialDays = const []});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List<int>.from(widget.initialDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List<Widget>.generate(_days.length, (int index) {
            final isSelected = _selectedDays.contains(index + 1);
            return FilterChip(
              label: Text(_days[index]),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(index + 1);
                  } else {
                    _selectedDays.remove(index + 1);
                  }
                  _selectedDays.sort();
                  widget.onSelectionChanged(_selectedDays);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
