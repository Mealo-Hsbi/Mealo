// lib/core/providers/app_providers.dart
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/providers/current_tab_provider.dart';

// Importiere alle Abhängigkeiten für die Instanziierung der Notifier
import 'package:frontend/services/api_client.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    // Hier instanziieren wir die Kern-Services, die von Notifiern benötigt werden
    final ApiClient apiClient = ApiClient();
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);

    // Korrektur hier: Benannte Parameter für den Konstruktor verwenden
    final RecipeRepositoryImpl recipeRepository = RecipeRepositoryImpl(remoteDataSource: recipeApiDataSource);

    // Der UseCase-Instanzname ist searchRecipesUsecase (mit kleinem 'u')
    final SearchRecipes searchRecipesUsecase = SearchRecipes(recipeRepository);

    return [
      ChangeNotifierProvider(create: (_) => SelectedIngredientsProvider()),
      ChangeNotifierProvider(create: (_) => CurrentTabProvider()),
      // Nun kann der SearchNotifier hier mit seinen Abhängigkeiten erstellt werden
      // Der Parametername im SearchNotifier-Konstruktor ist 'searchRecipesUsecase'
      // Daher muss dieser exakt hier verwendet werden.
      ChangeNotifierProvider(create: (_) => SearchNotifier(searchRecipesUsecase: searchRecipesUsecase)),
      // Füge hier weitere ChangeNotifierProvider oder andere Provider hinzu
    ];
  }
}