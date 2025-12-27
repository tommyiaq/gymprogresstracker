import 'package:gymprogresstracker/models/routine_exercise.dart';
import 'package:uuid/uuid.dart';

class WorkoutLog {
  final String sessionId;
  final String routineId;
  final DateTime startTime;
  final DateTime endTime;
  final RoutineExercise exercise;

  WorkoutLog({
    String? sessionId,
    required this.routineId,
    required this.startTime,
    required this.endTime,
    required this.exercise,
  }) : sessionId = sessionId ?? const Uuid().v4();

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      sessionId: json['sessionId'] ?? const Uuid().v4(), // Backward compatible
      routineId: json['routineId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      exercise: RoutineExercise.fromJson(json['exercise']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'routineId': routineId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercise': exercise.toJson(),
    };
  }
}
