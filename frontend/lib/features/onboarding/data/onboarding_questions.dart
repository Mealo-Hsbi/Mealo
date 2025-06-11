import 'package:flutter/material.dart';

class OnboardingQuestion {
  final String title;
  final List<OnboardingOption> options;

  OnboardingQuestion({required this.title, required this.options});
}

class OnboardingOption {
  final String label;
  final IconData? icon;

  OnboardingOption({required this.label, this.icon});
}

final List<OnboardingQuestion> onboardingQuestions = [
  OnboardingQuestion(
    title: 'Was isst du gerne?',
    options: [
      OnboardingOption(label: 'Vegan', icon: Icons.eco),
      OnboardingOption(label: 'Vegetarisch', icon: Icons.spa),
      OnboardingOption(label: 'Low Carb', icon: Icons.fitness_center),
      OnboardingOption(label: 'Keto', icon: Icons.local_fire_department),
    ],
  ),
  OnboardingQuestion(
    title: 'Hast du Allergien?',
    options: [
      OnboardingOption(label: 'Gluten', icon: Icons.no_food),
      OnboardingOption(label: 'Laktose', icon: Icons.icecream),
      OnboardingOption(label: 'Nüsse', icon: Icons.energy_savings_leaf),
      OnboardingOption(label: 'Soja', icon: Icons.local_dining),
    ],
  ),
  OnboardingQuestion(
    title: 'Was ist dein Ziel?',
    options: [
      OnboardingOption(label: 'Abnehmen', icon: Icons.downhill_skiing),
      OnboardingOption(label: 'Muskelaufbau', icon: Icons.fitness_center),
      OnboardingOption(label: 'Gesund bleiben', icon: Icons.favorite),
    ],
  ),
];
