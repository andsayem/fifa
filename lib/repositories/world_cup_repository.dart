import 'dart:convert';

import '../models/world_cup_data.dart';
import '../services/cache_service.dart';
import '../services/world_cup_service.dart';

enum DataSource { remote, cache, error }

class FetchResult {
  final WorldCupData data;
  final DataSource source;

  const FetchResult({required this.data, required this.source});
}

class WorldCupRepository {
  final WorldCupService _service;
  final CacheService _cache;

  WorldCupRepository({
    required WorldCupService service,
    required CacheService cache,
  })  : _service = service,
        _cache = cache;

  Future<FetchResult> fetchData() async {
    try {
      final rawJson = await _service.fetchWorldCupData();
      await _cache.cacheRawJson(jsonEncode(rawJson));
      return FetchResult(
        data: WorldCupData.fromJson(rawJson),
        source: DataSource.remote,
      );
    } catch (_) {
      final cached = await _cache.getCachedData();
      if (cached != null) {
        return FetchResult(
          data: WorldCupData.fromJson(cached),
          source: DataSource.cache,
        );
      }
      rethrow;
    }
  }

  Future<WorldCupData?> loadFromCache() async {
    final cached = await _cache.getCachedData();
    if (cached == null) return null;
    return WorldCupData.fromJson(cached);
  }

  Future<DateTime?> lastCacheTime() => _cache.getCacheTimestamp();
}
