import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../common/models/ingredient.dart';
import '../../../../common/models/recipe/instruction_step.dart';
import '../../../../services/api_client.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _servingsController = TextEditingController();
  final _readyInMinutesController = TextEditingController();
  final _cookingMinutesController = TextEditingController();
  final _preparationMinutesController = TextEditingController();
  final _healthScoreController = TextEditingController();
  final _pricePerServingController = TextEditingController();
  final _weightWatcherPointsController = TextEditingController();

  File? _selectedImage;
  bool _isVegan = false;
  bool _isVegetarian = false;
  bool _isGlutenFree = false;
  bool _isDairyFree = false;
  List<String> _selectedDishTypes = [];
  List<Ingredient> _ingredients = [];
  List<InstructionStep> _steps = [];
  bool _isLoading = false;

  final List<String> _availableDishTypes = [
    'breakfast', 'lunch', 'dinner', 'dessert', 'snack', 'appetizer', 'salad', 'soup', 'main course', 'side dish'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _instructionsController.dispose();
    _servingsController.dispose();
    _readyInMinutesController.dispose();
    _cookingMinutesController.dispose();
    _preparationMinutesController.dispose();
    _healthScoreController.dispose();
    _pricePerServingController.dispose();
    _weightWatcherPointsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }



  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
    // Aktualisiere die Schrittnummern
    for (int i = 0; i < _steps.length; i++) {
      _steps[i] = InstructionStep(
        stepNumber: i + 1,
        description: _steps[i].description,
        durationMinutes: _steps[i].durationMinutes,
      );
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(currentUserIdProvider);

      if (userId == null) {
        throw Exception('Benutzer nicht angemeldet');
      }

      // Bild hochladen, falls vorhanden
      String? imageUrl;
      if (_selectedImage != null) {
        // TODO: Implementiere Bild-Upload-Service
        // imageUrl = await uploadImage(_selectedImage!);
      }

      final recipeData = {
        'title': _titleController.text.trim(),
        'imageUrl': imageUrl,
        'servings': int.tryParse(_servingsController.text),
        'readyInMinutes': int.tryParse(_readyInMinutesController.text),
        'cookingMinutes': int.tryParse(_cookingMinutesController.text),
        'preparationMinutes': int.tryParse(_preparationMinutesController.text),
        'dishTypes': _selectedDishTypes,
        'summary': _summaryController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'healthScore': double.tryParse(_healthScoreController.text),
        'pricePerServing': double.tryParse(_pricePerServingController.text),
        'vegan': _isVegan,
        'vegetarian': _isVegetarian,
        'glutenFree': _isGlutenFree,
        'dairyFree': _isDairyFree,
        'weightWatcherPoints': int.tryParse(_weightWatcherPointsController.text),
        'ingredients': _ingredients.map((i) => i.toJson()).toList(),
        'steps': _steps.map((s) => s.toJson()).toList(),
      };

      final apiClient = ApiClient();
      final response = await apiClient.post('/recipes', data: recipeData);
      
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rezept erfolgreich erstellt!')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Fehler beim Erstellen des Rezepts');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Recipe'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveRecipe,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bild-Auswahl
              _buildImageSection(),
              const SizedBox(height: 24),

              // Grundinformationen
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Ernährungsinformationen
              _buildNutritionSection(),
              const SizedBox(height: 24),

              // Zutaten
              _buildIngredientsSection(),
              const SizedBox(height: 24),

              // Schritte
              _buildStepsSection(),
              const SizedBox(height: 24),

              // Speichern-Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rezeptbild',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Bild hinzufügen'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
                hintText: 'e.g. Spaghetti Bolognese',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                hintText: 'Short description of the recipe',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Text)',
                hintText: 'General instructions (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Servings',
                      hintText: 'e.g. 4',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _readyInMinutesController,
                    decoration: const InputDecoration(
                      labelText: 'Ready in (min)',
                      hintText: 'e.g. 30',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookingMinutesController,
                    decoration: const InputDecoration(
                      labelText: 'Cooking time (min)',
                      hintText: 'e.g. 20',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _preparationMinutesController,
                    decoration: const InputDecoration(
                      labelText: 'Preparation time (min)',
                      hintText: 'e.g. 10',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Dish Types',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableDishTypes.map((type) {
                final isSelected = _selectedDishTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDishTypes.add(type);
                      } else {
                        _selectedDishTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _healthScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Health Score',
                      hintText: 'e.g. 80',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pricePerServingController,
                    decoration: const InputDecoration(
                      labelText: 'Price per serving',
                      hintText: 'e.g. 2.50',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightWatcherPointsController,
              decoration: const InputDecoration(
                labelText: 'Weight Watcher Points',
                hintText: 'e.g. 5',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Dietary Preferences',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Vegan'),
              value: _isVegan,
              onChanged: (value) => setState(() => _isVegan = value!),
            ),
            CheckboxListTile(
              title: const Text('Vegetarian'),
              value: _isVegetarian,
              onChanged: (value) => setState(() => _isVegetarian = value!),
            ),
            CheckboxListTile(
              title: const Text('Gluten-free'),
              value: _isGlutenFree,
              onChanged: (value) => setState(() => _isGlutenFree = value!),
            ),
            CheckboxListTile(
              title: const Text('Lactose-free'),
              value: _isDairyFree,
              onChanged: (value) => setState(() => _isDairyFree = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _addIngredientRow,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: 'Add ingredient',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Click the plus icon to add ingredients',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  return _buildIngredientRow(index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index) {
    final ingredient = _ingredients[index];
    final nameController = TextEditingController(text: ingredient.name);
    final amountController = TextEditingController(text: ingredient.amount?.toString() ?? '');
    final unitController = TextEditingController(text: ingredient.unit ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: nameController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Ingredient',
                hintText: 'e.g. Tomato',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                _ingredients[index] = ingredient.copyWith(name: value);
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: amountController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 2',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _ingredients[index] = ingredient.copyWith(
                  amount: double.tryParse(value),
                  original: '${value} ${ingredient.unit ?? ''} ${ingredient.name}',
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: unitController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g. g, ml',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                _ingredients[index] = ingredient.copyWith(
                  unit: value,
                  original: '${ingredient.amount ?? ''} ${value} ${ingredient.name}',
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeIngredient(index),
            tooltip: 'Remove ingredient',
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _addStepRow,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: 'Add step',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_steps.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Click the plus icon to add steps',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildStepRow(index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(int index) {
    final step = _steps[index];
    final descriptionController = TextEditingController(text: step.description);
    final durationController = TextEditingController(text: step.durationMinutes?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${step.stepNumber}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: descriptionController,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Chop the onions',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 1,
                onChanged: (value) {
                  _steps[index] = step.copyWith(description: value);
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: durationController,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Duration (min)',
                  hintText: 'e.g. 5',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _steps[index] = step.copyWith(durationMinutes: int.tryParse(value));
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeStep(index),
              tooltip: 'Remove step',
            ),
          ],
        ),
      ),
    );
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(Ingredient(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: '',
        amount: null,
        unit: '',
        original: '',
      ));
    });
  }

  void _addStepRow() {
    setState(() {
      _steps.add(InstructionStep(
        stepNumber: _steps.length + 1,
        description: '',
        durationMinutes: null,
      ));
    });
  }
}

 