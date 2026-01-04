import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymprogresstracker/home_widget.dart';
import 'package:gymprogresstracker/models/routine.dart';
import 'package:gymprogresstracker/models/routine_exercise.dart';
import 'package:gymprogresstracker/models/workout_log.dart';
import 'package:gymprogresstracker/services/routine_service.dart';
import 'package:gymprogresstracker/services/workout_history_service.dart';
import 'package:gymprogresstracker/widgets/incrementable_field.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:uuid/uuid.dart';

class WorkoutPage extends StatefulWidget {
  final Routine routine;
  const WorkoutPage({super.key, required this.routine});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _routineService = RoutineService();
  final _historyService = WorkoutHistoryService();
  late Routine _currentRoutine;
  int _currentExerciseIndex = 0;
  
  late TextEditingController _repsController;
  late TextEditingController _variationController;
  late TextEditingController _weightController;

  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;
  DateTime? _exerciseStartTime;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _sessionId = const Uuid().v4();
    _currentRoutine = widget.routine;
    _setupControllersForCurrentExercise();
    _startSessionTimer();
    _exerciseStartTime = DateTime.now();
  }

  void _setupControllersForCurrentExercise() {
    final exercise = _currentRoutine.exercises[_currentExerciseIndex];
    _repsController = TextEditingController(text: exercise.reps.toString());
    _variationController = TextEditingController(text: exercise.variation.toString());
    _weightController = TextEditingController(text: exercise.weight.toString());
  }
  
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _sessionDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _sessionTimer?.cancel();
    _repsController.dispose();
    _variationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextExercise() {
    // 1. Log the completed exercise
    final endTime = DateTime.now();
    final updatedExercise = RoutineExercise(
      exercise: _currentRoutine.exercises[_currentExerciseIndex].exercise,
      reps: int.parse(_repsController.text),
      variation: int.parse(_variationController.text),
      weight: double.parse(_weightController.text),
    );
    _historyService.addLog(WorkoutLog(
      sessionId: _sessionId,
      routineId: _currentRoutine.id,
      startTime: _exerciseStartTime!,
      endTime: endTime,
      exercise: updatedExercise,
    ));

    // 2. Update the routine in memory
    _currentRoutine.exercises[_currentExerciseIndex] = updatedExercise;

    // 3. Move to the next exercise or finish
    if (_currentExerciseIndex < _currentRoutine.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _setupControllersForCurrentExercise();
        _exerciseStartTime = DateTime.now();
      });
    } else {
      WakelockPlus.disable();
      // Workout finished
      _routineService.updateRoutine(_currentRoutine.copyWith(lastPlayed: DateTime.now()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout Complete! Routine Updated.'), backgroundColor: Colors.green)
      );
      Navigator.of(context).pop();
      // Switch to stats tab (index 2)
      homeWidgetKey.currentState?.switchToTab(2);
    }
  }

  String _formatDuration(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  @override
  Widget build(BuildContext context) {
    final currentExercise = _currentRoutine.exercises[_currentExerciseIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Playing: ${_currentRoutine.name}'),
        automaticallyImplyLeading: false, // Prevents a back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_formatDuration(_sessionDuration), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: Column(
                  key: ValueKey<int>(_currentExerciseIndex),
                  children: [
                    Text(currentExercise.exercise.name, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 30),
                    IncrementableField(controller: _repsController, label: 'Reps'),
                    const SizedBox(height: 10),
                    IncrementableField(controller: _variationController, label: 'Variation'),
                    const SizedBox(height: 10),
                    IncrementableField(controller: _weightController, label: 'Weight (kg)', isDouble: true),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextExercise,
                child: Text(_currentExerciseIndex < _currentRoutine.exercises.length - 1 ? 'Next Exercise' : 'Finish Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}