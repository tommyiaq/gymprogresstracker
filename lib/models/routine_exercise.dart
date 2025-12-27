import 'package:gymprogresstracker/models/exercise.dart';

class RoutineExercise {
  final Exercise exercise;
  int reps;
  int variation;
  double weight;

  RoutineExercise({
    required this.exercise,
    required this.reps,
    this.variation = 1,
    this.weight = 0.0,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      exercise: Exercise.fromJson(json['exercise']),
      reps: json['reps'],
      variation: json['variation'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'reps': reps,
      'variation': variation,
      'weight': weight,
    };
  }
}
