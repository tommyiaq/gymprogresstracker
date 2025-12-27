/*
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gymprogresstracker/models/routine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    tz.initializeTimeZones();
    print('Notification Service Initialized.');
  }
  
  Future<void> requestPermissions() async {
     await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleRoutineNotification(Routine routine) async {
    if (routine.notificationMinutes == null) {
      await cancelRoutineNotifications(routine.id);
      return;
    }
    
    await cancelRoutineNotifications(routine.id); // Clear old notifications before scheduling new ones

    for (int day in routine.days) {
      for (TimeOfDay time in routine.timeSlots) {
        final tz.TZDateTime scheduledDate = _nextInstanceOfTime(day, time, routine.notificationMinutes!);
        
        await _notificationsPlugin.zonedSchedule(
          _generateNotificationId(routine.id, day, time),
          'Upcoming Workout!',
          'Time for your "${routine.name}" routine.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_channel_id',
              'Routine Notifications',
              channelDescription: 'Notifications for upcoming workout routines',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        print('Scheduled notification for ${routine.name} on day $day at $time');
      }
    }
  }

  Future<void> cancelRoutineNotifications(String routineId) async {
    print('Cancelling all notifications for routine ID: $routineId');
    // A more robust solution would store notification IDs, but for this app,
    // we can iterate through a reasonable range of possible IDs.
    for (int day = 1; day <= 7; day++) {
       for (int hour = 0; hour < 24; hour++) {
         for (int minute = 0; minute < 60; minute++) {
           await _notificationsPlugin.cancel(_generateNotificationId(routineId, day, TimeOfDay(hour: hour, minute: minute)));
         }
       }
    }
  }

  int _generateNotificationId(String routineId, int day, TimeOfDay time) {
    // Create a unique integer ID from the routine's ID hash code and the time.
    // This is a simple but effective way to get a unique ID for each scheduled time.
    return (routineId.hashCode + day + time.hour * 100 + time.minute).toSigned(31);
  }

  tz.TZDateTime _nextInstanceOfTime(int dayOfWeek, TimeOfDay time, int minutesBefore) {
    tz.TZDateTime scheduledDate = _nextInstanceOfDay(dayOfWeek);
    scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month, scheduledDate.day, time.hour, time.minute);
    scheduledDate = scheduledDate.subtract(Duration(minutes: minutesBefore));
    
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
  
  tz.TZDateTime _nextInstanceOfDay(int dayOfWeek) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int currentDay = now.weekday;
    int daysToAdd = dayOfWeek - currentDay;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
    return now.add(Duration(days: daysToAdd));
  }
}
*/
import 'package:gymprogresstracker/models/routine.dart';

class NotificationService {
  Future<void> init() async {}
  Future<void> requestPermissions() async {}
  Future<void> scheduleRoutineNotification(Routine routine) async {}
  Future<void> cancelRoutineNotifications(String routineId) async {}
}
