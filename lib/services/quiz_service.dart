import '../models/quiz_models.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();

  factory QuizService() {
    return _instance;
  }

  QuizService._internal();

  final List<QuizQuestion> _allQuestions = _initializeQuestions();

  List<QuizQuestion> getQuestionsByDifficulty(String difficulty) {
    return _allQuestions
        .where((q) => q.difficulty == difficulty)
        .toList()
        ..shuffle();
  }

  List<QuizQuestion> getDailyQuiz(String difficulty) {
    return getQuestionsByDifficulty(difficulty).take(5).toList();
  }

  bool isAnswerCorrect(QuizQuestion question, int selectedIndex) {
    return selectedIndex == question.correctAnswer;
  }

  static List<QuizQuestion> _initializeQuestions() {
    return [
      // SIP Questions
      QuizQuestion(
        id: 1,
        question: 'What does SIP stand for?',
        options: ['Simple Investment Plan', 'Systematic Investment Plan', 'Stock Investment Program', 'Savings Investment Plan'],
        correctAnswer: 1,
        explanation: 'SIP stands for Systematic Investment Plan. It allows you to invest a fixed amount regularly in mutual funds.',
        category: 'SIP',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 2,
        question: 'What is the minimum investment in SIP?',
        options: ['₹5000', '₹1000', '₹100', '₹10000'],
        correctAnswer: 2,
        explanation: 'Most SIPs allow investment as low as ₹100 or even ₹500, making it accessible to everyone.',
        category: 'SIP',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 3,
        question: 'What is the advantage of SIP during market downturns?',
        options: ['You make more profit', 'You buy more units at lower prices', 'You lose less money', 'No advantage'],
        correctAnswer: 1,
        explanation: 'During market downturns, your fixed SIP amount buys more units at lower prices, averaging your cost over time (Rupee Cost Averaging).',
        category: 'SIP',
        difficulty: 'Intermediate',
      ),

      // Mutual Funds Questions
      QuizQuestion(
        id: 4,
        question: 'What is a Mutual Fund?',
        options: ['A bank savings account', 'A pool of money from multiple investors managed by a professional', 'A insurance policy', 'A stock exchange'],
        correctAnswer: 1,
        explanation: 'A mutual fund pools money from many investors and is managed by a professional fund manager to invest in stocks, bonds, or other securities.',
        category: 'Mutual Funds',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 5,
        question: 'What does NAV stand for?',
        options: ['National Asset Value', 'Net Asset Value', 'New Account Verification', 'Navigate Account Value'],
        correctAnswer: 1,
        explanation: 'NAV (Net Asset Value) is the per-unit price of a mutual fund, calculated as total assets minus liabilities divided by number of units.',
        category: 'Mutual Funds',
        difficulty: 'Beginner',
      ),

      // Stocks Questions
      QuizQuestion(
        id: 6,
        question: 'What is a stock?',
        options: ['A type of bond', 'A share of ownership in a company', 'A savings account', 'A type of insurance'],
        correctAnswer: 1,
        explanation: 'A stock represents a share of ownership in a company. When you buy stock, you become a partial owner of that company.',
        category: 'Stocks',
        difficulty: 'Beginner',
      ),

      // Tax Questions
      QuizQuestion(
        id: 7,
        question: 'What is ELSS?',
        options: ['Equity Long-term Savings Scheme', 'Equity Long-term Security Share', 'Equity Linked Savings Scheme', 'Equity Linked Safety Scheme'],
        correctAnswer: 2,
        explanation: 'ELSS (Equity Linked Savings Scheme) is a mutual fund that offers tax deduction under Section 80C and has a 3-year lock-in period.',
        category: 'Tax Saving',
        difficulty: 'Intermediate',
      ),

      // Insurance Questions
      QuizQuestion(
        id: 8,
        question: 'What is Term Insurance?',
        options: ['Insurance for a fixed period', 'Insurance with investment component', 'Life insurance with maturity benefit', 'Health insurance'],
        correctAnswer: 0,
        explanation: 'Term Insurance is pure life insurance that covers you for a fixed period (term). It pays out only if death occurs during the term.',
        category: 'Insurance',
        difficulty: 'Beginner',
      ),
    ];
  }
}
