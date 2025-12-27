import 'package:flutter/material.dart';
import 'package:gymprogresstracker/models/routine.dart';
import 'package:gymprogresstracker/models/routine_exercise.dart';
import 'package:gymprogresstracker/services/routine_service.dart';
import 'package:gymprogresstracker/widgets/day_selector.dart';
import 'package:gymprogresstracker/widgets/exercise_selector.dart';
import 'package:gymprogresstracker/widgets/incrementable_field.dart';
import 'package:gymprogresstracker/widgets/routine_name_field.dart';
import 'package:gymprogresstracker/widgets/time_slot_selector.dart';

class EditRoutinePage extends StatefulWidget {
  final Routine? routine; // Pass a routine to edit, or null to create
  const EditRoutinePage({super.key, this.routine});

  @override
  State<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _routineService = RoutineService();

  late TextEditingController _nameController;
  late TextEditingController _notificationController;
  late List<int> _selectedDays;
  late List<TimeOfDay> _selectedTimeSlots;
  late List<RoutineExercise> _selectedExercises;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
    _notificationController = TextEditingController(text: widget.routine?.notificationMinutes?.toString() ?? '15');
    _selectedDays = widget.routine?.days ?? [];
    _selectedTimeSlots = widget.routine?.timeSlots ?? [];
    _selectedExercises = widget.routine?.exercises ?? [];
    _notificationsEnabled = widget.routine?.notificationMinutes != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      int? notificationMinutes;
      if (_notificationsEnabled) {
        notificationMinutes = int.tryParse(_notificationController.text);
        if (notificationMinutes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid number for notification minutes.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (widget.routine == null) {
        _routineService.addRoutine(Routine(
          name: _nameController.text,
          exercises: _selectedExercises,
          days: _selectedDays,
          timeSlots: _selectedTimeSlots,
          notificationMinutes: notificationMinutes,
        ));
      } else {
        _routineService.updateRoutine(widget.routine!.copyWith(
          name: _nameController.text,
          exercises: _selectedExercises,
          days: _selectedDays,
          timeSlots: _selectedTimeSlots,
          notificationMinutes: () => notificationMinutes,
        ));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routine Saved Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(); // Go back to the manage page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Create New Routine' : 'Edit Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              RoutineNameField(
                controller: _nameController,
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              DaySelector(
                initialDays: _selectedDays,
                onSelectionChanged: (selectedDays) {
                  _selectedDays = selectedDays;
                },
              ),
              const SizedBox(height: 20),
              TimeSlotSelector(
                initialTimes: _selectedTimeSlots,
                onSelectionChanged: (selectedTimes) {
                  _selectedTimeSlots = selectedTimes;
                },
              ),
              const SizedBox(height: 20),
               Row(
                children: [
                  const Text('Enable Notifications'),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              if (_notificationsEnabled)
                IncrementableField(
                  controller: _notificationController,
                  label: 'Notify Minutes Before',
                ),
              const SizedBox(height: 20),
              ExerciseSelector(
                initialExercises: _selectedExercises,
                onSelectionChanged: (exercises) {
                  _selectedExercises = exercises;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveRoutine,
                child: const Text('Save Routine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
