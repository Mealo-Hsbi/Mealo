import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/recipe_service.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRecipeListScreen extends StatefulWidget {
  const UserRecipeListScreen({Key? key}) : super(key: key);

  @override
  State<UserRecipeListScreen> createState() => _UserRecipeListScreenState();
}

class _UserRecipeListScreenState extends State<UserRecipeListScreen> {
  late Future<List<Recipe>> _futureRecipes;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureRecipes = _loadUserRecipes();
  }

  Future<List<Recipe>> _loadUserRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Nicht eingeloggt');
    }
    final token = await user.getIdToken();
    return await RecipeService.fetchUserRecipes(token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Rezepte'),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: \\${snapshot.error}'));
          }
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const Center(child: Text('Du hast noch keine eigenen Rezepte erstellt.'));
          }
          return ParallaxRecipes(
            recipes: recipes,
            scrollController: _scrollController,
            isLoadingMore: false,
            hasMore: false,
          );
        },
      ),
    );
  }
} 