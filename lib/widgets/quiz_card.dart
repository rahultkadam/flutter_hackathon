import 'package:flutter/material.dart';
import '../models/quiz_models.dart';

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
      color: Colors.white,
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
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
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
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: Colors.black87,
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
              Color textColor = Colors.black87;

              if (isAnswered) {
                if (isCorrect) {
                  bgColor = Colors.green[50]!;
                  borderColor = Colors.green[600]!;
                } else if (isWrong) {
                  bgColor = Colors.red[50]!;
                  borderColor = Colors.red[400]!;
                  textColor = Colors.red[800]!;
                } else {
                  bgColor = Colors.white;
                  borderColor = Colors.grey[300]!;
                }
              } else if (isSelected) {
                bgColor = Colors.blue[50]!;
                borderColor = Colors.blue[600]!;
              } else {
                bgColor = Colors.white;
                borderColor = Colors.grey[300]!;
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
                                  ? Colors.green
                                  : Colors.red)
                                  : Colors.blue)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected
                                ? (isAnswered
                                ? (isCorrect
                                ? Colors.green[100]
                                : Colors.red[100])
                                : Colors.blue[100])
                                : Colors.white,
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
                                  ? Colors.green
                                  : Colors.red)
                                  : Colors.blue,
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
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (isWrong)
                          const Icon(Icons.cancel, color: Colors.red),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Explanation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[900],
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
