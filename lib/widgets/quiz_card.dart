import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatelessWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isAnswered;

  const QuizCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.isAnswered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question counters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $questionNumber/$totalQuestions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.difficulty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Question text
            Text(
              question.question,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...question.options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              bool isSelected = selectedAnswer == index;
              bool isCorrect = index == question.correctAnswer;
              bool isWrong = isAnswered && isSelected && !isCorrect;

              // Color logic
              Color bgColor;
              Color borderColor;
              Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

              if (isAnswered) {
                if (isCorrect) {
                  bgColor = AppColors.successGreen.withOpacity(0.1);
                  borderColor = AppColors.successGreen;
                  textColor = AppColors.successGreen.withOpacity(0.9);
                } else if (isWrong) {
                  bgColor = AppColors.errorRed.withOpacity(0.1);
                  borderColor = AppColors.errorRed;
                  textColor = AppColors.errorRed.withOpacity(0.9);
                } else {
                  bgColor = Theme.of(context).colorScheme.surface;
                  borderColor = Theme.of(context).colorScheme.outline;
                  textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
                }
              } else if (isSelected) {
                bgColor = AppColors.primaryPurple.withOpacity(0.1);
                borderColor = AppColors.primaryPurple;
                textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
              } else {
                bgColor = Theme.of(context).colorScheme.surface;
                borderColor = Theme.of(context).colorScheme.outline;
                textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: isAnswered ? null : () => onAnswerSelected(index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isAnswered
                                  ? (isCorrect
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                                  : AppColors.primaryPurple)
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                            color: isSelected
                                ? (isAnswered
                                ? (isCorrect
                                ? AppColors.successGreen.withOpacity(0.2)
                                : AppColors.errorRed.withOpacity(0.2))
                                : AppColors.primaryPurple.withOpacity(0.2))
                                : Theme.of(context).colorScheme.surface,
                          ),
                          child: isSelected
                              ? Center(
                            child: Icon(
                              isAnswered
                                  ? (isCorrect
                                  ? Icons.check
                                  : Icons.close)
                                  : Icons.check,
                              size: 14,
                              color: isAnswered
                                  ? (isCorrect
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                                  : AppColors.primaryPurple,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (isAnswered && isCorrect)
                          Icon(Icons.check_circle, color: AppColors.successGreen),
                        if (isWrong)
                          Icon(Icons.cancel, color: AppColors.errorRed),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            if (isAnswered) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Explanation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
