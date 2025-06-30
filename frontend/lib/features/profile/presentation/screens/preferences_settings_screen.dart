import 'package:flutter/material.dart';
import '../../../onboarding/data/onboarding_questions.dart';
import '../../../onboarding/data/onboarding_api.dart';
import '../../../onboarding/presentation/widget/preference_chips.dart';

class PreferencesSettingsScreen extends StatefulWidget {
  final OnboardingApi? api;
  const PreferencesSettingsScreen({super.key, this.api});

  @override
  State<PreferencesSettingsScreen> createState() => PreferencesSettingsScreenState();
}

class PreferencesSettingsScreenState extends State<PreferencesSettingsScreen> {
  late final OnboardingApi _api;
  List<Map<String, Object>> userPreferences = [];
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? OnboardingApi();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    print('DEBUG: Lade User Preferences...');
    try {
      final preferences = await _api.getUserPreferences();
      print('DEBUG: Preferences geladen: ' + preferences.toString());
      // Mappe die geladenen Präferenzen auf alle Onboarding-Fragen
      final List<Map<String, Object>> merged = onboardingQuestions.map((q) {
        final pref = preferences.firstWhere(
          (p) => p['questionKey'] == q.questionKey,
          orElse: () => {
            'questionKey': q.questionKey,
            'questionLabel': q.title,
            'selectedOptions': <Map<String, Object>>[],
          },
        );
        return {
          'questionKey': q.questionKey,
          'questionLabel': q.title,
          'selectedOptions': (pref['selectedOptions'] as List?)?.map((e) {
            if (e is Map<String, Object>) return e;
            if (e is Map) return Map<String, Object>.from(e);
            throw Exception('selectedOptions contains non-Map element');
          }).toList() ?? [],
        };
      }).toList();
      setState(() {
        userPreferences = merged;
        isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Fehler beim Laden der Preferences: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading preferences')),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    print('DEBUG: Speichere Preferences...');
    setState(() {
      _isSaving = true;
    });

    try {
      // Sammle alle ausgewählten Optionen
      final allSelectedOptions = <String>[];
      for (final preference in userPreferences) {
        final selectedOptions = preference['selectedOptions'] as List;
        for (final option in selectedOptions) {
          allSelectedOptions.add(option['key'] as String);
        }
      }
      print('DEBUG: Zu speichernde Keys: $allSelectedOptions');
      await _api.submitPreferences(allSelectedOptions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
      }
    } catch (e) {
      print('DEBUG: Fehler beim Speichern: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving preferences')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _updatePreference(String questionKey, String optionKey, String optionLabel, bool isSelected) {
    print('DEBUG: updatePreference: questionKey=$questionKey, optionKey=$optionKey, isSelected=$isSelected');
    setState(() {
      final preferenceIndex = userPreferences.indexWhere((p) => p['questionKey'] == questionKey);
      if (preferenceIndex != -1) {
        final preference = userPreferences[preferenceIndex];
        List<Map<String, Object>> selectedOptions = (preference['selectedOptions'] as List).cast<Map<String, Object>>().toList();

        if (questionKey == 'cooking_frequency') {
          // Nur eine Auswahl zulassen
          if (isSelected) {
            selectedOptions = [
              {'key': optionKey, 'label': optionLabel}
            ];
          } else {
            selectedOptions = [];
          }
        } else {
          if (isSelected) {
            if (!selectedOptions.any((opt) => opt['key'] == optionKey)) {
              selectedOptions.add({
                'key': optionKey,
                'label': optionLabel,
              });
            }
          } else {
            selectedOptions.removeWhere((opt) => opt['key'] == optionKey);
          }
        }

        userPreferences[preferenceIndex] = {
          ...preference,
          'selectedOptions': selectedOptions,
        };
      }
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          // Ladeicon entfernt
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Preferences',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Customize your food preferences and dietary requirements.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...onboardingQuestions.map((question) {
                    final preferenceIndex = userPreferences.indexWhere((p) => p['questionKey'] == question.questionKey);
                    final userPreference = preferenceIndex != -1
                        ? userPreferences[preferenceIndex]
                        : {
                            'questionKey': question.questionKey,
                            'questionLabel': question.title,
                            'selectedOptions': <Map<String, Object>>[],
                          };
                    final selectedOptions = (userPreference['selectedOptions'] as List?)?.map((e) {
                      if (e is Map<String, Object>) return e;
                      if (e is Map) return Map<String, Object>.from(e);
                      throw Exception('selectedOptions contains non-Map element');
                    }).toList() ?? [];
                    final selectedKeys = selectedOptions.map((opt) => opt['key'] as String).toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (question.questionIcon != null) ...[
                                Icon(
                                  question.questionIcon,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  question.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PreferenceChips(
                            title: '',
                            options: question.options.map((e) => e.label).toList(),
                            icons: question.options.map((e) => e.icon).toList(),
                            selection: question.options
                                .where((o) => selectedKeys.contains(o.key))
                                .map((o) => o.label)
                                .toList(),
                            onChanged: (selectedLabel) {
                              final option = question.options.firstWhere(
                                (e) => e.label == selectedLabel,
                              );
                              final isCurrentlySelected = selectedKeys.contains(option.key);
                              print('DEBUG: Chip tapped: questionKey=${question.questionKey}, optionKey=${option.key}, isSelected=${!isCurrentlySelected}');
                              _updatePreference(
                                question.questionKey,
                                option.key,
                                option.label,
                                !isCurrentlySelected,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
} 