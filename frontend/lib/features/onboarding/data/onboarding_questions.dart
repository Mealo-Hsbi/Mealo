import 'package:flutter/material.dart';

class OnboardingQuestion {
  final String title;
  final String questionKey;
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
  final String key;
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
    title: 'What do you like to eat?',
    questionKey: 'diet',
    questionIcon: Icons.restaurant_menu,
    options: [
      OnboardingOption(key: 'vegan', label: 'Vegan', icon: Icons.eco),
      OnboardingOption(key: 'vegetarian', label: 'Vegetarian', icon: Icons.spa),
      OnboardingOption(key: 'low_carb', label: 'Low Carb', icon: Icons.fitness_center),
      OnboardingOption(key: 'keto', label: 'Keto', icon: Icons.local_fire_department),
      OnboardingOption(key: 'flexitarian', label: 'Flexitarian', icon: Icons.restaurant),
      OnboardingOption(key: 'pescetarian', label: 'Pescetarian', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'Do you have any allergies?',
    questionKey: 'allergy',
    questionIcon: Icons.warning_amber,
    options: [
      OnboardingOption(key: 'gluten', label: 'Gluten', icon: Icons.no_food),
      OnboardingOption(key: 'lactose', label: 'Lactose', icon: Icons.icecream),
      OnboardingOption(key: 'nuts', label: 'Nuts', icon: Icons.energy_savings_leaf),
      OnboardingOption(key: 'soy', label: 'Soy', icon: Icons.local_dining),
      OnboardingOption(key: 'egg', label: 'Egg', icon: Icons.egg_alt),
      OnboardingOption(key: 'fish', label: 'Fish', icon: Icons.set_meal),
    ],
  ),
  OnboardingQuestion(
    title: 'What is your goal?',
    questionKey: 'goal',
    questionIcon: Icons.flag,
    options: [
      OnboardingOption(key: 'lose_weight', label: 'Lose Weight', icon: Icons.trending_down),
      OnboardingOption(key: 'build_muscle', label: 'Build Muscle', icon: Icons.fitness_center),
      OnboardingOption(key: 'stay_healthy', label: 'Stay Healthy', icon: Icons.favorite),
      OnboardingOption(key: 'more_energy', label: 'More Energy', icon: Icons.bolt),
      OnboardingOption(key: 'less_sugar', label: 'Less Sugar', icon: Icons.no_food),
    ],
  ),
  OnboardingQuestion(
    title: 'How often do you cook per week?',
    questionKey: 'cooking_frequency',
    questionIcon: Icons.schedule,
    options: [
      OnboardingOption(key: 'daily', label: 'Daily', icon: Icons.restaurant),
      OnboardingOption(key: '2_3_times', label: '2–3x', icon: Icons.schedule),
      OnboardingOption(key: 'rarely', label: 'Rarely', icon: Icons.timer_off),
    ],
  ),
  OnboardingQuestion(
    title: 'Which devices do you use?',
    questionKey: 'devices',
    questionIcon: Icons.kitchen,
    options: [
      OnboardingOption(key: 'oven', label: 'Oven', icon: Icons.local_pizza),
      OnboardingOption(key: 'microwave', label: 'Microwave', icon: Icons.microwave),
      OnboardingOption(key: 'air_fryer', label: 'Air Fryer', icon: Icons.kitchen),
      OnboardingOption(key: 'blender', label: 'Blender', icon: Icons.blender),
      OnboardingOption(key: 'thermomix', label: 'Thermomix', icon: Icons.soup_kitchen),
    ],
  ),
];
