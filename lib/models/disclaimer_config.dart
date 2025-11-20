/// Configuration for the disclaimer system
/// Contains all disclaimer text and high-risk keyword patterns
class DisclaimerConfig {
  // Full disclaimer shown once before entering chat
  static const String fullDisclaimerTitle = 'Important Notice';
  static const String fullDisclaimerText =
      '⚠️ AI-generated content may be inaccurate; not financial advice.';
  
  // Contextual warning message sent automatically for high-risk queries
  static const String contextualWarningMessage =
      'Note: I can provide general information, but this is not financial advice.';
  
  // High-risk keywords that trigger contextual warnings
  // Organized by category for easy maintenance
  static const List<String> investmentKeywords = [
    'invest',
    'investment',
    'stock',
    'stocks',
    'buy stock',
    'sell stock',
    'portfolio',
    'trading',
    'trade',
    'crypto',
    'cryptocurrency',
    'bitcoin',
    'ethereum',
    'mutual fund',
    'etf',
    'bond',
    'bonds',
    'share',
    'shares',
  ];
  
  static const List<String> taxKeywords = [
    'tax avoidance',
    'avoid tax',
    'evade tax',
    'tax evasion',
    'hide income',
    'offshore account',
    'tax loophole',
    'tax shelter',
  ];
  
  static const List<String> predictionKeywords = [
    'predict',
    'prediction',
    'forecast',
    'will rise',
    'will fall',
    'will increase',
    'will decrease',
    'future price',
    'price target',
    'market crash',
    'bull market',
    'bear market',
  ];
  
  static const List<String> personalFinanceKeywords = [
    'should i invest',
    'should i buy',
    'should i sell',
    'what should i do',
    'recommend investment',
    'best investment',
    'where to invest',
    'how much to invest',
    'retirement plan',
    'financial plan',
    'personalized advice',
  ];
  
  static const List<String> loanKeywords = [
    'loan',
    'borrow',
    'debt',
    'mortgage',
    'credit card debt',
    'refinance',
    'bankruptcy',
  ];
  
  // Combined list of all high-risk keywords
  static List<String> get allHighRiskKeywords => [
    ...investmentKeywords,
    ...taxKeywords,
    ...predictionKeywords,
    ...personalFinanceKeywords,
    ...loanKeywords,
  ];
  
  // SharedPreferences key for tracking if disclaimer was shown
  static const String disclaimerShownKey = 'chat_disclaimer_shown';
}
