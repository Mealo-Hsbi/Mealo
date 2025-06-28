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

// 🔽 NEU: Imports für ProfileViewModel und seine Abhängigkeiten
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend/features/profile/domain/usecases/get_profile.dart';
import 'package:frontend/features/profile/domain/usecases/upload_avatar.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    final ApiClient apiClient = ApiClient();

    // 🔎 SEARCH-Feature Setup
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);
    final RecipeRepositoryImpl recipeRepository = RecipeRepositoryImpl(remoteDataSource: recipeApiDataSource);
    final SearchRecipesByQuery searchRecipesByQueryUsecase = SearchRecipesByQuery(recipeRepository);
    final SearchRecipesByIngredients searchRecipesByIngredientsUsecase = SearchRecipesByIngredients(recipeRepository);

    // Provider-Liste
    return [
      ChangeNotifierProvider(create: (_) => SelectedIngredientsProvider()),
      ChangeNotifierProvider(create: (_) => CurrentTabProvider()),

      ChangeNotifierProvider(
        create: (_) => SearchNotifier(
          searchRecipesByQueryUsecase: searchRecipesByQueryUsecase,
          searchRecipesByIngredientsUsecase: searchRecipesByIngredientsUsecase,
        ),
      ),

      // 👤 PROFILE-Feature Setup
      ChangeNotifierProvider<ProfileViewModel>(
        create: (_) {
          final profileRemoteDataSource = ProfileRemoteDataSourceImpl(apiClient);
          final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource, apiClient);
          return ProfileViewModel(
            GetProfile(profileRepository),
            UploadAvatar(profileRepository),
          );
        },
      ),
    ];
  }
}
