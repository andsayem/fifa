import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  static const String _key = 'favorite_matches_ids';
  List<int> _favoriteMatchIds = [];
  bool _isLoading = true;

  List<int> get favoriteMatchIds => _favoriteMatchIds;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? storedStringIds = prefs.getStringList(_key);
      if (storedStringIds != null) {
        _favoriteMatchIds = storedStringIds.map((id) => int.parse(id)).toList();
      }
    } catch (e) {
      // Fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int matchId) {
    return _favoriteMatchIds.contains(matchId);
  }

  Future<void> toggleFavorite(int matchId) async {
    if (_favoriteMatchIds.contains(matchId)) {
      _favoriteMatchIds.remove(matchId);
    } else {
      _favoriteMatchIds.add(matchId);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStringIds = _favoriteMatchIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_key, storedStringIds);
    } catch (e) {
      // Fallback
    }
  }
}
