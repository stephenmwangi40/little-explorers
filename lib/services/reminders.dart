import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// On-device reminders for GROWN-UPS only. Off by default, opt-in from the
/// parent area, scheduled locally (no server, no data leaves the device).
/// Wording is friendly and never guilt-trips the child.
class Reminders {
  Reminders._();
  static final Reminders I = Reminders._();

  static const _daily = 1;
  static const _trial = 2;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'grown_up_reminders',
      'Reminders for grown-ups',
      channelDescription: 'Optional daily adventure and trial reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('Reminders unavailable: $e');
    }
  }

  /// Asks the system for permission. Returns true when allowed.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _plugin
                .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      }
      return await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  /// A daily reminder at [hour]:00, local time.
  Future<void> scheduleDaily({required int hour, required int minutes}) async {
    if (!_ready) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: _daily,
        title: 'Tiko’s adventure is ready',
        body: 'About $minutes minutes of letters, numbers, stories and play, whenever you are ready.',
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
    }
  }

  Future<void> cancelDaily() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _daily);
    } catch (_) {}
  }

  /// Reminder 2 days before a free trial ends (as promised on the plan screen).
  Future<void> scheduleTrialReminder(DateTime trialEnds) async {
    if (!_ready) return;
    final at = trialEnds.subtract(const Duration(days: 2));
    if (at.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: _trial,
        title: 'Your free trial ends in 2 days',
        body: 'Explorer Plus will renew unless cancelled in your App Store or Google Play subscriptions.',
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Could not schedule trial reminder: $e');
    }
  }
}
