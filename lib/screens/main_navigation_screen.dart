import 'package:flutter/material.dart';
import '../widgets/theme_toggle.dart';
import 'chat_screen.dart';
import 'quiz_screen.dart';
import 'myth_fact_screen.dart';
import 'daily_facts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const QuizScreen(),
    const MythFactScreen(),
    const DailyFactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Buddy'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Myth vs Fact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Daily Facts', // FIX #5: Renamed from "Daily Facts"
          ),
        ],
      ),
    );
  }
}
