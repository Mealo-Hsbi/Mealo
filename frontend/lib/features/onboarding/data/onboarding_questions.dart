import 'package:flutter/material.dart';

class OnboardingQuestion {
  final String title;
  final String questionKey; // z. B. 'diet'
  final List<OnboardingOption> options;
  final IconData? questionIcon;

  OnboardingQuestion({
    required this.title,
    required this.questionKey,
    required this.options,
    this.questionIcon,
  });
}

class OnboardingOption {
  final String key; // z. B. 'vegan'
  final String label;
  final IconData? icon;

  OnboardingOption({
    required this.key,
    required this.label,
    this.icon,
  });
}

final List<OnboardingQuestion> onboardingQuestions = [
  OnboardingQuestion(
    title: 'Was isst du gerne?',
    questionKey: 'diet',
    questionIcon: Icons.restaurant_menu,
    options: [
      OnboardingOption(key: 'vegan', label: 'Vegan', icon: Icons.eco),
      OnboardingOption(key: 'vegetarian', label: 'Vegetarisch', icon: Icons.spa),
      OnboardingOption(key: 'low_carb', label: 'Low Carb', icon: Icons.fitness_center),
      OnboardingOption(key: 'keto', label: 'Keto', icon: Icons.local_fire_department),
      OnboardingOption(key: 'flexitarian', label: 'Flexitarisch', icon: Icons.restaurant),
      OnboardingOption(key: 'pescetarian', label: 'Pescetarisch', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'Hast du Allergien?',
    questionKey: 'allergy',
    questionIcon: Icons.warning_amber,
    options: [
      OnboardingOption(key: 'gluten', label: 'Gluten', icon: Icons.no_food),
      OnboardingOption(key: 'lactose', label: 'Laktose', icon: Icons.icecream),
      OnboardingOption(key: 'nuts', label: 'Nüsse', icon: Icons.energy_savings_leaf),
      OnboardingOption(key: 'soy', label: 'Soja', icon: Icons.local_dining),
      OnboardingOption(key: 'egg', label: 'Ei', icon: Icons.egg_alt),
      OnboardingOption(key: 'fish', label: 'Fisch', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'Was ist dein Ziel?',
    questionKey: 'goal',
    questionIcon: Icons.flag,
    options: [
      OnboardingOption(key: 'lose_weight', label: 'Abnehmen', icon: Icons.trending_down),
      OnboardingOption(key: 'build_muscle', label: 'Muskelaufbau', icon: Icons.fitness_center),
      OnboardingOption(key: 'stay_healthy', label: 'Gesund bleiben', icon: Icons.favorite),
      OnboardingOption(key: 'more_energy', label: 'Mehr Energie', icon: Icons.bolt),
      OnboardingOption(key: 'less_sugar', label: 'Weniger Zucker', icon: Icons.no_food),
    ],
  ),
  OnboardingQuestion(
    title: 'Wie oft kochst du pro Woche?',
    questionKey: 'cooking_frequency',
    questionIcon: Icons.schedule,
    options: [
      OnboardingOption(key: 'daily', label: 'Täglich', icon: Icons.restaurant),
      OnboardingOption(key: '2_3_times', label: '2–3x', icon: Icons.schedule),
      OnboardingOption(key: 'rarely', label: 'Selten', icon: Icons.timer_off),
    ],
  ),
  OnboardingQuestion(
    title: 'Welche Geräte nutzt du?',
    questionKey: 'devices',
    questionIcon: Icons.kitchen,
    options: [
      OnboardingOption(key: 'oven', label: 'Ofen', icon: Icons.local_pizza),
      OnboardingOption(key: 'microwave', label: 'Mikrowelle', icon: Icons.microwave),
      OnboardingOption(key: 'air_fryer', label: 'Heißluftfritteuse', icon: Icons.kitchen),
      OnboardingOption(key: 'blender', label: 'Mixer', icon: Icons.blender),
      OnboardingOption(key: 'thermomix', label: 'Thermomix', icon: Icons.soup_kitchen),
    ],
  ),
];
