import '/services/api_client.dart';


class OnboardingApi {
  final _api = ApiClient();

  Future<void> submitPreferences(List<String> optionKeys) async {
    await _api.post('/preferences', data: {
      'optionKeys': optionKeys,
    });
  }
}
