// lib/core/providers/app_providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/providers/current_tab_provider.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';

// Importiere alle Abhängigkeiten für die Instanziierung der Notifier
import 'package:frontend/services/api_client.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    // Hier instanziieren wir die Kern-Services, die von Notifiern benötigt werden
    final ApiClient apiClient = ApiClient();
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);
    final RecipeRepositoryImpl recipeRepository = RecipeRepositoryImpl(recipeApiDataSource);
    final SearchRecipes searchRecipesUsecase = SearchRecipes(recipeRepository);

    return [
      ChangeNotifierProvider(create: (_) => SelectedIngredientsProvider()),
      ChangeNotifierProvider(create: (_) => CurrentTabProvider()),
      // Nun kann der SearchNotifier hier mit seinen Abhängigkeiten erstellt werden
      ChangeNotifierProvider(create: (_) => SearchNotifier(searchRecipesUsecase)),
      // Füge hier weitere ChangeNotifierProvider oder andere Provider hinzu
    ];
  }
}