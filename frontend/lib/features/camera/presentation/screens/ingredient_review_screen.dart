import 'package:flutter/material.dart';
import 'package:frontend/common/models/ingredient.dart';

class IngredientReviewScreen extends StatefulWidget {
  final List<Ingredient> ingredients; // List of Ingredient objects

  const IngredientReviewScreen({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  State<IngredientReviewScreen> createState() => _IngredientReviewScreenState();
}

class _IngredientReviewScreenState extends State<IngredientReviewScreen> {
  // You might keep a local state for editable ingredients here later.
  // For example:
  // List<String> _editableIngredients = [];

  @override
  void initState() {
    super.initState();
    // If you want to make a local copy of ingredients for editing:
    // _editableIngredients = List.from(widget.ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Ingredients'), // English text
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'We recognized the following ingredients:', // English text
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = widget.ingredients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Display image if imageUrl is available
                          // AND it successfully loads. Otherwise, it will be SizedBox.shrink()
                          if (ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.asset(
                                  ingredient.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // If image fails to load (e.g., path is wrong),
                                    // return an empty box so no space is taken.
                                    return SizedBox.shrink(); // <-- Changed here!
                                  },
                                ),
                              ),
                            ),
                          // Display ingredient name
                          Expanded(
                            child: Text(
                              ingredient.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement logic to show recipes here later
                print('Ingredients confirmed! Navigating to recipes.'); // English print statement
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Find Recipes!', // English text
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}