import 'dart:convert';
import 'package:gymprogresstracker/models/exercise.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  List<Exercise> _masterExerciseList = [];
  static const _key = 'master_exercise_list';
  Future<void>? _initFuture;

  Future<void> init() {
    return _initFuture ??= _loadData();
  }

  List<Exercise> get allExercises => _masterExerciseList;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? exercisesString = prefs.getString(_key);
    if (exercisesString != null) {
      final List<dynamic> exerciseList = jsonDecode(exercisesString);
      _masterExerciseList = exerciseList.map((i) => Exercise.fromJson(i)).toList();
    } else {
      _masterExerciseList = [
        Exercise(name: 'Push-ups'),
        Exercise(name: 'Squats'),
        Exercise(name: 'Plank'),
      ];
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String exercisesString = jsonEncode(_masterExerciseList.map((e) => e.toJson()).toList());
    await prefs.setString(_key, exercisesString);
  }

  Exercise addExercise(String name) {
    final existing = _masterExerciseList.where((e) => e.name.toLowerCase() == name.toLowerCase());
    if (existing.isEmpty) {
      final newExercise = Exercise(name: name);
      _masterExerciseList.add(newExercise);
      _saveData();
      return newExercise;
    }
    return existing.first;
  }
}
