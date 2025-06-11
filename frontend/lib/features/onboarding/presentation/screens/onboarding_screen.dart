import 'package:flutter/material.dart';
import '../widget/preference_chips.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _dietPreferences = [];
  final List<String> _allergies = [];
  String? _goal;

  void _completeOnboarding() {
    // TODO: Call ViewModel or API here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _buildIntro(),
          PreferenceChips(
            title: 'Was isst du gerne?',
            options: ['Vegan', 'Vegetarisch', 'Low Carb', 'Keto'],
            selection: _dietPreferences,
          ),
          PreferenceChips(
            title: 'Hast du Allergien?',
            options: ['Gluten', 'Laktose', 'Nüsse', 'Soja'],
            selection: _allergies,
          ),
          _buildGoalSelector(),
          _buildSummary(),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
            Row(
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
            TextButton(
              child: Text(_currentPage == 4 ? "Fertig" : "Weiter"),
              onPressed: () {
                if (_currentPage == 4) {
                  _completeOnboarding();
                } else {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Willkommen bei Mealo! Lass uns deine Vorlieben kennenlernen.',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _buildGoalSelector() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Was ist dein Ziel?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButton<String>(
            isExpanded: true,
            value: _goal,
            hint: const Text("Ziel auswählen"),
            items: ['Abnehmen', 'Muskelaufbau', 'Gesund bleiben']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => setState(() => _goal = val),
          )
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Du bist bereit!', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          const Text('Du kannst deine Angaben später jederzeit anpassen.'),
        ],
      ),
    );
  }
}
