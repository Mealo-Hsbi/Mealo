import 'package:flutter/material.dart';

class IngredientReviewScreen extends StatefulWidget {
  final List<String> ingredients; // Die erkannten Zutaten vom CameraScreen

  const IngredientReviewScreen({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  State<IngredientReviewScreen> createState() => _IngredientReviewScreenState();
}

class _IngredientReviewScreenState extends State<IngredientReviewScreen> {
  // Hier könntest du später einen lokalen Zustand für die bearbeitbaren Zutaten halten.
  // Zum Beispiel:
  // List<String> _editableIngredients = [];

  @override
  void initState() {
    super.initState();
    // Wenn du eine lokale Kopie der Zutaten machen möchtest, um sie zu bearbeiten:
    // _editableIngredients = List.from(widget.ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zutaten überprüfen'),
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
              'Wir haben folgende Zutaten erkannt:',
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
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Hier später die Logik zum Anzeigen der Rezepte implementieren
                print('Zutaten bestätigt! Navigiere zu Rezepten.');
                // Beispiel: Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //     builder: (context) => RecipeResultsScreen(
                //       finalIngredients: _editableIngredients, // Oder widget.ingredients
                //     ),
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Rezepte finden!',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}