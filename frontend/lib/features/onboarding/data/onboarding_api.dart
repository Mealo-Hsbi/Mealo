import '/services/api_client.dart';


class OnboardingApi {
  final _api = ApiClient();

  Future<void> submitPreferences(List<String> optionKeys) async {
    await _api.post('/preferences', data: {
      'optionKeys': optionKeys,
    });
  }

  Future<List<Map<String, dynamic>>> getUserPreferences() async {
    final response = await _api.get('/preferences/user');
    // Robustes Mapping für alle Elemente
    return (response.data as List)
        .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<bool> getOnboardingStatus() async {
    final response = await _api.get('/users/me');
    return response.data['has_completed_onboarding'] == true;
  }
}
