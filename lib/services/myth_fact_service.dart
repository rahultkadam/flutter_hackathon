import '../models/myth_fact_models.dart';

class MythFactService {
  static final MythFactService _instance = MythFactService._internal();

  factory MythFactService() {
    return _instance;
  }

  MythFactService._internal();

  final List<MythFactStatement> _allStatements = _initializeStatements();

  List<MythFactStatement> getRandomStatements(int count) {
    final shuffled = List<MythFactStatement>.from(_allStatements)..shuffle();
    return shuffled.take(count).toList();
  }

  bool isAnswerCorrect(MythFactStatement statement, bool userSwipedRight) {
  // User swiped right means they think it's a fact
  // Return true if user's swipe matches the actual fact state of the statement
  return userSwipedRight == statement.isFact;
}


  bool isCorrectAnswer(MythFactStatement statement, bool userSwipedRight) {
    // Swipe right = Fact, Swipe left = Myth
    if (userSwipedRight) {
      return statement.isFact; // User thinks it's fact
    } else {
      return !statement.isFact; // User thinks it's myth
    }
  }

  static List<MythFactStatement> _initializeStatements() {
    return [
      MythFactStatement(
        id: 1,
        statement: 'You need ₹1 lakh to start investing',
        isFact: false,
        explanation: 'False! Many investment options like SIPs start from just ₹100-500. You can start small and build wealth over time.',
        category: 'Investment Basics',
        emoji: '💰',
      ),
      MythFactStatement(
        id: 2,
        statement: 'PPF (Public Provident Fund) is 100% safe',
        isFact: true,
        explanation: 'True! PPF is backed by the government and offers guaranteed returns with no market risk. It\'s one of the safest investments.',
        category: 'Investment Basics',
        emoji: '🏦',
      ),
      MythFactStatement(
        id: 3,
        statement: 'Gold is always a good investment',
        isFact: false,
        explanation: 'False! While gold has traditionally been a safe asset, it doesn\'t always provide the best returns. Diversification is key.',
        category: 'Asset Classes',
        emoji: '⭐',
      ),
      MythFactStatement(
        id: 4,
        statement: 'SIP returns are guaranteed',
        isFact: false,
        explanation: 'False! SIPs invest in market-linked instruments where returns fluctuate based on market performance. Past returns don\'t guarantee future returns.',
        category: 'SIP',
        emoji: '📊',
      ),
      MythFactStatement(
        id: 5,
        statement: 'Mutual funds are managed by professionals',
        isFact: true,
        explanation: 'True! A qualified fund manager handles investment decisions, research, and portfolio management on your behalf.',
        category: 'Mutual Funds',
        emoji: '👨‍💼',
      ),
      MythFactStatement(
        id: 6,
        statement: 'You can withdraw PPF money anytime',
        isFact: false,
        explanation: 'False! PPF has specific withdrawal rules. You can withdraw after 7 years (or partial after 4 years). Early withdrawal has penalties.',
        category: 'PPF',
        emoji: '🔒',
      ),
      MythFactStatement(
        id: 7,
        statement: 'Stocks are only for rich people',
        isFact: false,
        explanation: 'False! Anyone can buy stocks. You can start investing in stocks with small amounts and build your portfolio gradually.',
        category: 'Stocks',
        emoji: '📈',
      ),
      MythFactStatement(
        id: 8,
        statement: 'Tax-saving investments always give good returns',
        isFact: false,
        explanation: 'False! Tax benefits and investment returns are separate. You should invest based on returns potential, not just tax benefits.',
        category: 'Tax Saving',
        emoji: '💡',
      ),
      MythFactStatement(
        id: 9,
        statement: 'Emergency fund should be kept in FD or Savings Account',
        isFact: true,
        explanation: 'True! Emergency funds should be liquid and safe. Savings accounts or FDs are ideal as you need quick access without risk.',
        category: 'Emergency Fund',
        emoji: '🚨',
      ),
      MythFactStatement(
        id: 10,
        statement: 'Debt mutual funds have zero risk',
        isFact: false,
        explanation: 'False! Debt funds carry interest rate risk and credit risk. They\'re safer than equity but not risk-free.',
        category: 'Mutual Funds',
        emoji: '⚠️',
      ),
      MythFactStatement(
        id: 11,
        statement: 'You must have insurance',
        isFact: true,
        explanation: 'True! Insurance protects your family\'s financial future. Term insurance is affordable and essential for earning members.',
        category: 'Insurance',
        emoji: '🛡️',
      ),
      MythFactStatement(
        id: 12,
        statement: 'Higher return investments are always high risk',
        isFact: true,
        explanation: 'True! Generally, investments with higher potential returns come with higher risk. Risk and return are correlated.',
        category: 'Risk Management',
        emoji: '⚡',
      ),
      MythFactStatement(
        id: 13,
        statement: 'You should panic sell when market crashes',
        isFact: false,
        explanation: 'False! Market crashes are opportunities to buy at lower prices. Panic selling locks in losses. Stay calm and follow your plan.',
        category: 'Market Psychology',
        emoji: '😨',
      ),
      MythFactStatement(
        id: 14,
        statement: 'Inflation erodes your savings purchasing power',
        isFact: true,
        explanation: 'True! Inflation reduces what your money can buy over time. That\'s why investing is important to beat inflation.',
        category: 'Economics',
        emoji: '📉',
      ),
      MythFactStatement(
        id: 15,
        statement: 'You can retire early with proper financial planning',
        isFact: true,
        explanation: 'True! With disciplined saving, smart investing, and compound growth, early retirement is achievable for many.',
        category: 'Retirement Planning',
        emoji: '🏖️',
      ),
    ];
  }
}
