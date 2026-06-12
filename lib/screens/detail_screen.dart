import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../main.dart';
import '../models/game_session.dart';

class DetailScreen extends StatefulWidget {
  final GameSession session;

  const DetailScreen({super.key, required this.session});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _monthController;
  late TextEditingController _totalController;
  late TextEditingController _correctController;
  late String _difficulty;
  bool _editing = false;

  final Map<String, double> _rates = {
    'Easy': 1.0,
    'Medium': 2.0,
    'Hard': 3.0,
  };

  @override
  void initState() {
    super.initState();
    _monthController = TextEditingController(text: widget.session.month);
    _totalController =
        TextEditingController(text: widget.session.totalQuestions.toString());
    _correctController =
        TextEditingController(text: widget.session.correctAnswers.toString());
    _difficulty = widget.session.difficulty;
  }

  @override
  void dispose() {
    _monthController.dispose();
    _totalController.dispose();
    _correctController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final total = int.parse(_totalController.text);
    final correct = int.parse(_correctController.text);
    if (correct > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correct answers cannot be more than total questions.',
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

    final updated = widget.session.copyWith(
      month: _monthController.text.trim(),
      totalQuestions: total,
      correctAnswers: correct,
      difficulty: _difficulty,
      rate: rate,
      basePoints: basePoints,
      bonus: bonus,
      finalScore: finalScore,
    );

    await DBHelper.instance.updateSession(updated);
    if (!mounted) return;
    setState(() {
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Updated successfully!'),
        backgroundColor: AppColors.accent,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Are you sure you want to delete this score record? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.session.id != null) {
      await DBHelper.instance.deleteSession(widget.session.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Record' : 'Score Detail'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
            tooltip: _editing ? 'Cancel' : 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_editing) ...[
                    TextFormField(
                      controller: _monthController,
                      decoration: const InputDecoration(labelText: 'Month'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Month cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration:
                          const InputDecoration(labelText: 'Difficulty'),
                      items: _rates.keys
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _difficulty = v ?? _difficulty),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Total Questions'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
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
                          labelText: 'Correct Answers'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 0) {
                          return 'Enter a whole number (0 or more)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
                  ] else ...[
                    _row('Month', s.month),
                    _row('Difficulty', s.difficulty),
                    _row('Unit (Correct Answers)',
                        '${s.correctAnswers} / ${s.totalQuestions}'),
                    _row('Points per Question', s.rate.toStringAsFixed(0)),
                    _row('Total Charges (Base Points)',
                        s.basePoints.toStringAsFixed(1)),
                    _row('Rebate (Bonus)', s.bonus.toStringAsFixed(1)),
                    const Divider(),
                    _row('Final Cost (Final Score)',
                        s.finalScore.toStringAsFixed(1),
                        highlight: true),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
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
