import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../main.dart';
import '../models/game_session.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<GameSession>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = DBHelper.instance.getAllSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart),
            SizedBox(width: 8),
            Text('Score History'),
          ],
        ),
      ),
      body: FutureBuilder<List<GameSession>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No saved scores yet!',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Go to the Play tab, calculate your score, and tap '
                      '"Save Result" to see it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = sessions[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.emoji_events,
                          color: Colors.white),
                    ),
                    title: Text(
                      s.month,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Final Score: ${s.finalScore.toStringAsFixed(1)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(session: s),
                        ),
                      );
                      _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
