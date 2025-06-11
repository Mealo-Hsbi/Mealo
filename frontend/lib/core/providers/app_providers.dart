
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_ingredients.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_query.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:frontend/providers/current_tab_provider.dart';
import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    // Hier instanziieren wir die Kern-Services, die von Notifiern benötigt werden
    final ApiClient apiClient = ApiClient();
    
    // Instanziierung der DataSource-Implementierung
    // Dies sollte nun eindeutig sein, wenn keine Re-Exports vorliegen.
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);

    // Instanziierung des Repository
    // Behebt "The method 'RecipeRepositoryImpl' isn't defined"
    final RecipeRepositoryImpl recipeRepository = RecipeRepositoryImpl(remoteDataSource: recipeApiDataSource);

    // **KORREKTUR:** Instanziierung BEIDER neuer Use Cases
    // Behebt "Undefined class 'SearchRecipes'" und "The method 'SearchRecipes' isn't defined"
    final SearchRecipesByQuery searchRecipesByQueryUsecase = SearchRecipesByQuery(recipeRepository);
    final SearchRecipesByIngredients searchRecipesByIngredientsUsecase = SearchRecipesByIngredients(recipeRepository);

    return [
      ChangeNotifierProvider(create: (_) => SelectedIngredientsProvider()),
      ChangeNotifierProvider(create: (_) => CurrentTabProvider()),
      // **KORREKTUR:** Der SearchNotifier muss nun BEIDE Use Cases erhalten
      // Behebt "The named parameter 'searchRecipesByQueryUsecase' is required..."
      ChangeNotifierProvider(
        create: (_) => SearchNotifier(
          searchRecipesByQueryUsecase: searchRecipesByQueryUsecase,
          searchRecipesByIngredientsUsecase: searchRecipesByIngredientsUsecase,
        ),
      ),
      // Füge hier weitere ChangeNotifierProvider oder andere Provider hinzu
    ];
  }
}