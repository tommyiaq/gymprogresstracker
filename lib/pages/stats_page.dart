import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymprogresstracker/services/workout_history_service.dart';
import 'package:gymprogresstracker/models/workout_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

enum PeriodUnit { weeks, months, years }

class _StatsPageState extends State<StatsPage> {
  DateTime _endDate = DateTime.now();
  int _periodValue = 1;
  PeriodUnit _periodUnit = PeriodUnit.weeks;
  Set<String> _deselectedExercises = {};
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  late Future<void> _initFuture;

  // Keys for shared_preferences
  static const String _periodValueKey = 'stats_period_value';
  static const String _periodUnitKey = 'stats_period_unit';
  static const String _deselectedExercisesKey = 'stats_deselected_exercises';

  @override
  void initState() {
    super.initState();
    _initFuture = _loadPreferencesAndData();
  }

  Future<void> _loadPreferencesAndData() async {
    await _historyService.init(); // Ensure history service is loaded
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _periodValue = prefs.getInt(_periodValueKey) ?? 1;
      _periodUnit = PeriodUnit.values[prefs.getInt(_periodUnitKey) ?? PeriodUnit.weeks.index];
      _deselectedExercises = Set<String>.from(prefs.getStringList(_deselectedExercisesKey) ?? []);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_periodValueKey, _periodValue);
    await prefs.setInt(_periodUnitKey, _periodUnit.index);
    await prefs.setStringList(_deselectedExercisesKey, _deselectedExercises.toList());
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Stats'),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildStatsContent();
        },
      ),
    );
  }

  void _showDataPointDetails(List<WorkoutLog> dailyLogs) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Workout Details for ${DateFormat('d MMM yyyy').format(dailyLogs.first.endTime)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dailyLogs.length,
              itemBuilder: (context, index) {
                final log = dailyLogs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${log.exercise.exercise.name}: ${log.exercise.reps} reps, ${log.exercise.variation} var, ${log.exercise.weight} kg @ ${DateFormat.jm().format(log.endTime)}',
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigatePeriod(int direction) {
    setState(() {
      switch (_periodUnit) {
        case PeriodUnit.weeks:
          _endDate = _endDate.add(Duration(days: direction * _periodValue * 7));
          break;
        case PeriodUnit.months:
          _endDate = DateTime(_endDate.year, _endDate.month + (direction * _periodValue), _endDate.day);
          break;
        case PeriodUnit.years:
          _endDate = DateTime(_endDate.year + (direction * _periodValue), _endDate.month, _endDate.day);
          break;
      }
      if (_endDate.isAfter(DateTime.now())) {
        _endDate = DateTime.now();
      }
    });
  }

  Widget _buildStatsContent() {
    // Data processing logic
    DateTime startDate;
    switch (_periodUnit) {
      case PeriodUnit.weeks:
        startDate = _endDate.subtract(Duration(days: _periodValue * 7));
        break;
      case PeriodUnit.months:
        startDate = DateTime(_endDate.year, _endDate.month - _periodValue, _endDate.day);
        break;
      case PeriodUnit.years:
        startDate = DateTime(_endDate.year - _periodValue, _endDate.month, _endDate.day);
        break;
    }

    final logs = _historyService.allLogs.where((log) {
      return log.endTime.isAfter(startDate) && log.endTime.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    final Map<String, Map<DateTime, double>> dailyEffortSum = {};
    final Map<String, Map<DateTime, List<WorkoutLog>>> dailyLogsMap = {};
    final Set<String> allExercisesInPeriod = {};
    final Map<String, double> maxEffortPerExercise = {};

    for (var log in logs) {
      final day = DateTime(log.endTime.year, log.endTime.month, log.endTime.day);
      final effort = (log.exercise.reps * log.exercise.variation * (log.exercise.weight == 0 ? 1 : log.exercise.weight)).toDouble();
      final name = log.exercise.exercise.name;
      allExercisesInPeriod.add(name);
      
      dailyEffortSum.putIfAbsent(name, () => {})[day] = (dailyEffortSum[name]?[day] ?? 0) + effort;
      dailyLogsMap.putIfAbsent(name, () => {})[day] = (dailyLogsMap[name]?[day] ?? [])..add(log);
    }

    dailyEffortSum.forEach((name, dayMap) {
      double maxEffort = 0;
      dayMap.values.forEach((effort) {
        if (effort > maxEffort) maxEffort = effort;
      });
      maxEffortPerExercise[name] = maxEffort == 0 ? 1 : maxEffort;
    });

    final Map<String, List<FlSpot>> exerciseData = {};
    dailyEffortSum.forEach((name, dayMap) {
      if (!_deselectedExercises.contains(name)) {
        // Create a list of all days in the range
        final List<FlSpot> spots = [];
        DateTime currentDay = DateTime(startDate.year, startDate.month, startDate.day);
        final endDay = DateTime(_endDate.year, _endDate.month, _endDate.day);
        
        while (currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
          final totalEffort = dayMap[currentDay] ?? 0.0;
          final maxEffort = maxEffortPerExercise[name]!;
          final normalizedEffort = (totalEffort / maxEffort) * 100;
          spots.add(FlSpot(currentDay.millisecondsSinceEpoch.toDouble(), normalizedEffort));
          currentDay = currentDay.add(const Duration(days: 1));
        }
        
        exerciseData[name] = spots;
      }
    });

    // Assign colors (expanded palette to avoid duplicates for many exercises)
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
    ];
    final Map<String, Color> exerciseColors = {};
    int colorIndex = 0;
    for (var name in allExercisesInPeriod) {
      exerciseColors[name] = colors[colorIndex % colors.length];
      colorIndex++;
    }

    bool isRightArrowDisabled = _endDate.year == DateTime.now().year && _endDate.month == DateTime.now().month && _endDate.day == DateTime.now().day;

    return Column(
      children: [
        _buildDateControls(),
        _buildPeriodNavigator(startDate, isRightArrowDisabled),
        Expanded(
          child: logs.isEmpty
              ? const Center(child: Text('No workout data in this period.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      minX: startDate.millisecondsSinceEpoch.toDouble() - (Duration.millisecondsPerDay * 0.5),
                      maxX: _endDate.millisecondsSinceEpoch.toDouble() + (Duration.millisecondsPerDay * 0.5),
                      minY: 0,
                      maxY: 100,
                      lineTouchData: LineTouchData(
                        enabled: _periodUnit != PeriodUnit.years,
                        touchTooltipData: LineTouchTooltipData(),
                        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                          if (touchResponse == null || touchResponse.lineBarSpots == null) {
                            return;
                          }
                          if (event is FlTapUpEvent) {
                            final spot = touchResponse.lineBarSpots!.first;
                            final exerciseName = exerciseData.entries.firstWhere((element) => element.value.contains(spot)).key;
                            final day = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                            final logsForDay = dailyLogsMap[exerciseName]?[day] ?? [];
                            if (logsForDay.isNotEmpty) {
                              _showDataPointDetails(logsForDay);
                            }
                          }
                        },
                      ),
                      lineBarsData: exerciseData.entries.map((entry) {
                        return LineChartBarData(
                          spots: entry.value,
                          isCurved: false,
                          color: exerciseColors[entry.key]!,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: _periodUnit != PeriodUnit.years),
                          belowBarData: BarAreaData(show: false),
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              // Skip if too close to min to avoid duplication
                              if ((value - meta.min).abs() < (meta.max - meta.min) * 0.05 && value != meta.min) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                DateFormat('d MMM').format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                            interval: (_endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch) / 4,
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}%'))),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
        ),
        _buildExerciseFilter(allExercisesInPeriod, exerciseColors),
      ],
    );
  }

  Widget _buildPeriodNavigator(DateTime startDate, bool isRightArrowDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _navigatePeriod(-1)),
          Text('${DateFormat('d MMM yyyy').format(startDate)} - ${DateFormat('d MMM yyyy').format(_endDate)}'),
          IconButton(icon: Icon(Icons.arrow_forward), onPressed: isRightArrowDisabled ? null : () => _navigatePeriod(1)),
        ],
      ),
    );
  }

  Widget _buildDateControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: _selectEndDate,
            child: const Text('Set End Date'),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() { if(_periodValue > 1) _periodValue--; _savePreferences(); })),
              Text('$_periodValue'),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() { _periodValue++; _savePreferences(); })),
            ],
          ),
          DropdownButton<PeriodUnit>(
            value: _periodUnit,
            onChanged: (PeriodUnit? newValue) {
              setState(() {
                _periodUnit = newValue!;
                _savePreferences();
              });
            },
            items: PeriodUnit.values.map<DropdownMenuItem<PeriodUnit>>((PeriodUnit value) {
              return DropdownMenuItem<PeriodUnit>(
                value: value,
                child: Text(value.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseFilter(Set<String> exercises, Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: exercises.map((name) {
          final isSelected = !_deselectedExercises.contains(name);
          return FilterChip(
            label: Text(name),
            selected: isSelected,
            backgroundColor: colors[name]?.withOpacity(0.3),
            selectedColor: colors[name]?.withOpacity(0.8),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _deselectedExercises.remove(name);
                } else {
                  _deselectedExercises.add(name);
                }
                _savePreferences();
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
