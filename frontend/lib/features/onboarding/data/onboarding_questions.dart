import 'package:flutter/material.dart';

class OnboardingQuestion {
  final String title;
  final List<OnboardingOption> options;
  final IconData? questionIcon;

  OnboardingQuestion({
    required this.title,
    required this.options,
    this.questionIcon,
  });
}

class OnboardingOption {
  final String label;
  final IconData? icon;

  OnboardingOption({required this.label, this.icon});
}

final List<OnboardingQuestion> onboardingQuestions = [
  OnboardingQuestion(
    title: 'Was isst du gerne?',
    questionIcon: Icons.restaurant_menu,
    options: [
      OnboardingOption(label: 'Vegan', icon: Icons.eco),
      OnboardingOption(label: 'Vegetarisch', icon: Icons.spa),
      OnboardingOption(label: 'Low Carb', icon: Icons.fitness_center),
      OnboardingOption(label: 'Keto', icon: Icons.local_fire_department),
      OnboardingOption(label: 'Flexitarisch', icon: Icons.restaurant),
      OnboardingOption(label: 'Pescetarisch', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'Hast du Allergien?',
    questionIcon: Icons.warning_amber,
    options: [
      OnboardingOption(label: 'Gluten', icon: Icons.no_food),
      OnboardingOption(label: 'Laktose', icon: Icons.icecream),
      OnboardingOption(label: 'Nüsse', icon: Icons.energy_savings_leaf),
      OnboardingOption(label: 'Soja', icon: Icons.local_dining),
      OnboardingOption(label: 'Ei', icon: Icons.egg_alt),
      OnboardingOption(label: 'Fisch', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'Was ist dein Ziel?',
    questionIcon: Icons.flag,
    options: [
      OnboardingOption(label: 'Abnehmen', icon: Icons.trending_down),
      OnboardingOption(label: 'Muskelaufbau', icon: Icons.fitness_center),
      OnboardingOption(label: 'Gesund bleiben', icon: Icons.favorite),
      OnboardingOption(label: 'Mehr Energie', icon: Icons.bolt),
      OnboardingOption(label: 'Weniger Zucker', icon: Icons.no_food),
    ],
  ),
  OnboardingQuestion(
    title: 'Wie oft kochst du pro Woche?',
    questionIcon: Icons.schedule,
    options: [
      OnboardingOption(label: 'Täglich', icon: Icons.restaurant),
      OnboardingOption(label: '2–3x', icon: Icons.schedule),
      OnboardingOption(label: 'Selten', icon: Icons.timer_off),
    ],
  ),
  OnboardingQuestion(
    title: 'Welche Geräte nutzt du?',
    questionIcon: Icons.kitchen,
    options: [
      OnboardingOption(label: 'Ofen', icon: Icons.local_pizza),
      OnboardingOption(label: 'Mikrowelle', icon: Icons.microwave),
      OnboardingOption(label: 'Heißluftfritteuse', icon: Icons.kitchen),
      OnboardingOption(label: 'Mixer', icon: Icons.blender),
      OnboardingOption(label: 'Thermomix', icon: Icons.soup_kitchen),
    ],
  ),
];
