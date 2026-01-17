import 'package:flutter/material.dart';
import 'package:gymprogresstracker/models/exercise.dart';
import 'package:gymprogresstracker/models/routine_exercise.dart';
import 'package:gymprogresstracker/services/exercise_service.dart';

class ExerciseSelector extends StatefulWidget {
  final ValueChanged<List<RoutineExercise>> onSelectionChanged;
  final List<RoutineExercise> initialExercises;

  const ExerciseSelector({super.key, required this.onSelectionChanged, this.initialExercises = const []});

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  late List<RoutineExercise> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = List<RoutineExercise>.from(widget.initialExercises);
  }

  void _addExercise(RoutineExercise exercise) {
    setState(() {
      _selectedExercises.add(exercise);
      widget.onSelectionChanged(_selectedExercises);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
      widget.onSelectionChanged(_selectedExercises);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, exercise);
      widget.onSelectionChanged(_selectedExercises);
    });
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExerciseDialog(onAdd: _addExercise);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedExercises.length,
          onReorder: _reorderExercises,
          itemBuilder: (context, index) {
            final re = _selectedExercises[index];
            return Card(
              key: ValueKey('${re.exercise.name}_$index'),
              child: ListTile(
                leading: const Icon(Icons.drag_handle),
                title: Text(re.exercise.name),
                subtitle: Text('Reps: ${re.reps}, Weight: ${re.weight}kg, Variation: ${re.variation}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeExercise(index),
                ),
              ),
            );
          },
        ),
        OutlinedButton.icon(
          onPressed: _showAddExerciseDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Exercise'),
        ),
      ],
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  final Function(RoutineExercise) onAdd;

  const AddExerciseDialog({super.key, required this.onAdd});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseService = ExerciseService();
  Exercise? _selectedExercise;

  late TextEditingController _nameController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _variationController;

  late Future<void> _initExercisesFuture;

  @override
  void initState() {
    super.initState();
    _initExercisesFuture = _exerciseService.init();
    _nameController = TextEditingController();
    _repsController = TextEditingController(text: '10');
    _weightController = TextEditingController(text: '0.0');
    _variationController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _variationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initExercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            title: Text('Add Exercise to Routine'),
            content: Center(child: CircularProgressIndicator()),
          );
        }
        
        final allExercises = _exerciseService.allExercises;

        return AlertDialog(
          title: const Text('Add Exercise to Routine'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<Exercise>(
                  decoration: const InputDecoration(labelText: 'Choose Exercise'),
                  value: _selectedExercise,
                  items: allExercises.map<DropdownMenuItem<Exercise>>((Exercise value) {
                    return DropdownMenuItem<Exercise>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList()
                    ..add(const DropdownMenuItem(value: null, child: Text("Add new..."))),
                  onChanged: (Exercise? newValue) {
                    setState(() {
                      _selectedExercise = newValue;
                    });
                  },
                ),
                if (_selectedExercise == null)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'New Exercise Name'),
                    validator: (value) {
                      if (_selectedExercise == null && (value == null || value.isEmpty)) {
                        return 'Please enter a name for the new exercise';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter reps' : null,
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _variationController,
                  decoration: const InputDecoration(labelText: 'Variation'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  Exercise exercise;
                  if (_selectedExercise == null) {
                    exercise = _exerciseService.addExercise(_nameController.text);
                  } else {
                    exercise = _selectedExercise!;
                  }

                  final newRoutineExercise = RoutineExercise(
                    exercise: exercise,
                    reps: int.tryParse(_repsController.text) ?? 0,
                    weight: double.tryParse(_weightController.text) ?? 0.0,
                    variation: int.tryParse(_variationController.text) ?? 1,
                  );
                  widget.onAdd(newRoutineExercise);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}