import 'package:flutter/material.dart';

class AboutMealoScreen extends StatelessWidget {
  const AboutMealoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('About Mealo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mealo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Mealo is a smart and intuitive meal planning app designed to help users eat better, healthier, and more sustainably.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Our Vision',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'To empower individuals to make informed and conscious food choices – tailored to their preferences, dietary needs, and lifestyle.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '• Personalized Onboarding\n• Smart Suggestions\n• Cooking Assistant\n• Device-Aware Planning\n• Cloud Sync',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Our Values',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '• Health First\n• Sustainability\n• Simplicity',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Contact & Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'We love hearing from you! Please reach out via the app store or contact us on our email: mealo@gmail.com.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Mealo – Eat better. Live smarter.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
