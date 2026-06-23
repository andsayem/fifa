import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _boxName = 'worldcup_cache';
  static const _dataKey = 'raw_json';
  static const _timestampKey = 'cached_at';

  Box? _box;

  Future<Box> get _boxInstance async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  Future<void> cacheRawJson(String json) async {
    final box = await _boxInstance;
    await box.put(_dataKey, json);
    await box.put(_timestampKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<String?> getCachedJson() async {
    final box = await _boxInstance;
    return box.get(_dataKey) as String?;
  }

  Future<DateTime?> getCacheTimestamp() async {
    final box = await _boxInstance;
    final ts = box.get(_timestampKey) as String?;
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  Future<void> clear() async {
    final box = await _boxInstance;
    await box.clear();
  }

  Future<Map<String, dynamic>?> getCachedData() async {
    final json = await getCachedJson();
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
