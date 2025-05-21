import 'api_keys.dart';
import 'environment.dart';

class AppConfig {
  static late final Environment environment;

  static late final String spoonacularApiKey;
  static late final String spoonacularBaseUrl;

  static void init(Environment env) {
    environment = env;

    switch (env) {
      case Environment.dev:
        spoonacularApiKey = ApiKeys.spoonacular;
        spoonacularBaseUrl = 'https://api.spoonacular.com';
        break;
      case Environment.prod:
        spoonacularApiKey = ApiKeys.spoonacular; // ggf. anderer Key
        spoonacularBaseUrl = 'https://api.spoonacular.com';
        break;
    }
  }
}
