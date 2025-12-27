import 'package:flutter/material.dart';
import 'package:gymprogresstracker/models/routine_exercise.dart';
import 'package:uuid/uuid.dart';

class Routine {
  final String id;
  final String name;
  final List<RoutineExercise> exercises;
  final List<int> days; // 1 for Monday, 7 for Sunday
  final List<TimeOfDay> timeSlots;
  final DateTime? lastPlayed;
  final int? notificationMinutes;

  Routine({
    String? id,
    required this.name,
    required this.exercises,
    required this.days,
    required this.timeSlots,
    this.lastPlayed,
    this.notificationMinutes,
  }) : id = id ?? const Uuid().v4();

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      exercises: (json['exercises'] as List)
          .map((i) => RoutineExercise.fromJson(i))
          .toList(),
      days: List<int>.from(json['days']),
      timeSlots: (json['timeSlots'] as List)
          .map((i) => TimeOfDay(hour: int.parse(i.split(':')[0]), minute: int.parse(i.split(':')[1])))
          .toList(),
      lastPlayed: json['lastPlayed'] == null ? null : DateTime.parse(json['lastPlayed']),
      notificationMinutes: json['notificationMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'days': days,
      'timeSlots': timeSlots.map((t) => '${t.hour}:${t.minute}').toList(),
      'lastPlayed': lastPlayed?.toIso8601String(),
      'notificationMinutes': notificationMinutes,
    };
  }

  Routine copyWith({
    String? name,
    List<RoutineExercise>? exercises,
    List<int>? days,
    List<TimeOfDay>? timeSlots,
    DateTime? lastPlayed,
    ValueGetter<int?>? notificationMinutes,
  }) {
    return Routine(
      id: id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      days: days ?? this.days,
      timeSlots: timeSlots ?? this.timeSlots,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      notificationMinutes: notificationMinutes != null ? notificationMinutes() : this.notificationMinutes,
    );
  }
}
