import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myth_fact_provider.dart';
import '../widgets/swipeable_card.dart';

class MythFactScreen extends StatefulWidget {
  const MythFactScreen({Key? key}) : super(key: key);

  @override
  State<MythFactScreen> createState() => _MythFactScreenState();
}

class _MythFactScreenState extends State<MythFactScreen> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎲 Myth vs Fact'),
        elevation: 0,
      ),
      body: Consumer<MythFactProvider>(
        builder: (context, mythFactProvider, child) {
          if (mythFactProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (!mythFactProvider.isGameActive) {
            return _buildStartScreen(mythFactProvider);
          } else {
            return _buildGameScreen(mythFactProvider);
          }
        },
      ),
    );
  }

  Widget _buildStartScreen(MythFactProvider mythFactProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text('🎲', style: TextStyle(fontSize: 64)),
                SizedBox(height: 16),
                Text(
                  'Myth vs Fact',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  'Swipe right for FACT, left for MYTH',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('🔥 Max Streak', '${mythFactProvider.maxStreak}',
                          'correct'),
                      _statItem('🎮 Games',
                          '${mythFactProvider.gameResults.length}', 'played'),
                      _statItem(
                        '🎯 Best',
                        mythFactProvider.gameResults.isNotEmpty
                            ? '${mythFactProvider.gameResults.reduce((a, b) => a.percentage > b.percentage ? a : b).percentage}%'
                            : '0%',
                        'score',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '📖 How to Play',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(height: 12),
                Text('• Swipe RIGHT if you think it\'s a FACT',
                    style: TextStyle(fontSize: 12)),
                Text('• Swipe LEFT if you think it\'s a MYTH',
                    style: TextStyle(fontSize: 12)),
                Text('• Learn the explanation after each card',
                    style: TextStyle(fontSize: 12)),
                Text('• Build your streak with correct answers',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: mythFactProvider.isLoading
                  ? null
                  : () {
                mythFactProvider.startGame();
                setState(() {
                  _showExplanation = false;
                });
              },
              icon: mythFactProvider.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.play_arrow),
              label: Text(
                mythFactProvider.isLoading
                    ? 'Generating Statements...'
                    : 'Start Game',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(MythFactProvider mythFactProvider) {
    final currentStatement = mythFactProvider.currentStatement;
    if (currentStatement == null) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${mythFactProvider.totalAnswered}/${mythFactProvider.currentStatements.length}',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    'Streak: ${mythFactProvider.streak} 🔥',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (mythFactProvider.totalAnswered + 1) /
                    mythFactProvider.currentStatements.length,
                color: Colors.green,
                backgroundColor: Colors.grey,
                minHeight: 8,
              ),
            ],
          ),
        ),
        Expanded(
          // FIX #7: Add unique key to force widget rebuild
          child: SwipeableCard(
            key: ValueKey(currentStatement.id), // CRITICAL: Unique key
            statement: currentStatement,
            onSwipe: (swipedRight) {
              final isCorrect =
              mythFactProvider.isAnswerCorrect(currentStatement, swipedRight);
              mythFactProvider.processAnswer(isCorrect);
              if (mythFactProvider.currentStatement != null) {
                setState(() {
                  _showExplanation = false;
                });
              }
            },
            onCardEnd: () {},
          ),
        ),
        if (_showExplanation)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is a ${currentStatement.isFact ? 'FACT ✓' : 'MYTH ✗'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: currentStatement.isFact
                          ? Colors.green
                          : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStatement.explanation,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showExplanation = true;
                  });
                },
                child: const Text('Show Explanation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
