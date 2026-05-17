import 'package:flutter/material.dart';
import '../models/bracket_model.dart';
import '../services/static_api_service.dart';

class BracketProvider with ChangeNotifier {
  final StaticApiService _apiService = StaticApiService();
  BracketModel? _bracket;
  bool _isLoading = true;

  BracketModel? get bracket => _bracket;
  bool get isLoading => _isLoading;

  BracketProvider() {
    loadBracket();
  }

  Future<void> loadBracket() async {
    _isLoading = true;
    notifyListeners();
    _bracket = await _apiService.loadBracket();
    _isLoading = false;
    notifyListeners();
  }
}
