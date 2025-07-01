import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipe/recipe_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/mealplan/presentation/widgets/mealplan_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final String? userName = profileVM.profile?.name;
    final bool isProfileLoading = profileVM.isLoading || profileVM.profile == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: isProfileLoading
                ? Container(
                    width: 220,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName ?? 'User',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
          MealPlanSection(),
        ],
      ),
    );
  }
}
