import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../main.dart';
import '../models/game_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _correctController = TextEditingController();

  String _difficulty = 'Easy';
  final Map<String, double> _rates = {
    'Easy': 1.0,
    'Medium': 2.0,
    'Hard': 3.0,
  };

  GameSession? _result;
  bool _saved = false;

  @override
  void dispose() {
    _totalController.dispose();
    _correctController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _saved = false);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final total = int.parse(_totalController.text);
    final correct = int.parse(_correctController.text);

    if (correct > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Oops! Correct answers cannot be more than total questions.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final rate = _rates[_difficulty]!;
    final basePoints = correct * rate;
    final bonus = (correct >= (total * 0.8)) ? basePoints * 0.2 : 0.0;
    final finalScore = basePoints + bonus;

    final now = DateTime.now();
    final month = DateFormat('MMMM yyyy').format(now);

    setState(() {
      _result = GameSession(
        month: month,
        correctAnswers: correct,
        totalQuestions: total,
        difficulty: _difficulty,
        rate: rate,
        basePoints: basePoints,
        bonus: bonus,
        finalScore: finalScore,
        dateCreated: now.toIso8601String(),
      );
    });
  }

  Future<void> _save() async {
    if (_result == null) return;
    await DBHelper.instance.insertSession(_result!);
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Score saved! Check History tab to view it.'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded),
            SizedBox(width: 8),
            Text('Math Quest Kids'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Score Calculator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your quiz results below. Pick a difficulty, '
                        'type how many questions you attempted, and how many '
                        'you got correct. Tap "Calculate" to see your score!',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty Level',
                          prefixIcon: Icon(Icons.bolt),
                        ),
                        items: _rates.keys
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                      '$d (${_rates[d]!.toStringAsFixed(0)} pts/question)'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _difficulty = v ?? 'Easy'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Questions',
                          hintText: 'e.g. 10',
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter total questions';
                          }
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Enter a whole number greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _correctController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Correct Answers',
                          hintText: 'e.g. 8',
                          prefixIcon: Icon(Icons.check_circle_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter correct answers';
                          }
                          final n = int.tryParse(value);
                          if (n == null || n < 0) {
                            return 'Enter a whole number (0 or more)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🏆 Your Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _resultRow('Month', _result!.month),
                        _resultRow('Difficulty', _result!.difficulty),
                        _resultRow('Correct Answers',
                            '${_result!.correctAnswers} / ${_result!.totalQuestions}'),
                        _resultRow('Points per Question',
                            _result!.rate.toStringAsFixed(0)),
                        _resultRow('Total Points',
                            _result!.basePoints.toStringAsFixed(1)),
                        _resultRow('Bonus (Rebate)',
                            '+${_result!.bonus.toStringAsFixed(1)}'),
                        const Divider(),
                        _resultRow(
                          'Final Score',
                          _result!.finalScore.toStringAsFixed(1),
                          highlight: true,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _saved ? null : _save,
                          icon: Icon(_saved ? Icons.check : Icons.save),
                          label: Text(_saved ? 'Saved' : 'Save Result'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Card(
                color: Color(0xFFFFF3D6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Get 80% or more correct to earn a 20% bonus '
                          'on your score!',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              fontSize: highlight ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 18 : 14,
              color: highlight ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
