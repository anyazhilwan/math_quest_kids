import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // TODO: Replace with your own photo.
  // Add your photo file to assets/images/student_photo.png and
  // register it in pubspec.yaml under flutter > assets, then set
  // _hasPhoto to true.
  static const bool _hasPhoto = false;
  static const String _studentName = 'Anya Zhilwan';
  static const String _studentId = 'QIU23-0148';
  static const String _courseCode = 'MTD';
  static const String _courseName = 'Mobile Technology and Development';
  static const String _githubUrl =
      'https://github.com/anyazhilwan/math_quest_kids';

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(_githubUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info),
            SizedBox(width: 8),
            Text('About'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  _hasPhoto ? const AssetImage('assets/images/student_photo.png') : null,
              child: _hasPhoto
                  ? null
                  : const Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.badge, 'Name', _studentName),
                  _infoRow(Icons.numbers, 'Student ID', _studentId),
                  _infoRow(Icons.school, 'Course Code', _courseCode),
                  _infoRow(Icons.menu_book, 'Course Name', _courseName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How to Use Math Quest Kids',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  _instructionStep(
                      '1', 'Go to the "Play" tab on the bottom navigation.'),
                  _instructionStep('2',
                      'Choose a difficulty level: Easy, Medium, or Hard.'),
                  _instructionStep('3',
                      'Enter the total number of questions you attempted.'),
                  _instructionStep(
                      '4', 'Enter how many questions you answered correctly.'),
                  _instructionStep('5',
                      'Tap "Calculate" to instantly see your score, bonus, and final result on the same page.'),
                  _instructionStep('6',
                      'Tap "Save Result" to store your score in the app\'s offline database.'),
                  _instructionStep('7',
                      'Go to the "History" tab to see all your saved scores listed by month.'),
                  _instructionStep('8',
                      'Tap any record in History to view full details, edit it, or delete it.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Website',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _openUrl(context),
                    child: Text(
                      _githubUrl,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '© 2026 Math Quest Kids. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.accent,
            child: Text(number,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
