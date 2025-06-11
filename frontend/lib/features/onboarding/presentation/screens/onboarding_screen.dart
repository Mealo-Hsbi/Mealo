import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/onboarding_questions.dart';
import '../widget/preference_chips.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final Map<String, List<String>> _responses = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Systemleisten zurücksetzen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    // TODO: Save preferences / call viewmodel
    Navigator.of(context, rootNavigator: true).pop(); // direkt raus
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = onboardingQuestions.length + 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: totalPages,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              if (index == 0) return _buildIntro();
              if (index == totalPages - 1) return _buildSummary();

              final question = onboardingQuestions[index - 1];
              final answers = _responses.putIfAbsent(question.title, () => []);
              return PreferenceChips(
                title: question.title,
                options: question.options.map((e) => e.label).toList(),
                icons: question.options.map((e) => e.icon).toList(),
                selection: answers,
              );
            },
          ),
          _buildBottomControls(totalPages),
        ],
      ),
    );
  }

  Widget _buildIntro() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/app_icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'Willkommen bei Mealo!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Lass uns deine Vorlieben kennenlernen.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildSummary() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              SizedBox(height: 24),
              Text('Du bist bereit!', style: TextStyle(fontSize: 24)),
              SizedBox(height: 12),
              Text('Du kannst deine Angaben später jederzeit anpassen.'),
            ],
          ),
        ),
      );

  Widget _buildBottomControls(int totalPages) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: const Text('Zurück'),
            onPressed: _currentPage > 0
                ? () => _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    )
                : null,
          ),
          Row(
            children: List.generate(
              totalPages,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          TextButton(
            child: Text(_currentPage == totalPages - 1 ? 'Fertig' : 'Weiter'),
            onPressed: () {
              if (_currentPage == totalPages - 1) {
                _completeOnboarding();
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
