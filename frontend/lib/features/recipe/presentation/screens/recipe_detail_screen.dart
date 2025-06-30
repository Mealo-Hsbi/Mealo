// lib/features/recipeDetails/presentation/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';

// Importiere deine ausgelagerten Modelle
import 'package:frontend/common/models/recipe/recipe_details.dart'; // Wichtig: Für RecipeDetails
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_detail_app_bar.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_detail_content.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:frontend/features/search/domain/usecases/get_recipe_details.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/services/api_client.dart';


class RecipeDetailScreen extends StatefulWidget {
  final int? recipeId; // Dies ist die spoonacularId, die zum Laden der Details verwendet wird
  final String? internalRecipeId;
  final bool isInternal;

  final String initialImageUrl;
  final String initialName;
  final String initialPlace;
  final int? initialReadyInMinutes;
  final bool? containsUserAllergens;
  final List<String>? matchedAllergens;

  const RecipeDetailScreen({
    super.key,
    this.recipeId,
    this.internalRecipeId,
    this.isInternal = false,
    required this.initialImageUrl,
    required this.initialName,
    required this.initialPlace,
    this.initialReadyInMinutes,
    this.containsUserAllergens,
    this.matchedAllergens,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  RecipeDetails? _recipeDetails; // Dieses Objekt hält die geladenen Details
  bool _isLoading = true;
  String? _errorMessage;

  late GetRecipeDetails _getRecipeDetailsUseCase;

  double? _latestAverageRating;
  int? _latestRatingCount;

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
      final details = await _getRecipeDetailsUseCase(
        recipeId: widget.recipeId,
        internalRecipeId: widget.internalRecipeId,
        isInternal: widget.isInternal,
      );
      setState(() {
        _recipeDetails = details;
        _latestAverageRating = details.averageRating;
        _latestRatingCount = details.ratingCount;
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

  void _onRatingChanged(double newAverage, int newCount) {
    setState(() {
      _latestAverageRating = newAverage;
      _latestRatingCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'averageRating': _latestAverageRating ?? _recipeDetails?.averageRating,
          'ratingCount': _latestRatingCount ?? _recipeDetails?.ratingCount,
        });
        return false;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Ausgelagerte AppBar
            RecipeDetailAppBar(
              imageUrl: widget.initialImageUrl,
              title: widget.initialName,
            ),
            SliverToBoxAdapter(
              child: (widget.containsUserAllergens == true && (widget.matchedAllergens?.isNotEmpty ?? false))
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'This recipe contains: ${(widget.matchedAllergens ?? []).join(", ")}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Ausgelagerter Hauptinhalt
            RecipeDetailContent(
              initialName: widget.initialName,
              initialPlace: widget.initialPlace,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              recipeDetails: _recipeDetails,
              onRatingChanged: _onRatingChanged,
            ),
          ],
        ),
      ),
    );
  }
}