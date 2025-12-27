import 'dart:convert';
import 'package:gymprogresstracker/models/routine.dart';
// import 'package:gymprogresstracker/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineService {
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();

  // final NotificationService _notificationService = NotificationService();
  List<Routine> _routines = [];
  static const _key = 'routines_list';
  Future<void>? _initFuture;

  Future<void> init() {
    return _initFuture ??= _loadData();
  }

  List<Routine> get allRoutines => _routines;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routinesString = prefs.getString(_key);
    if (routinesString != null) {
      final List<dynamic> routineList = jsonDecode(routinesString);
      _routines = routineList.map((i) => Routine.fromJson(i)).toList();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String routinesString = jsonEncode(_routines.map((r) => r.toJson()).toList());
    await prefs.setString(_key, routinesString);
  }

  void addRoutine(Routine routine) {
    _routines.add(routine);
    _saveData();
    // _notificationService.scheduleRoutineNotification(routine);
    print('Routine "${routine.name}" saved!');
  }

  void updateRoutine(Routine updatedRoutine) {
    final index = _routines.indexWhere((r) => r.id == updatedRoutine.id);
    if (index != -1) {
      _routines[index] = updatedRoutine;
      _saveData();
      // _notificationService.scheduleRoutineNotification(updatedRoutine);
      print('Routine "${updatedRoutine.name}" updated!');
    }
  }
  
  void deleteRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
    _saveData();
    // _notificationService.cancelRoutineNotifications(id);
    print('Routine with id "$id" deleted!');
  }
}
