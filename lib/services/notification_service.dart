import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/match_model.dart';
import '../providers/settings_provider.dart';
import '../screens/match_details_screen.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _scheduledIdsKey = 'scheduled_notification_ids';

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  final Map<int, MatchModel> _matchCache = {};

  void attachNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
    developer.log('NotificationService initialized', name: 'NotificationService');
  }

  Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || _navigatorKey?.currentContext == null) return;

    final matchId = int.tryParse(payload);
    if (matchId == null) return;

    final match = _matchCache[matchId];
    if (match == null) return;

    _navigatorKey!.currentState?.push(
      MaterialPageRoute(
        builder: (_) => MatchDetailsScreen(match: match),
      ),
    );
  }

  Future<void> scheduleMatchNotification({
    required MatchModel match,
    required bool isEnabled,
    required bool remind30MinBefore,
  }) async {
    if (!isEnabled || !remind30MinBefore) return;
    if (match.status != 'upcoming') return;

    final utcNow = DateTime.now().toUtc();
    final matchUtc = _getMatchUtc(match);
    final diffToKickoff = matchUtc.difference(utcNow);

    if (diffToKickoff.inMinutes < 30) return;

    final fireUtc = matchUtc.subtract(const Duration(minutes: 30));
    final localTz = tz.local;
    final fireTzDateTime = tz.TZDateTime.from(fireUtc, localTz);

    const androidDetails = AndroidNotificationDetails(
      'match_reminders_channel',
      'Match Reminders',
      channelDescription: 'Reminders for upcoming FIFA World Cup matches',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      match.id,
      '⚽ Match Starting Soon!',
      '${match.homeTeam} vs ${match.awayTeam} starts in 30 minutes.\nDon\'t miss the match!',
      fireTzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: match.id.toString(),
    );

    await _persistScheduledId(match.id);
    _matchCache[match.id] = match;

    developer.log(
      'Scheduled notification for match ${match.id}: ${match.homeTeam} vs ${match.awayTeam} at $fireTzDateTime',
      name: 'NotificationService',
    );
  }

  Future<void> cancelNotification(int matchId) async {
    await _plugin.cancel(matchId);
    await _removePersistedId(matchId);
    _matchCache.remove(matchId);
    developer.log('Cancelled notification for match $matchId', name: 'NotificationService');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_scheduledIdsKey, []);
    _matchCache.clear();
    developer.log('Cancelled all notifications', name: 'NotificationService');
  }

  Future<void> rescheduleAllNotifications({
    required List<MatchModel> matches,
    bool? isEnabled,
    bool? remind30MinBefore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = isEnabled ?? (prefs.getBool('notifications_enabled') ?? true);
    final remind = remind30MinBefore ?? (prefs.getBool('remind_30min_before') ?? true);

    if (!enabled || !remind) {
      await cancelAllNotifications();
      return;
    }

    await cancelAllNotifications();

    for (final match in matches) {
      try {
        await scheduleMatchNotification(
          match: match,
          isEnabled: enabled,
          remind30MinBefore: remind,
        );
      } catch (e) {
        developer.log(
          'Failed to schedule notification for match ${match.id}: $e',
          name: 'NotificationService',
        );
      }
    }

    developer.log(
      'Rescheduled all notifications (${matches.length} matches)',
      name: 'NotificationService',
    );
  }

  DateTime _getMatchUtc(MatchModel match) {
    return SettingsProvider.staticMatchUtcDateTime(match);
  }

  Future<void> _persistScheduledId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_scheduledIdsKey) ?? [];
    if (!ids.contains(id.toString())) {
      ids.add(id.toString());
      await prefs.setStringList(_scheduledIdsKey, ids);
    }
  }

  Future<void> _removePersistedId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_scheduledIdsKey) ?? [];
    ids.remove(id.toString());
    await prefs.setStringList(_scheduledIdsKey, ids);
  }

  Future<List<int>> getScheduledIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_scheduledIdsKey) ?? [])
        .map((e) => int.tryParse(e) ?? -1)
        .where((id) => id != -1)
        .toList();
  }

  Future<void> restoreScheduledNotifications({
    required List<MatchModel> matches,
    required bool isEnabled,
    required bool remind30MinBefore,
  }) async {
    if (!isEnabled || !remind30MinBefore) return;

    final persistedIds = await getScheduledIds();
    if (persistedIds.isEmpty) return;

    for (final match in matches) {
      if (persistedIds.contains(match.id)) {
        _matchCache[match.id] = match;
      }
    }
  }
}
