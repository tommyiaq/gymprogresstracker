import 'package:flutter/material.dart';
import 'package:gymprogresstracker/pages/edit_routine_page.dart';
import 'package:gymprogresstracker/pages/workout_page.dart';
import 'package:gymprogresstracker/services/routine_service.dart';

class ManageRoutinesPage extends StatefulWidget {
  const ManageRoutinesPage({super.key});

  @override
  State<ManageRoutinesPage> createState() => _ManageRoutinesPageState();
}

class _ManageRoutinesPageState extends State<ManageRoutinesPage> {
  final RoutineService _routineService = RoutineService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routines'),
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


