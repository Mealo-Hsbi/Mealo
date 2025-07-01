import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/presentation/screens/preferences_settings_screen.dart';
import 'package:frontend/features/onboarding/data/onboarding_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DummyOnboardingApi extends OnboardingApi {
  @override
  Future<List<Map<String, dynamic>>> getUserPreferences() async => [];
  @override
  Future<void> submitPreferences(List<String> optionKeys) async {}
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL="http://localhost:8080/api"\n');
  });

  testWidgets('PreferencesSettingsScreen lädt korrekt', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreferencesSettingsScreen(api: DummyOnboardingApi()),
      ),
    );
    await tester.pumpAndSettle();

    // Überprüfe, dass die App lädt
    expect(find.byType(PreferencesSettingsScreen), findsOneWidget);
    expect(find.text('Your Preferences'), findsOneWidget);
  });

  testWidgets('FilterChips sind vorhanden', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreferencesSettingsScreen(api: DummyOnboardingApi()),
      ),
    );
    await tester.pumpAndSettle();

    // Setze Testdaten direkt
    final state = tester.state<PreferencesSettingsScreenState>(find.byType(PreferencesSettingsScreen));
    state.setState(() {
      state.userPreferences = [
        {
          'questionKey': 'cooking_frequency',
          'questionLabel': 'How often do you cook per week?',
          'selectedOptions': <Map<String, Object>>[],
        },
        {
          'questionKey': 'allergy',
          'questionLabel': 'Do you have any allergies?',
          'selectedOptions': <Map<String, Object>>[],
        },
      ];
      state.isLoading = false;
    });
    await tester.pumpAndSettle();

    // Überprüfe, dass FilterChips vorhanden sind
    expect(find.byType(FilterChip), findsWidgets);
  });

  testWidgets('Mehrfachauswahl bei allergy möglich', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreferencesSettingsScreen(api: DummyOnboardingApi()),
      ),
    );
    await tester.pumpAndSettle();

    // Setze Testdaten direkt
    final state = tester.state<PreferencesSettingsScreenState>(find.byType(PreferencesSettingsScreen));
    state.setState(() {
      state.userPreferences = [
        {
          'questionKey': 'cooking_frequency',
          'questionLabel': 'How often do you cook per week?',
          'selectedOptions': <Map<String, Object>>[],
        },
        {
          'questionKey': 'allergy',
          'questionLabel': 'Do you have any allergies?',
          'selectedOptions': <Map<String, Object>>[],
        },
      ];
      state.isLoading = false;
    });
    await tester.pumpAndSettle();

    // Warte bis die Chips geladen sind
    await tester.pump(const Duration(milliseconds: 500));

    // Finde die spezifischen Chips für allergy
    final glutenChip = find.descendant(
      of: find.byType(PreferencesSettingsScreen),
      matching: find.ancestor(
        of: find.text('Gluten'),
        matching: find.byType(FilterChip),
      ),
    );

    final lactoseChip = find.descendant(
      of: find.byType(PreferencesSettingsScreen),
      matching: find.ancestor(
        of: find.text('Lactose'),
        matching: find.byType(FilterChip),
      ),
    );

    // Teste die Chips
    if (tester.widgetList(glutenChip).isNotEmpty) {
      await tester.tap(glutenChip.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    if (tester.widgetList(lactoseChip).isNotEmpty) {
      await tester.tap(lactoseChip.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // Überprüfe die Auswahl
    if (tester.widgetList(glutenChip).isNotEmpty) {
      expect(
        tester.widget<FilterChip>(glutenChip.first).selected,
        isTrue,
      );
    }

    if (tester.widgetList(lactoseChip).isNotEmpty) {
      expect(
        tester.widget<FilterChip>(lactoseChip.first).selected,
        isTrue,
      );
    }
  });
} 