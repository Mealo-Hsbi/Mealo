import 'package:flutter/foundation.dart';
import '../../data/onboarding_questions.dart';
import '../../data/onboarding_api.dart';

class OnboardingViewModel extends ChangeNotifier {
  final Map<String, List<String>> responses = {}; // Frage → Optionen
  final OnboardingApi _api = OnboardingApi();

  void toggleSelection(String question, String option) {
    final selected = responses.putIfAbsent(question, () => []);
    if (selected.contains(option)) {
      selected.remove(option);
    } else {
      selected.add(option);
    }
    notifyListeners();
  }

  Future<void> submit() async {
    final selectedOptionKeys = responses.values.expand((e) => e).toList();
    await _api.submitPreferences(selectedOptionKeys);
  }
}
