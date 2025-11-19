import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_card.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _selectedDifficulty = 'Beginner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Daily Financial Quiz'),
        elevation: 0,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (!quizProvider.isQuizStarted) {
            return _buildStartScreen(quizProvider);
          } else {
            return _buildQuizScreen(quizProvider);
          }
        },
      ),
    );
  }

  Widget _buildStartScreen(QuizProvider quizProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Card
          Card(
            elevation: 4,
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
                      _statItem('🔥 Streak', '${quizProvider.streakDays}', 'days'),
                      _statItem('🎓 Quizzes', '${quizProvider.quizResults.length}', 'completed'),
                      _statItem('🏆 Badges', '${quizProvider.badges.length}', 'earned'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Badges
          if (quizProvider.badges.isNotEmpty) ...[
            const Text(
              'Badges Earned',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quizProvider.badges.map((badge) {
                return Tooltip(
                  message: '${badge.name}\n${badge.description}',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow!),
                    ),
                    child: Text(
                      badge.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Difficulty Selection - FIXED VISIBILITY
          Text(
            'Select Difficulty',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).textTheme.titleMedium?.color
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryPurple : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryPurple : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: quizProvider.isLoading
                  ? null
                  : () async {
                await quizProvider.startQuiz(_selectedDifficulty);
              },
              icon: quizProvider.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.play_arrow),
              label: Text(
                quizProvider.isLoading ? 'Generating Questions...' : 'Start Quiz',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuizScreen(QuizProvider quizProvider) {
    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) return const SizedBox();

    final isAnswered = quizProvider.userAnswers.length > quizProvider.currentQuestionIndex;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (quizProvider.currentQuestionIndex + 1) /
              quizProvider.currentQuiz.length,
          minHeight: 8,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: QuizCard(
              question: currentQuestion,
              questionNumber: quizProvider.currentQuestionIndex + 1,
              totalQuestions: quizProvider.currentQuiz.length,
              selectedAnswer: isAnswered
                  ? quizProvider.userAnswers[quizProvider.currentQuestionIndex]
                  : null,
              onAnswerSelected: (index) {
                quizProvider.selectAnswer(index);
              },
              isAnswered: isAnswered,
            ),
          ),
        ),
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (quizProvider.currentQuestionIndex > 0)
                ElevatedButton.icon(
                  onPressed: () {
                    quizProvider.previousQuestion();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              if (quizProvider.currentQuestionIndex <
                  quizProvider.currentQuiz.length - 1)
                ElevatedButton.icon(
                  onPressed: () {
                    quizProvider.nextQuestion();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              if (quizProvider.currentQuestionIndex ==
                  quizProvider.currentQuiz.length - 1)
                ElevatedButton.icon(
                  onPressed: () {
                    quizProvider.submitQuiz();
                    _showResultsDialog(quizProvider);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResultsDialog(QuizProvider quizProvider) {
    final lastResult = quizProvider.quizResults.last;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${lastResult.score}/${lastResult.totalQuestions}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              '${lastResult.percentage}%',
              style: TextStyle(
                fontSize: 24,
                color: lastResult.percentage >= 80 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current Streak: ${lastResult.streakDays} days 🔥',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
