import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/common/models/mealplan.dart';
import '../../data/datasources/mealplan_remote_datasource.dart';
import '../../data/repositories/mealplan_repository_impl.dart';
import '../../domain/usecases/get_current_mealplan.dart';
import '../../domain/usecases/update_current_mealplan.dart';
import 'package:frontend/services/api_client.dart';
import 'package:intl/intl.dart';

final mealplanProvider = StateNotifierProvider<MealplanNotifier, AsyncValue<Mealplan>>((ref) {
  final apiClient = ApiClient();
  final datasource = MealplanRemoteDatasource(apiClient);
  final repository = MealplanRepositoryImpl(datasource);
  return MealplanNotifier(
    getCurrentMealplan: GetCurrentMealplan(repository),
    updateCurrentMealplan: UpdateCurrentMealplan(repository),
  );
});

class MealplanNotifier extends StateNotifier<AsyncValue<Mealplan>> {
  final GetCurrentMealplan getCurrentMealplan;
  final UpdateCurrentMealplan updateCurrentMealplan;

  MealplanNotifier({required this.getCurrentMealplan, required this.updateCurrentMealplan}) : super(const AsyncLoading()) {
    loadMealplan();
  }

  Future<void> loadMealplan() async {
    state = const AsyncLoading();
    try {
      final mealplan = await getCurrentMealplan();
      state = AsyncData(mealplan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Hilfsfunktion: Wochentag ("Mon") -> Datum (YYYY-MM-DD) der aktuellen Woche
  String _isoDateForDay(String day) {
    final now = DateTime.now();
    // Finde Montag dieser Woche
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final offset = daysOfWeek.indexOf(day);
    final date = monday.add(Duration(days: offset));
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Future<void> saveMealplan(Mealplan mealplan) async {
    try {
      // Mapping: days -> items[]
      final items = <Map<String, dynamic>>[];
      mealplan.days.forEach((dateKey, meals) {
        meals.forEach((mealType, recipe) {
          if (recipe != null && (recipe.id != null || recipe.internalId != null)) {
            items.add({
              'date': dateKey,
              'mealType': mealType,
              'recipeId': recipe.internalId ?? recipe.id,
              'spoonacularId': recipe.id,
              'recipeData': recipe.toJson(),
            });
          }
        });
      });
      final payload = {
        'items': items,
      };
      await updateCurrentMealplan(payload);
      await loadMealplan();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void updateMeal(String dateKey, String meal, dynamic recipeModel) {
    final current = state.value ?? Mealplan.empty();
    final dayMap = current.days[dateKey] ?? {
      'Breakfast': null,
      'Lunch': null,
      'Dinner': null,
    };
    final updated = Mealplan(
      id: current.id,
      days: {
        ...current.days,
        dateKey: {
          ...dayMap,
          meal: recipeModel,
        },
      },
    );
    
    // Optimistic Update: UI sofort aktualisieren
    state = AsyncData(updated);
    
    // Backend-Update im Hintergrund
    _saveMealplanInBackground(updated);
  }

  // Hintergrund-Update ohne UI-Blockierung
  Future<void> _saveMealplanInBackground(Mealplan mealplan) async {
    try {
      // Mapping: days -> items[]
      final items = <Map<String, dynamic>>[];
      mealplan.days.forEach((dateKey, meals) {
        meals.forEach((mealType, recipe) {
          if (recipe != null && (recipe.id != null || recipe.internalId != null)) {
            items.add({
              'date': dateKey,
              'mealType': mealType,
              'recipeId': recipe.internalId ?? recipe.id,
              'spoonacularId': recipe.id,
              'recipeData': recipe.toJson(),
            });
          }
        });
      });
      final payload = {
        'items': items,
      };
      await updateCurrentMealplan(payload);
      
      // Nach erfolgreichem Update den aktuellen Stand vom Server holen
      // für die Shopping List (Zutaten werden vom Backend geladen)
      await loadMealplan();
    } catch (e, st) {
      // Bei Fehler: UI auf vorherigen Stand zurücksetzen
      print('Fehler beim Speichern des Mealplans: $e');
      // Optional: Snackbar oder Toast anzeigen
    }
  }

  void resetMealplan() {
    final empty = Mealplan.empty();
    
    // Optimistic Update: UI sofort leeren
    state = AsyncData(empty);
    
    // Backend-Update im Hintergrund
    _saveMealplanInBackground(empty);
  }

  Future<void> generateMealplan(String? diet) async {
    try {
      print('[MealplanProvider] Starting mealplan generation for diet: $diet');
      
      // Call backend to generate mealplan
      final response = await ApiClient().post('/mealplan/generate', data: {
        if (diet != null) 'diet': diet,
        'timeFrame': 'week',
        'targetCalories': 2000,
      });
      
      print('[MealplanProvider] Backend response received: ${response.statusCode}');
      
      // Reload mealplan after generation
      await loadMealplan();
      
      print('[MealplanProvider] Mealplan generation completed successfully');
    } catch (e, st) {
      print('[MealplanProvider] Error in generateMealplan: $e');
      print('[MealplanProvider] Stack trace: $st');
      state = AsyncError(e, st);
      rethrow;
    }
  }
} 