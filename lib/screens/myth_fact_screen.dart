import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myth_fact_provider.dart';
import '../widgets/swipeable_card.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

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
          }

          // FIX #7: Show results screen when game ends
          if (!mythFactProvider.isGameActive && mythFactProvider.lastGameResult != null) {
            return _buildResultsScreen(mythFactProvider);
          }

          if (!mythFactProvider.isGameActive) {
            return _buildStartScreen(mythFactProvider);
          } else {
            return _buildGameScreen(mythFactProvider);
          }
        },
      ),
    );
  }

  // FIX #7: Results screen similar to quiz
  Widget _buildResultsScreen(MythFactProvider mythFactProvider) {
    final result = mythFactProvider.lastGameResult!;
    final score = result.correctAnswers;
    final total = result.totalQuestions;
    final percentage = result.percentage;

    // Determine performance level
    String performanceEmoji;
    String performanceText;
    Color performanceColor;
    
    if (percentage >= 80) {
      performanceEmoji = '🏆';
      performanceText = 'Excellent!';
      performanceColor = AppColors.successGreen;
    } else if (percentage >= 60) {
      performanceEmoji = '🎯';
      performanceText = 'Good Job!';
      performanceColor = AppColors.primaryPurple;
    } else if (percentage >= 40) {
      performanceEmoji = '💪';
      performanceText = 'Keep Trying!';
      performanceColor = AppColors.warningOrange;
    } else {
      performanceEmoji = '📚';
      performanceText = 'Keep Learning!';
      performanceColor = AppColors.errorRed;
    }

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final emojiSize = ResponsiveHelper.getFontSize(context, mobile: 80, desktop: 56);
    final titleSize = ResponsiveHelper.getFontSize(context, mobile: 32, desktop: 24);
    final subtitleSize = ResponsiveHelper.getFontSize(context, mobile: 16, desktop: 13);
    final circleSize = ResponsiveHelper.getIconSize(context, mobile: 220, desktop: 160);
    final percentageSize = ResponsiveHelper.getFontSize(context, mobile: 56, desktop: 40);
    final spacing = ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 20);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 24, desktop: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 20, desktop: 12)),

              // Score Card with circular progress indicator and left side content
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Emoji, Title, Subtitle
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          performanceEmoji,
                          style: TextStyle(fontSize: emojiSize),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
                        Text(
                          performanceText,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: performanceColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6)),
                        Text(
                          'You got $score out of\n$total correct',
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 24, desktop: 20)),
                  // Right side: Circular progress indicator
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          performanceColor.withOpacity(0.1),
                          performanceColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: performanceColor.withOpacity(0.3),
                        width: isDesktop ? 2 : 3,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular progress indicator
                        SizedBox(
                          width: circleSize - 20,
                          height: circleSize - 20,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: isDesktop ? 8 : 12,
                            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(performanceColor),
                          ),
                        ),
                        // Score text in center
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: percentageSize,
                                fontWeight: FontWeight.bold,
                                color: performanceColor,
                              ),
                            ),
                            SizedBox(height: isDesktop ? 2 : 4),
                            Text(
                              'Score',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // Stats Cards in Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      label: 'Correct',
                      value: '$score',
                      color: AppColors.successGreen,
                      context: context,
                      isDesktop: isDesktop,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cancel,
                      label: 'Wrong',
                      value: '${total - score}',
                      color: AppColors.errorRed,
                      context: context,
                      isDesktop: isDesktop,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      label: 'Max Streak',
                      value: '${result.currentStreak}',
                      color: AppColors.warningOrange,
                      context: context,
                      isDesktop: isDesktop,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.emoji_events,
                      label: 'Accuracy',
                      value: '$percentage%',
                      color: AppColors.primaryPurple,
                      context: context,
                      isDesktop: isDesktop,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    mythFactProvider.startGame();
                    setState(() {
                      _showExplanation = false;
                    });
                  },
                  icon: Icon(Icons.refresh, size: isDesktop ? 18 : 24),
                  label: Text('Play Again', style: TextStyle(fontSize: isDesktop ? 14 : 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? 12 : 16,
                    ),
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    mythFactProvider.resetGame();
                  },
                  icon: Icon(Icons.home, size: isDesktop ? 18 : 24),
                  label: Text('Back to Home', style: TextStyle(fontSize: isDesktop ? 14 : 16)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? color.withOpacity(0.15)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isDesktop ? 24 : 32,
          ),
          SizedBox(height: isDesktop ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isDesktop ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 10 : 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen(MythFactProvider mythFactProvider) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final padding = ResponsiveHelper.getPadding(context, mobile: 20, desktop: 16);
    final titleSize = ResponsiveHelper.getFontSize(context, mobile: 28, desktop: 24);
    final subtitleSize = ResponsiveHelper.getFontSize(context, mobile: 14, desktop: 13);
    final headerSize = ResponsiveHelper.getFontSize(context, mobile: 18, desktop: 16);
    final spacing = ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 24);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('🎲', style: TextStyle(fontSize: isDesktop ? 56 : 64)),
                    SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12)),
                    Text(
                      'Myth vs Fact',
                      style: TextStyle(
                        fontSize: titleSize, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).textTheme.headlineMedium?.color
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6)),
                    Text(
                      'Swipe right for FACT, left for MYTH',
                      style: TextStyle(
                        fontSize: subtitleSize, 
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Stats',
                        style: TextStyle(fontSize: headerSize, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('🔥 Max Streak', '${mythFactProvider.maxStreak}', 'correct'),
                          _statItem('🎮 Games', '${mythFactProvider.gameResults.length}', 'played'),
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
              SizedBox(height: spacing),

              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14)),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.primaryPurple.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.primaryPurple.withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '📖 How to Play',
                      style: TextStyle(
                        fontSize: subtitleSize, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.primaryPurple
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 12, desktop: 8)),
                    Text(
                      '• Swipe RIGHT if you think it\'s a FACT', 
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      '• Swipe LEFT if you think it\'s a MYTH', 
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      '• Learn the explanation after each card', 
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      '• Build your streak with correct answers', 
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing),

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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    mythFactProvider.isLoading
                        ? 'Loading Myth vs Fact statements...'
                        : 'Start Game',
                    style: TextStyle(fontSize: subtitleSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14)),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Streak: ${mythFactProvider.streak} 🔥',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (mythFactProvider.totalAnswered + 1) / mythFactProvider.currentStatements.length,
                color: Colors.green,
                backgroundColor: Colors.grey,
                minHeight: 8,
              ),
            ],
          ),
        ),

        Expanded(
          child: SwipeableCard(
            key: ValueKey(currentStatement.id),
            statement: currentStatement,
            onSwipe: (swipedRight) {
              final isCorrect = mythFactProvider.isAnswerCorrect(currentStatement, swipedRight);
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
              constraints: BoxConstraints(maxHeight: 120), // Limit height to prevent overflow
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryPurple.withOpacity(0.2)
                    : AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          currentStatement.isFact ? Icons.check_circle : Icons.cancel,
                          color: currentStatement.isFact ? AppColors.successGreen : AppColors.errorRed,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'This is a ${currentStatement.isFact ? 'FACT ✓' : 'MYTH ✗'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentStatement.isFact ? AppColors.successGreen : AppColors.errorRed,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentStatement.explanation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: isDesktop ? 11 : 12, color: Colors.grey)),
        SizedBox(height: isDesktop ? 3 : 4),
        Text(value, style: TextStyle(fontSize: isDesktop ? 20 : 22, fontWeight: FontWeight.bold)),
        Text(unit, style: TextStyle(fontSize: isDesktop ? 10 : 11, color: Colors.grey)),
      ],
    );
  }
}
