import 'package:flutter/material.dart';
import '../models/match_model.dart';

enum TimezoneMode { device, stadium, utc, custom }

class SettingsProvider with ChangeNotifier {
  TimezoneMode _timezoneMode = TimezoneMode.device; // Default: Device/Country Time
  int _customOffsetHours = 6; // Default custom offset (e.g. GMT+6 for Bangladesh)

  TimezoneMode get timezoneMode => _timezoneMode;
  int get customOffsetHours => _customOffsetHours;

  void setTimezoneMode(TimezoneMode mode) {
    _timezoneMode = mode;
    notifyListeners();
  }

  void setCustomOffset(int offset) {
    _customOffsetHours = offset;
    notifyListeners();
  }

  // Map each stadium to its respective UTC offset in June 2026 (DST active in US/Canada)
  int getStadiumUtcOffset(String stadium) {
    final s = stadium.toLowerCase();
    // Eastern Daylight (EDT) UTC-4: New York/NJ, Boston, Philadelphia, Atlanta, Miami, Toronto
    if (s.contains('metlife') ||
        s.contains('hard rock') ||
        s.contains('bmo') ||
        s.contains('mercedes-benz') ||
        s.contains('east rutherford') ||
        s.contains('new york') ||
        s.contains('boston') ||
        s.contains('foxborough') ||
        s.contains('philadelphia') ||
        s.contains('miami') ||
        s.contains('toronto') ||
        s.contains('atlanta')) {
      return -4;
    }
    // Central Daylight (CDT) UTC-5: Dallas, Houston, Kansas City, Chicago
    if (s.contains("at&t") ||
        s.contains('arlington') ||
        s.contains('dallas') ||
        s.contains('houston') ||
        s.contains('kansas city')) {
      return -5;
    }
    // Central Standard (CST, Mexico - no DST) UTC-6: Mexico City, Guadalajara, Monterrey
    if (s.contains('azteca') ||
        s.contains('mexico city') ||
        s.contains('guadalajara') ||
        s.contains('zapopan') ||
        s.contains('monterrey') ||
        s.contains('guadalupe')) {
      return -6;
    }
    // Pacific Daylight (PDT) UTC-7: Los Angeles, San Francisco, Seattle, Vancouver
    if (s.contains('sofi') ||
        s.contains('bc place') ||
        s.contains('inglewood') ||
        s.contains('los angeles') ||
        s.contains('san francisco') ||
        s.contains('santa clara') ||
        s.contains('seattle') ||
        s.contains('vancouver')) {
      return -7;
    }
    return -5; // Fallback to central
  }

  // Get the parsed DateTime of the match in UTC
  DateTime getRawUtcDateTime(String date, String time, String? stadium) {
    try {
      final parts = date.split('-');
      final timeParts = time.split(':');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final stadiumOffset = stadium != null ? getStadiumUtcOffset(stadium) : -5;
      // To get UTC, we subtract the stadium's offset (e.g., subtracting -4 adds 4 hours)
      return DateTime.utc(year, month, day, hour, minute).subtract(Duration(hours: stadiumOffset));
    } catch (_) {
      // Fallback in case of parse error
      return DateTime.now();
    }
  }

  // Get the parsed DateTime of the match in UTC (MatchModel version)
  DateTime getMatchUtcDateTime(MatchModel match) {
    return getRawUtcDateTime(match.date, match.time, match.stadium);
  }

  // Get the DateTime adjusted to the user's preferred timezone setting
  DateTime getRawDisplayDateTime(String date, String time, String? stadium) {
    final utcDateTime = getRawUtcDateTime(date, time, stadium);
    switch (_timezoneMode) {
      case TimezoneMode.device:
        return utcDateTime.toLocal(); // local device / country time
      case TimezoneMode.stadium:
        final stadiumOffset = stadium != null ? getStadiumUtcOffset(stadium) : -5;
        return utcDateTime.add(Duration(hours: stadiumOffset));
      case TimezoneMode.utc:
        return utcDateTime;
      case TimezoneMode.custom:
        return utcDateTime.add(Duration(hours: _customOffsetHours));
    }
  }

  // Get the DateTime adjusted to the user's preferred timezone setting (MatchModel version)
  DateTime getMatchDisplayDateTime(MatchModel match) {
    return getRawDisplayDateTime(match.date, match.time, match.stadium);
  }

  // Formatted date string for display (Raw version)
  String getFormattedRawDate(String date, String time, String? stadium) {
    final dt = getRawDisplayDateTime(date, time, stadium);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  // Formatted date string for display (MatchModel version)
  String getFormattedDate(MatchModel match) {
    return getFormattedRawDate(match.date, match.time, match.stadium);
  }

  // Formatted time string with timezone label (Raw version)
  String getFormattedRawTime(String date, String time, String? stadium) {
    final dt = getRawDisplayDateTime(date, time, stadium);
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minuteStr $amPm';

    switch (_timezoneMode) {
      case TimezoneMode.device: {
        final tzName = DateTime.now().timeZoneName;
        final deviceOffset = DateTime.now().timeZoneOffset;
        final offsetHours = deviceOffset.inHours;
        final offsetMinutes = deviceOffset.inMinutes.remainder(60).abs();
        final offsetStr = offsetMinutes > 0
            ? 'GMT${offsetHours >= 0 ? "+" : ""}$offsetHours:${offsetMinutes.toString().padLeft(2, "0")}'
            : 'GMT${offsetHours >= 0 ? "+" : ""}$offsetHours';
        return '$timeStr ($tzName, $offsetStr)';
      }
      case TimezoneMode.stadium:
        final offset = stadium != null ? getStadiumUtcOffset(stadium) : -5;
        final sign = offset >= 0 ? '+' : '';
        return '$timeStr (Stadium GMT$sign$offset)';
      case TimezoneMode.utc:
        return '$timeStr (UTC)';
      case TimezoneMode.custom:
        final sign = _customOffsetHours >= 0 ? '+' : '';
        return '$timeStr (GMT$sign$_customOffsetHours)';
    }
  }

  // Formatted time string with timezone label (MatchModel version)
  String getFormattedTime(MatchModel match) {
    return getFormattedRawTime(match.date, match.time, match.stadium);
  }
}
