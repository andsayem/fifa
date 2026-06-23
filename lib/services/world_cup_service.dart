import 'package:dio/dio.dart';

class WorldCupService {
  static const _baseUrl =
      'https://raw.githubusercontent.com/openfootball/worldcup.json/master';

  late final Dio _dio;

  WorldCupService({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json'},
          ),
        );
  }

  Future<Map<String, dynamic>> fetchWorldCupData() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/2026/worldcup.json',
      );
      return response.data ?? {};
    } on DioException {
      rethrow;
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      await _dio.head('/2026/worldcup.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _dio.close();
  }
}
