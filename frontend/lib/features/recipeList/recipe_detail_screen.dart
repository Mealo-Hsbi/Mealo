// lib/features/recipeDetails/presentation/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/common/models/nutrition.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/common/models/recipe_details.dart';
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
    final repository = RecipeRepositoryImpl(dataSource);
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

  String _parseHtmlString(String htmlString) {
    final unescape = HtmlUnescape();
    String textWithoutTags = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    return unescape.convert(textWithoutTags);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double top = constraints.biggest.height;
                final bool isCollapsed = top < kToolbarHeight + 20;

                return FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.initialImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey[400])),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.6, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: AnimatedOpacity(
                    opacity: isCollapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.initialName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  stretchModes: const [StretchMode.zoomBackground],
                );
              },
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Haupttitel (unterhalb des Bildes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.initialName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Ort/Land
                    Text(
                      widget.initialPlace,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ladeindikator oder Fehlermeldung
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (_recipeDetails != null)
                      // Hier rufen wir die Methode auf, die alle Abschnitte enthält
                      _buildRecipeDetailsContent(_recipeDetails!)
                    else
                      const Center(child: Text('No recipe details available.', style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // --- Methode zum Bauen der detaillierten Rezeptinhalte ---
  Widget _buildRecipeDetailsContent(RecipeDetails details) {
    // Eine Hilfsfunktion, um Nährwerte aus der Liste zu finden
    double? _findNutrientValue(String name) {
      if (details.nutrition?.nutrients == null) return null;
      final nutrients = details.nutrition!.nutrients.where((n) => n.name == name);
      if (nutrients.isNotEmpty) {
        return nutrients.first.amount;
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servings und ReadyInMinutes
        _buildInfoRow(Icons.people_alt, 'Servings', details.servings?.toString() ?? 'N/A'),
        _buildInfoRow(Icons.access_time, 'Ready in', '${details.readyInMinutes ?? 'N/A'} min'),
        const SizedBox(height: 20),

        // Nährwertangaben - Dieser Block wird jetzt direkt hier angezeigt
        if (details.calories != null ||
            details.protein != null ||
            details.fat != null ||
            details.carbs != null ||
            details.sugar != null) ...[
          const Text('Nutrition Information:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          _buildNutritionRow('Calories', details.calories), // Direktzugriff auf das Feld
          _buildNutritionRow('Protein', details.protein, unit: 'g'),
          _buildNutritionRow('Fat', details.fat, unit: 'g'),
          _buildNutritionRow('Carbs', details.carbs, unit: 'g'),
          _buildNutritionRow('Sugar', details.sugar, unit: 'g'),
          const SizedBox(height: 20),
        ],

        // Health Score
        if (details.healthScore != null) ...[
          const Text('Health Score:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Text('${details.healthScore!.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
        ],

        // Zutaten
        if (details.extendedIngredients != null && details.extendedIngredients!.isNotEmpty) ...[
          const Text('Ingredients:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.extendedIngredients!.map((ing) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '• ${ing.original}',
                style: const TextStyle(fontSize: 16),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Zubereitungsanleitung
        if (details.analyzedInstructions != null && details.analyzedInstructions!.isNotEmpty) ...[
          const Text('Instructions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.analyzedInstructions!.expand((instructionSet) {
              return [
                if (instructionSet.name != null && instructionSet.name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Text(
                      instructionSet.name!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ...instructionSet.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '${step.number}. ${_parseHtmlString(step.step)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
              ];
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Zusammenfassung
        if (details.summary != null && details.summary!.isNotEmpty) ...[
          const Text('Summary:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Text(
            _parseHtmlString(details.summary!),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],

        // Link zur Originalquelle
        if (details.sourceUrl != null && details.sourceUrl!.isNotEmpty)
          GestureDetector(
            onTap: () => _launchUrl(details.sourceUrl!),
            child: Text(
              'View original recipe at: ${details.sourceName ?? 'Source'}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Hilfsmethode für Infobereich (Servings, Ready In)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Hilfsmethode für Nährwert-Zeilen
  Widget _buildNutritionRow(String label, double? value, {String unit = ''}) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 16)),
          Text(
            '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$unit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}