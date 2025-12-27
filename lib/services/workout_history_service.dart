import 'dart:convert';
import 'package:gymprogresstracker/models/workout_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutHistoryService {
  static final WorkoutHistoryService _instance = WorkoutHistoryService._internal();
  factory WorkoutHistoryService() => _instance;
  WorkoutHistoryService._internal();

  List<WorkoutLog> _workoutLogs = [];
  static const _key = 'workout_logs_list';
  Future<void>? _initFuture;

  Future<void> init() {
    return _initFuture ??= _loadData();
  }

  List<WorkoutLog> get allLogs => _workoutLogs;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsString = prefs.getString(_key);
    if (logsString != null) {
      final List<dynamic> logList = jsonDecode(logsString);
      _workoutLogs = logList.map((i) => WorkoutLog.fromJson(i)).toList();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String logsString = jsonEncode(_workoutLogs.map((log) => log.toJson()).toList());
    await prefs.setString(_key, logsString);
  }

  void addLog(WorkoutLog log) {
    _workoutLogs.add(log);
    _saveData();
    print('Workout log added for routine ${log.routineId}. Total logs: ${_workoutLogs.length}');
  }
}
