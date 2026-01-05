import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<String?> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all data
      final data = {
        'master_exercise_list': prefs.getString('master_exercise_list'),
        'routines_list': prefs.getString('routines_list'),
        'workout_logs_list': prefs.getString('workout_logs_list'),
        'stats_period_value': prefs.getInt('stats_period_value'),
        'stats_period_unit': prefs.getInt('stats_period_unit'),
        'stats_deselected_exercises': prefs.getStringList('stats_deselected_exercises'),
      };

      // Convert to JSON
      final jsonString = jsonEncode(data);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gym_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Error exporting data: $e');
      return null;
    }
  }

  Future<bool> importData() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      // Read file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Restore data
      final prefs = await SharedPreferences.getInstance();
      
      if (data['master_exercise_list'] != null) {
        await prefs.setString('master_exercise_list', data['master_exercise_list']);
      }
      if (data['routines_list'] != null) {
        await prefs.setString('routines_list', data['routines_list']);
      }
      if (data['workout_logs_list'] != null) {
        await prefs.setString('workout_logs_list', data['workout_logs_list']);
      }
      if (data['stats_period_value'] != null) {
        await prefs.setInt('stats_period_value', data['stats_period_value']);
      }
      if (data['stats_period_unit'] != null) {
        await prefs.setInt('stats_period_unit', data['stats_period_unit']);
      }
      if (data['stats_deselected_exercises'] != null) {
        await prefs.setStringList('stats_deselected_exercises', 
          List<String>.from(data['stats_deselected_exercises']));
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
}
