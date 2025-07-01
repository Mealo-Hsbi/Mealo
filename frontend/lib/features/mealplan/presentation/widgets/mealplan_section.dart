import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/data/mock_recipes.dart';
import 'package:frontend/features/search/presentation/screens/search_screen.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';

class MealPlanSection extends StatefulWidget {
  MealPlanSection({Key? key}) : super(key: key);

  @override
  State<MealPlanSection> createState() => _MealPlanSectionState();
}

class _MealPlanSectionState extends State<MealPlanSection> {
  final List<String> days = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  final List<String> meals = const [
    'Breakfast', 'Lunch', 'Dinner'
  ];

  // Mutable meal plan state
  late Map<String, Map<String, Map<String, dynamic>>> mealPlan;

  // Präferenz-Optionen für die automatische Generierung
  final List<String> dietOptions = [
    'Vegetarian', 'Vegan', 'Gluten Free', 'Ketogenic', 'Pescetarian'
  ];
  Set<String> selectedDiets = {};

  @override
  void initState() {
    super.initState();
    mealPlan = {
      for (var day in days)
        day: {
          for (var meal in meals) meal: {},
        },
    };
    // Beispielhafte Vorbelegung (optional)
    mealPlan['Mon']!['Breakfast'] = mockRecipes[0];
    mealPlan['Mon']!['Dinner'] = mockRecipes[1];
    mealPlan['Tue']!['Lunch'] = mockRecipes[2];
  }

  void _showPreferencesAndGenerate() async {
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        Set<String> tempSelected = {...selectedDiets};
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mealplan Preferences', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: dietOptions.map((diet) => FilterChip(
                        label: Text(diet),
                        selected: tempSelected.contains(diet),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              tempSelected.add(diet);
                            } else {
                              tempSelected.remove(diet);
                            }
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(tempSelected),
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedDiets = result;
      });
      _generateMealPlanWithPreferences(result);
    }
  }

  void _generateMealPlanWithPreferences(Set<String> diets) async {
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        final filtered = mockRecipes.where((r) {
          if (diets.isEmpty) return true;
          final title = r['title'].toString().toLowerCase();
          return diets.any((diet) => title.contains(diet.toLowerCase()));
        }).toList();
        final random = filtered.isNotEmpty ? filtered : mockRecipes;
        if (random.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keine passenden Rezepte gefunden!')),
          );
        }
        random.shuffle();
        int recipeIdx = 0;
        for (var day in days) {
          for (var meal in meals) {
            mealPlan[day]![meal] = random[recipeIdx % random.length];
            recipeIdx++;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der Generierung: $e')),
      );
    } finally {
      if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
        Navigator.of(dialogContext!).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mealplan wurde automatisch erstellt!')),
      );
    }
  }

  void _showRecipePicker(String day, String meal) async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: ChangeNotifierProvider<SearchNotifier>.value(
            value: Provider.of<SearchNotifier>(context, listen: false),
            child: _RecipeSearchPicker(
              onRecipeSelected: (recipe) => Navigator.of(context).pop(recipe),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        mealPlan[day]![meal] = selected;
      });
    }
  }

  void _showShoppingList() {
    // Zutaten aggregieren
    final Set<String> ingredients = {};
    for (var day in days) {
      for (var meal in meals) {
        final recipe = mealPlan[day]?[meal] ?? {};
        if (recipe.isNotEmpty && recipe['ingredients'] != null) {
          ingredients.addAll(List<String>.from(recipe['ingredients']));
        }
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Shopping List', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                if (ingredients.isEmpty)
                  const Text('No ingredients yet.'),
                ...ingredients.map((ing) => ListTile(
                      leading: const Icon(Icons.check_box_outline_blank, size: 20),
                      title: Text(ing),
                    )),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageController = PageController(viewportFraction: 0.92, initialPage: DateTime.now().weekday - 1);
    int currentPage = DateTime.now().weekday - 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Mealplan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.deepPurple, size: 28),
                          tooltip: 'Generate automatically',
                          onPressed: _showPreferencesAndGenerate,
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.green, size: 28),
                          tooltip: 'Show shopping list',
                          onPressed: _showShoppingList,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 28),
                          tooltip: 'Reset mealplan',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Mealplan zurücksetzen?'),
                                content: const Text('Willst du wirklich den gesamten Mealplan löschen?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Abbrechen'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Löschen'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              setState(() {
                                for (var day in days) {
                                  for (var meal in meals) {
                                    mealPlan[day]![meal] = {};
                                  }
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mealplan wurde zurückgesetzt.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  days[currentPage],
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 320,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: days.length,
                    onPageChanged: (idx) => setState(() => currentPage = idx),
                    itemBuilder: (context, dayIdx) {
                      final day = days[dayIdx];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...meals.map((meal) {
                                final mealData = mealPlan[day]?[meal] ?? {};
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: (mealData.isNotEmpty)
                                      ? _MealSlotCard(
                                          title: mealData['title'],
                                          imageUrl: mealData['image'],
                                          onRemove: () {
                                            setState(() {
                                              mealPlan[day]![meal] = {};
                                            });
                                          },
                                          large: true,
                                        )
                                      : _AddMealSlotButton(meal: meal, onTap: () => _showRecipePicker(day, meal)),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MealSlotCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onRemove;
  final bool large;
  const _MealSlotCard({required this.title, required this.imageUrl, this.onRemove, this.large = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: large ? 72 : 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(large ? 16 : 12),
      ),
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 6, vertical: large ? 8 : 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(large ? 12 : 8),
            child: Image.network(imageUrl, width: large ? 56 : 36, height: large ? 56 : 36, fit: BoxFit.cover),
          ),
          SizedBox(width: large ? 18 : 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: large ? 18 : 16),
              overflow: TextOverflow.ellipsis,
              maxLines: large ? 3 : 2,
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close, size: large ? 24 : 20, color: Colors.redAccent),
              tooltip: 'Entfernen',
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _AddMealSlotButton extends StatelessWidget {
  final String meal;
  final VoidCallback onTap;
  const _AddMealSlotButton({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(meal, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

// Neues Widget für die Rezeptauswahl mit echter Such-UI
class _RecipeSearchPicker extends StatelessWidget {
  final void Function(Map<String, dynamic> recipe) onRecipeSelected;
  const _RecipeSearchPicker({required this.onRecipeSelected});

  @override
  Widget build(BuildContext context) {
    // Hole die UseCases aus dem globalen Provider
    final globalNotifier = Provider.of<SearchNotifier>(context, listen: false);
    return ChangeNotifierProvider<SearchNotifier>(
      create: (context) {
        final notifier = SearchNotifier(
          searchRecipesByQueryUsecase: globalNotifier.searchRecipesByQueryUsecase,
          searchRecipesByIngredientsUsecase: globalNotifier.searchRecipesByIngredientsUsecase,
        );
        notifier.initializeSearch([]); // Frischer Zustand
        return notifier;
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SearchScreenWrapper(onRecipeSelected: onRecipeSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchScreenWrapper extends StatelessWidget {
  final void Function(Map<String, dynamic> recipe) onRecipeSelected;
  const SearchScreenWrapper({required this.onRecipeSelected});

  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      onRecipeTap: (recipe) {
        final allIngredients = [
          ...?recipe.usedIngredients,
          ...?recipe.missedIngredients,
        ];
        onRecipeSelected({
          'title': recipe.name,
          'image': recipe.imageUrl,
          'ingredients': allIngredients.map((e) => e.name).toList(),
        });
      },
    );
  }
} 