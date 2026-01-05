import 'package:flutter/material.dart';
import 'package:gymprogresstracker/pages/edit_routine_page.dart';
import 'package:gymprogresstracker/pages/workout_page.dart';
import 'package:gymprogresstracker/services/routine_service.dart';
import 'package:gymprogresstracker/services/backup_service.dart';
import 'package:share_plus/share_plus.dart';

class ManageRoutinesPage extends StatefulWidget {
  const ManageRoutinesPage({super.key});

  @override
  State<ManageRoutinesPage> createState() => _ManageRoutinesPageState();
}

class _ManageRoutinesPageState extends State<ManageRoutinesPage> {
  final RoutineService _routineService = RoutineService();
  final BackupService _backupService = BackupService();
  late Future<void> _initServicesFuture;

  @override
  void initState() {
    super.initState();
    _initServicesFuture = _routineService.init();
  }

  void _deleteRoutine(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this routine?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _routineService.deleteRoutine(id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportBackup() async {
    final filePath = await _backupService.exportData();
    if (filePath != null && mounted) {
      await Share.shareXFiles([XFile(filePath)], text: 'Gym Progress Tracker Backup');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup exported successfully!'), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export backup'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _importBackup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Backup'),
        content: const Text('This will replace all your current data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _backupService.importData();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup imported successfully! Please restart the app.'), backgroundColor: Colors.green),
          );
          setState(() {
            _initServicesFuture = _routineService.init();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to import backup'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routines'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportBackup();
              } else if (value == 'import') {
                _importBackup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Export Backup'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Import Backup'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initServicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final routines = _routineService.allRoutines;
          routines.sort((a, b) {
            if (a.lastPlayed == null && b.lastPlayed == null) return 0;
            if (a.lastPlayed == null) return 1;
            if (b.lastPlayed == null) return -1;
            return b.lastPlayed!.compareTo(a.lastPlayed!);
          });

          if (routines.isEmpty) {
            return const Center(
              child: Text('No routines created yet. Tap the + button to add one!'),
            );
          }

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                child: ListTile(
                  title: Text(routine.name),
                  subtitle: Text('${routine.exercises.length} exercises'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkoutPage(routine: routine),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteRoutine(routine.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditRoutinePage(routine: routine),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EditRoutinePage(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


