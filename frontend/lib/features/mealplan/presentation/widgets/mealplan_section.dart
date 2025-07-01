import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/data/mock_recipes.dart';
import 'package:frontend/features/search/presentation/screens/search_screen.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';
import 'package:frontend/common/models/mealplan.dart';
import 'package:frontend/common/models/recipe_model.dart';
import 'package:frontend/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mealplan_provider.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:frontend/common/models/ingredient.dart';

class MealPlanSection extends ConsumerStatefulWidget {
  const MealPlanSection({Key? key}) : super(key: key);

  @override
  ConsumerState<MealPlanSection> createState() => _MealPlanSectionState();
}

class _MealPlanSectionState extends ConsumerState<MealPlanSection> {
  // State to track checked ingredients in shopping list
  final Set<String> _checkedIngredients = <String>{};

  final List<String> meals = const [
    'Breakfast', 'Lunch', 'Dinner'
  ];

  String getWeekdayAbbreviation(String dateKey) {
    final date = DateTime.parse(dateKey);
    return DateFormat('E').format(date); // z.B. 'Mon', 'Tue', ...
  }

  final List<String> dietOptions = [
    'Vegetarian', 'Vegan', 'Gluten Free', 'Ketogenic', 'Pescetarian'
  ];

  final List<String> weekDays = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  void _showShoppingList(Mealplan mealplan) {
    // Sammle alle Zutaten
    final allIngredients = <Ingredient>[];
    mealplan.days.forEach((_, meals) {
      meals.forEach((_, recipe) {
        if (recipe != null) {
          if (recipe.usedIngredients != null) {
            allIngredients.addAll(recipe.usedIngredients!);
          }
          if (recipe.missedIngredients != null) {
            allIngredients.addAll(recipe.missedIngredients!);
          }
        }
      });
    });

    // Gruppiere Zutaten nach Namen und addiere Mengen
    final ingredientGroups = <String, List<Ingredient>>{};
    for (final ingredient in allIngredients) {
      if (ingredient.name != null) {
        final normalizedName = ingredient.name!.toLowerCase().trim();
        ingredientGroups.putIfAbsent(normalizedName, () => []).add(ingredient);
      }
    }

    // Erstelle zusammengefasste Zutaten
    final mergedIngredients = <Ingredient>[];
    ingredientGroups.forEach((name, ingredients) {
      if (ingredients.length == 1) {
        // Nur eine Zutat mit diesem Namen
        mergedIngredients.add(ingredients.first);
      } else {
        // Mehrere Zutaten mit gleichem Namen - versuche zu addieren
        final firstIngredient = ingredients.first;
        double? totalAmount;
        String? commonUnit;
        bool canMerge = true;

        // Prüfe ob alle Zutaten die gleiche Einheit haben
        for (final ingredient in ingredients) {
          if (ingredient.unit != firstIngredient.unit) {
            canMerge = false;
            break;
          }
        }

        if (canMerge) {
          // Addiere Mengen
          totalAmount = 0.0;
          for (final ingredient in ingredients) {
            if (ingredient.amount != null) {
              totalAmount = totalAmount! + ingredient.amount!;
            }
          }
          commonUnit = firstIngredient.unit;
        }

        // Erstelle zusammengefasste Zutat oder behalte separate Einträge
        if (canMerge && totalAmount != null) {
          mergedIngredients.add(Ingredient(
            id: firstIngredient.id,
            name: firstIngredient.name,
            imageUrl: firstIngredient.imageUrl,
            aliases: firstIngredient.aliases,
            amount: totalAmount,
            unit: commonUnit,
            original: '${totalAmount}${commonUnit != null ? ' $commonUnit' : ''} ${firstIngredient.name}',
          ));
        } else {
          // Kann nicht zusammengefasst werden - behalte alle separaten Einträge
          mergedIngredients.addAll(ingredients);
        }
      }
    });

    final ingredients = mergedIngredients.where((i) => i.name != null).toList();
    ingredients.sort((a, b) => a.name!.compareTo(b.name!));
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Shopping List'),
          content: SizedBox(
            width: double.maxFinite,
            child: ingredients.isEmpty
                ? const Text('No ingredients in your meal plan.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      final ingredientKey = '${ingredient.name}_${ingredient.amount}_${ingredient.unit}';
                      final isChecked = _checkedIngredients.contains(ingredientKey);
                      
                      return ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _checkedIngredients.add(ingredientKey);
                              } else {
                                _checkedIngredients.remove(ingredientKey);
                              }
                            });
                            // Also update the dialog state to rebuild immediately
                            setDialogState(() {});
                          },
                        ),
                        title: Text([
                          if (ingredient.amount != null) ingredient.amount,
                          if ((ingredient.unit ?? '').isNotEmpty) ingredient.unit,
                          ingredient.name ?? ''
                        ].where((e) => e != null && e.toString().isNotEmpty).join(' ')),
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _checkedIngredients.remove(ingredientKey);
                            } else {
                              _checkedIngredients.add(ingredientKey);
                            }
                          });
                          // Also update the dialog state to rebuild immediately
                          setDialogState(() {});
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final mealplanAsync = ref.watch(mealplanProvider);
    final mealplanNotifier = ref.read(mealplanProvider.notifier);
    final List<String> meals = const [
      'Breakfast', 'Lunch', 'Dinner'
    ];
    final List<String> weekDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (mealplanAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (mealplanAsync.hasError) {
      print('[MealPlanSection] Error: ${mealplanAsync.error}');
      print('[MealPlanSection] Stack trace: ${mealplanAsync.stackTrace}');
      return Center(child: Text('Fehler beim Laden des Mealplans: ${mealplanAsync.error}'));
    }
    final mealplan = mealplanAsync.value!;
    print('[MealPlanSection] mealplan.days: \n${mealplan.days}');
    print('Date-Keys in mealplan.days: \n${mealplan.days.keys.toList()}');

    final dateKeys = getCurrentWeekDateKeys();
    final sortedDateKeys = mealplan.days.keys.toList()..sort();

    void _showRecipePicker(String dateKey, String meal) async {
      final selected = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final topPadding = MediaQuery.of(context).padding.top + 16;
          return Container(
            margin: EdgeInsets.only(top: topPadding),
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _RecipeSearchPicker(
              onRecipeSelected: (recipe) => Navigator.of(context).pop(recipe),
            ),
          );
        },
      );
      if (selected != null) {
        mealplanNotifier.updateMeal(dateKey, meal, RecipeModel.fromJson(selected));
      }
    }



    void _generateMealplan(String diet) async {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Generating your meal plan...'),
              ],
            ),
          ),
        );

        // Call backend to generate mealplan
        await mealplanNotifier.generateMealplan(diet);
        
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal plan generated with $diet diet!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating meal plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void _showPreferencesAndGenerate() async {
      String? selectedDiet;
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Diet Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose your dietary preferences:'),
              const SizedBox(height: 16),
              ...dietOptions.map((diet) => RadioListTile<String>(
                title: Text(diet),
                value: diet,
                groupValue: selectedDiet,
                onChanged: (value) {
                  setState(() {
                    selectedDiet = value;
                  });
                },
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedDiet == null ? null : () {
                Navigator.of(context).pop();
                _generateMealplan(selectedDiet!);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      );


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
                Text('Your Mealplan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
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
                      onPressed: () => _showShoppingList(mealplan),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary, size: 28),
                      tooltip: 'Reset mealplan',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reset meal plan?'),
                            content: const Text('Do you really want to reset your entire meal plan?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Yes, reset'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          mealplanNotifier.resetMealplan();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Tabellenkopf
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  const SizedBox(width: 60, child: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                  ...meals.map((meal) => Expanded(
                    child: Center(child: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold))),
                  )),
                ],
              ),
            ),
            const Divider(),
            // Wochenansicht
            ...List.generate(7, (i) {
              final dateKey = dateKeys[i];
              final date = DateTime.parse(dateKey);
              final weekday = weekDays[date.weekday - 1];
              final dayMeals = mealplan.days[dateKey] ?? {};
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                weekday,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('dd.MM.').format(date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...meals.map((mealType) {
                        final recipe = dayMeals[mealType];
                        if (recipe == null) {
                          return Expanded(
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary, size: 32),
                                tooltip: 'Add $mealType',
                                onPressed: () => _showRecipePicker(dateKey, mealType),
                              ),
                            ),
                          );
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipeId: recipe.id,
                                    internalRecipeId: recipe.internalId,
                                    isInternal: recipe.isInternal ?? false,
                                    initialImageUrl: recipe.imageUrl ?? '',
                                    initialName: recipe.name ?? '',
                                    initialPlace: recipe.place ?? '',
                                    initialReadyInMinutes: recipe.readyInMinutes,
                                    containsUserAllergens: recipe.containsUserAllergens,
                                    matchedAllergens: recipe.matchedAllergens,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove recipe?'),
                                  content: Text('Do you want to remove "${recipe.name}" from your meal plan?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        mealplanNotifier.updateMeal(dateKey, mealType, null);
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (recipe.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        recipe.imageUrl!,
                                        height: 50,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.name ?? '-',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
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
    final globalNotifier = legacy_provider.Provider.of<SearchNotifier>(context, listen: false);
    return legacy_provider.ChangeNotifierProvider<SearchNotifier>(
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
        onRecipeSelected(recipe.toJson());
      },
    );
  }
}

// Hilfsfunktion: Liefert die 7 Datums-Strings (yyyy-MM-dd) der aktuellen Woche (Mo-So)
List<String> getCurrentWeekDateKeys() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return List.generate(7, (i) {
    final date = monday.add(Duration(days: i));
    return DateFormat('yyyy-MM-dd').format(date);
  });
} 