import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'module_screen.dart';
import 'quiz_screen.dart';
import 'practice_screen.dart';
import '../services/tts_service.dart';
import '../services/database_interface.dart';
import '../services/database_factory.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _tts = TTSService();
  final BaseDatabaseService _db = DatabaseFactory.getDatabaseService();

  String _getWelcomeText(String language) {
    final Map<String, String> welcomeText = {
      'en': 'Welcome to Gaon Gyaan. You have ${_modules.length} learning modules available.',
      'hi': 'गांव ज्ञान में आपका स्वागत है। आपके पास ${_modules.length} सीखने के मॉड्यूल उपलब्ध हैं।',
      'te': 'గ్రామ జ్ఞాన్ కు స్వాగతం. మీకు ${_modules.length} అభ్యాస మాడ్యూల్స్ అందుబాటులో ఉన్నాయి.'
    };
    return welcomeText[language] ?? welcomeText['en']!;
  }
  
  @override
  void initState() {
    super.initState();
    _loadModuleProgress();
  }

  Future<void> _loadModuleProgress() async {
    final userId = context.read<UserProvider>().userId;
    if (userId != null) {
      for (var module in _modules) {
        final progress = await _db.getProgress(userId, module['title'] as String);
        module['progress'] = progress;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Basic Smartphone Usage',
      'icon': Icons.smartphone,
      'progress': 0.0,
    },
    {
      'title': 'Internet Navigation',
      'icon': Icons.language,
      'progress': 0.0,
    },
    {
      'title': 'Digital Payments',
      'icon': Icons.payment,
      'progress': 0.0,
    },
    {
      'title': 'Government Services',
      'icon': Icons.account_balance,
      'progress': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaon Gyaan'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // Language selection is handled in Settings
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${userProvider.name}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Continue your learning journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Modules',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _modules.length,
                    itemBuilder: (context, index) {
                      return _buildModuleCard(_modules[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.headphones),
        onPressed: () async {
          final userProvider = context.read<UserProvider>();
          final language = userProvider.preferredLanguage;
          final text = _getWelcomeText(language);
          await _tts.speak(text, language: language);
        },
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () async {
          final userProvider = context.read<UserProvider>();
          await _tts.speak(
            'Opening ${module['title']}',
            language: userProvider.preferredLanguage,
          );
          
          if (!mounted) return;
          
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.green),
                  title: const Text('Learn'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleScreen(
                          title: module['title'] as String,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sports_esports, color: Colors.teal),
                  title: const Text('Practice'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PracticeScreen(
                          moduleName: module['title'] as String,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.orange),
                  title: const Text('Take Quiz'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          moduleName: module['title'] as String,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                module['icon'] as IconData,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                module['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: module['progress'] as double,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '${((module['progress'] as double) * 100).toInt()}% Complete',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
