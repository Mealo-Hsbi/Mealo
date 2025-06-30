
// lib/core/providers/app_providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_ingredients.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_query.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:frontend/providers/current_tab_provider.dart';
import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/services/api_client.dart';

// NEUE IMPORTS für Favoriten und Bewertungen
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart';

// WICHTIG: Korrekter Import für IHRE implementierte DataSource
import 'package:frontend/features/recipe/data/datasources/recipe_interaction_remote_datasource.dart'; // <-- Dies ist IHR Pfad zu Interface UND Implementierung
import 'package:frontend/features/recipe/data/repositories/recipe_interaction_repository_impl.dart'; // Annahme: Pfad zum Repository

import 'package:frontend/features/recipe/domain/usecases/add_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/remove_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/get_favorite_recipes.dart';
import 'package:frontend/features/recipe/domain/usecases/is_recipe_favorited.dart';
import 'package:frontend/features/recipe/domain/usecases/add_or_update_recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/get_user_recipe_rating.dart';


// 🔽 NEU: Imports für ProfileViewModel und seine Abhängigkeiten
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:frontend/features/profile/domain/usecases/get_profile.dart';
import 'package:frontend/features/profile/domain/usecases/upload_avatar.dart';

// 🔽 NEU: Imports für AchievementProvider
import 'package:frontend/features/profile/presentation/providers/achievement_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    final ApiClient apiClient = ApiClient();

    // 🔎 SEARCH Feature
    final RecipeApiDataSourceImpl recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);
    final RecipeRepositoryImpl recipeRepository = RecipeRepositoryImpl(remoteDataSource: recipeApiDataSource);
    final SearchRecipesByQuery searchRecipesByQueryUsecase = SearchRecipesByQuery(recipeRepository);
    final SearchRecipesByIngredients searchRecipesByIngredientsUsecase = SearchRecipesByIngredients(recipeRepository);

    // ⭐ FAVORITEN & ⭐ BEWERTUNGEN
    final RecipeInteractionRemoteDataSourceImpl recipeInteractionDataSource = RecipeInteractionRemoteDataSourceImpl(apiClient);
    final RecipeInteractionRepositoryImpl recipeInteractionRepository = RecipeInteractionRepositoryImpl(
      remoteDataSource: recipeInteractionDataSource,
    );

    final AddFavoriteRecipe addFavoriteRecipeUseCase = AddFavoriteRecipe(recipeInteractionRepository);
    final RemoveFavoriteRecipe removeFavoriteRecipeUseCase = RemoveFavoriteRecipe(recipeInteractionRepository);
    final GetFavoriteRecipes getFavoriteRecipesUseCase = GetFavoriteRecipes(recipeInteractionRepository);
    final IsRecipeFavorited isRecipeFavoritedUseCase = IsRecipeFavorited(recipeInteractionRepository);

    final AddOrUpdateRecipeRating addOrUpdateRecipeRatingUseCase = AddOrUpdateRecipeRating(recipeInteractionRepository);
    final GetUserRecipeRating getUserRecipeRatingUseCase = GetUserRecipeRating(recipeInteractionRepository);

    // 👤 PROFILE Feature
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(apiClient);
    final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource, apiClient);

    return [
      ChangeNotifierProvider(create: (_) => SelectedIngredientsProvider()),
      ChangeNotifierProvider(create: (_) => CurrentTabProvider()),
      ChangeNotifierProvider(
        create: (_) => SearchNotifier(
          searchRecipesByQueryUsecase: searchRecipesByQueryUsecase,
          searchRecipesByIngredientsUsecase: searchRecipesByIngredientsUsecase,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => FavoriteNotifier(
          addFavoriteRecipeUseCase: addFavoriteRecipeUseCase,
          removeFavoriteRecipeUseCase: removeFavoriteRecipeUseCase,
          getFavoriteRecipesUseCase: getFavoriteRecipesUseCase,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => RatingNotifier(
          addOrUpdateRecipeRatingUseCase: addOrUpdateRecipeRatingUseCase,
          getUserRecipeRatingUseCase: getUserRecipeRatingUseCase,
        ),
      ),
      ChangeNotifierProvider<ProfileViewModel>(
        create: (_) => ProfileViewModel(
          GetProfile(profileRepository),
          UploadAvatar(profileRepository),
          profileRepository,
        ),
      ),
      // 🔽 NEU: AchievementProvider
      ChangeNotifierProvider<AchievementProvider>(
        create: (_) => AchievementProvider(),
      ),
    ];
  }
}

