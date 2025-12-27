import 'package:flutter/material.dart';
import 'package:gymprogresstracker/models/routine.dart';
import 'package:gymprogresstracker/pages/workout_page.dart';
import 'package:gymprogresstracker/services/routine_service.dart';
import 'package:gymprogresstracker/services/workout_history_service.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final RoutineService _routineService = RoutineService();
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  late Future<void> _initServicesFuture;

  @override
  void initState() {
    super.initState();
    _initServicesFuture = Future.wait([_routineService.init(), _historyService.init()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play a Routine'),
      ),
      body: FutureBuilder(
        future: _initServicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final routines = _routineService.allRoutines;
          if (routines.isEmpty) {
            return const Center(
              child: Text('No routines available. Go to the Routines tab to create one!'),
            );
          }
          
          // Find Last Played Routine
          routines.sort((a, b) {
            if (a.lastPlayed == null && b.lastPlayed == null) return 0;
            if (a.lastPlayed == null) return 1;
            if (b.lastPlayed == null) return -1;
            return b.lastPlayed!.compareTo(a.lastPlayed!);
          });
          Routine? lastPlayed;
          try {
            lastPlayed = routines.firstWhere((r) => r.lastPlayed != null);
          } catch (e) {
            lastPlayed = routines.isNotEmpty ? routines.first : null;
          }

          // Find Next Scheduled Routine
          Routine? nextScheduled;
          final today = DateTime.now();
          try {
            nextScheduled = routines.firstWhere((r) => r.days.contains(today.weekday));
          } catch (e) {
            nextScheduled = null;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lastPlayed != null) ...[
                  Text('Last Played', style: Theme.of(context).textTheme.headlineSmall),
                  RoutineSummaryCard(routine: lastPlayed, historyService: _historyService),
                  const SizedBox(height: 20),
                ],
                if (nextScheduled != null) ...[
                  Text('Next Scheduled for Today', style: Theme.of(context).textTheme.headlineSmall),
                  RoutineSummaryCard(routine: nextScheduled, historyService: _historyService),
                ] else ...[
                   const Text('No routines scheduled for today.'),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

class RoutineSummaryCard extends StatelessWidget {
  final Routine routine;
  final WorkoutHistoryService historyService;
  const RoutineSummaryCard({super.key, required this.routine, required this.historyService});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLogs = historyService.allLogs.where((log) {
      return log.routineId == routine.id &&
          log.endTime.year == today.year &&
          log.endTime.month == today.month &&
          log.endTime.day == today.day;
    });
    final sessionCount = todayLogs.map((log) => log.sessionId).toSet().length;

    return Card(
      child: ListTile(
        title: Text(routine.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${routine.exercises.length} exercises'),
            if (routine.timeSlots.isNotEmpty)
              TimeSlotsDisplay(timeSlots: routine.timeSlots, completedCount: sessionCount),
          ],
        ),
        trailing: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WorkoutPage(routine: routine),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TimeSlotsDisplay extends StatelessWidget {
  final List<TimeOfDay> timeSlots;
  final int completedCount;

  const TimeSlotsDisplay({super.key, required this.timeSlots, required this.completedCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: List.generate(timeSlots.length, (index) {
          final time = timeSlots[index];
          final color = index < completedCount ? Colors.green : Colors.red.withOpacity(0.7);
          return Chip(
            label: Text(time.format(context)),
            backgroundColor: color,
            labelStyle: const TextStyle(color: Colors.white),
            padding: EdgeInsets.zero,
          );
        }),
      ),
    );
  }
}
