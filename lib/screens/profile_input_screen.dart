import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../providers/chat_provider.dart';
import '../services/perplexity_service.dart';
import '../providers/quiz_provider.dart';
import '../providers/myth_fact_provider.dart';
import '../providers/daily_fact_provider.dart';
import '../widgets/theme_toggle.dart';
import '../utils/responsive_helper.dart';
import 'main_navigation_screen.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({Key? key}) : super(key: key);

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedIncomeRange = '5-10 LPA';
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _incomeRanges = ['Below 5 LPA', '5-10 LPA', '10-20 LPA', '20-50 LPA', 'Above 50 LPA'];

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getPadding(context, mobile: 16, desktop: 12);
    final titleSize = ResponsiveHelper.getFontSize(context, mobile: 24, desktop: 20);
    final subtitleSize = ResponsiveHelper.getFontSize(context, mobile: 14, desktop: 13);
    final spacing = ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
        elevation: 0,
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    '💰 Welcome to Money Buddy!',
                    style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6)),
                  Text(
                    'Tell us about yourself to get personalized financial advice',
                    style: TextStyle(fontSize: subtitleSize, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 24)),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),

                  // Occupation
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your occupation';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),

                  // Age
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 100) {
                        return 'Please enter a valid age (18-100)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: _genderOptions.map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  SizedBox(height: spacing),

                  // Income Range
                  DropdownButtonFormField<String>(
                    value: _selectedIncomeRange,
                    decoration: const InputDecoration(
                      labelText: 'Annual Income Range',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    items: _incomeRanges.map((range) {
                      return DropdownMenuItem(value: range, child: Text(range));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIncomeRange = value!;
                      });
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 24)),

                  // FIX #3: Revert to original simple button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14)),
                      ),
                      child: Text('Start Exploring', style: TextStyle(fontSize: subtitleSize)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        occupation: _occupationController.text,
        incomeRange: _selectedIncomeRange,
      );

      await StorageService().saveUserProfile(profile);

      if (mounted) {
        context.read<ChatProvider>().setUserProfile(profile);
        context.read<QuizProvider>().setUserProfile(profile);
        context.read<MythFactProvider>().setUserProfile(profile);
        context.read<DailyFactProvider>().setUserProfile(profile); // NEW LINE

        // Prefetch content
        PerplexityService().generateQuizQuestions(profile, 'Beginner', 5).then((quiz) {
          context.read<QuizProvider>().preloadQuiz(quiz);
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }
}
