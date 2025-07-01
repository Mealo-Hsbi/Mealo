import 'package:flutter/foundation.dart';
import '../../data/achievement_service.dart';
import '../../domain/entities/achievement.dart';

enum AchievementStatus {
  initial,
  loading,
  loaded,
  error,
}

class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService();
  
  AchievementStatus _status = AchievementStatus.initial;
  List<Achievement> _achievements = [];
  String? _errorMessage;

  // Getters
  AchievementStatus get status => _status;
  List<Achievement> get achievements => _achievements;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AchievementStatus.loading;
  
  // Anzahl der freigeschalteten Achievements
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;
  
  // Gesamtanzahl der Achievements
  int get totalCount => _achievements.length;

  /// Lädt alle Achievements vom Backend
  Future<void> loadAchievements() async {
    if (_status == AchievementStatus.loading) return;
    
    _status = AchievementStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final achievements = await _achievementService.getAllAchievements();
      _achievements = achievements;
      _status = AchievementStatus.loaded;
      print('[AchievementProvider] Loaded ${achievements.length} achievements');
    } catch (e) {
      _errorMessage = e.toString();
      _status = AchievementStatus.error;
      print('[AchievementProvider] Error loading achievements: $e');
    }
    
    notifyListeners();
  }

  /// Lädt die Achievements neu
  Future<void> refreshAchievements() async {
    await loadAchievements();
  }

  /// Setzt den Status zurück
  void reset() {
    _status = AchievementStatus.initial;
    _achievements = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Findet ein Achievement nach ID
  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Findet ein Achievement nach Key
  Achievement? getAchievementByKey(String key) {
    try {
      return _achievements.firstWhere((achievement) => achievement.key == key);
    } catch (e) {
      return null;
    }
  }
} 