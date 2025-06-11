// lib/features/recipeDetails/presentation/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';

// Importiere deine ausgelagerten Modelle
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_detail_app_bar.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_detail_content.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/domain/usecases/get_recipe_details.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/services/api_client.dart';


class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String initialImageUrl;
  final String initialName;
  final String initialPlace;
  final int? initialReadyInMinutes;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.initialImageUrl,
    required this.initialName,
    required this.initialPlace,
    this.initialReadyInMinutes,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  RecipeDetails? _recipeDetails;
  bool _isLoading = true;
  String? _errorMessage;

  late GetRecipeDetails _getRecipeDetailsUseCase;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final dataSource = RecipeApiDataSourceImpl(apiClient);
    final repository = RecipeRepositoryImpl(remoteDataSource: dataSource);
    _getRecipeDetailsUseCase = GetRecipeDetails(repository);

    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _getRecipeDetailsUseCase(widget.recipeId);
      setState(() {
        _recipeDetails = details;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recipe details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Ausgelagerte AppBar
          RecipeDetailAppBar(
            imageUrl: widget.initialImageUrl,
            title: widget.initialName,
          ),
          // Ausgelagerter Hauptinhalt
          RecipeDetailContent(
            initialName: widget.initialName,
            initialPlace: widget.initialPlace,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            recipeDetails: _recipeDetails,
          ),
        ],
      ),
    );
  }
}