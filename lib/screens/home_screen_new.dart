import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'module_screen.dart';
import 'quiz_screen.dart';
import 'practice_screen.dart';
import '../services/tts_service.dart';
import '../services/database_interface.dart';
import '../services/database_factory.dart';
import '../providers/user_provider.dart';
import '../providers/module_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _tts = TTSService();
  // ignore: unused_field
  late final BaseDatabaseService _db;
  late ModuleProvider _moduleProvider;

  String _getWelcomeText(String language, int moduleCount) {
    switch (language) {
      case 'te':
        return 'గ్రామ జ్ఞాన్ కు స్వాగతం. మీకు $moduleCount అభ్యాస మాడ్యూల్స్ అందుబాటులో ఉన్నాయి.';
      case 'hi':
        return 'गांव ज्ञान में आपका स्वागत है। आपके पास $moduleCount सीखने के मॉड्यूल उपलब्ध हैं।';
      default:
        return 'Welcome to Gaon Gyaan. You have $moduleCount learning modules available.';
    }
  }
  
  @override
  void initState() {
    super.initState();
    _db = DatabaseFactory.getDatabaseService();
    _moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
    _loadModuleProgress();
  }

  Future<void> _loadModuleProgress() async {
    final userId = context.read<UserProvider>().userId;
    if (userId != null) {
      await _moduleProvider.loadProgressForUser(userId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadModuleProgress();
  }

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Basic Smartphone Usage',
      'icon': Icons.smartphone,
      'level': 1,
    },
    {
      'title': 'Internet Navigation',
      'icon': Icons.language,
      'level': 2,
    },
    {
      'title': 'Digital Payments',
      'icon': Icons.payment,
      'level': 3,
    },
    {
      'title': 'Government Services',
      'icon': Icons.account_balance,
      'level': 4,
    },
  ];

  int _currentLevel(List<Map<String, dynamic>> modules) {
    for (int level = modules.length; level >= 1; level--) {
      final modulesForLevel = modules.where((m) => m['level'] == level);
      if (modulesForLevel.isNotEmpty && modulesForLevel.every((m) => (m['progress'] ?? 0.0) >= 1.0)) {
        return level;
      }
    }
    return 0;
  }

  double _overallProgress(List<Map<String, dynamic>> modules) {
    if (modules.isEmpty) return 0.0;
    double total = 0.0;
    for (var m in modules) {
      total += (m['progress'] ?? 0.0) as double;
    }
    return total / modules.length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleProvider>(
      builder: (context, moduleProvider, _) {
        final modules = moduleProvider.modules.isNotEmpty ? moduleProvider.modules : _modules;
        final userProvider = context.watch<UserProvider>();
        final language = userProvider.preferredLanguage;
        final currentLevelValue = _currentLevel(modules);
        final overallProgressValue = _overallProgress(modules);
        final greeting = _getGreeting(userProvider.name, language);
        final welcomeText = _getWelcomeText(language, modules.length);
        final currentLevelLabel = _getCurrentLevelLabel(currentLevelValue, language);
        final overallProgressLabel = _getOverallProgressLabel(overallProgressValue, language);
        final moduleSectionLabel = _getModulesHeading(language);
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppTitle(language)),
            backgroundColor: Colors.green,
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              welcomeText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              currentLevelLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: overallProgressValue,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            Text(
                              overallProgressLabel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moduleSectionLabel,
                        style: const TextStyle(
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
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          return _buildModuleCard(modules[index], language);
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
              final text = _getWelcomeText(language, modules.length);
              await _tts.speak(text, language: language);
            },
          ),
        );
      },
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module, String language) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () async {
          final baseTitle = module['title'] as String;
          final localizedTitle = _localizedModuleTitle(baseTitle, language);
          await _tts.speak(
            _getOpeningModuleText(localizedTitle, language),
            language: language,
          );
          if (!mounted) return;
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.green),
                  title: Text(_getActionLabel('learn', language)),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleScreen(
                          title: baseTitle,
                        ),
                      ),
                    );
                    _loadModuleProgress();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sports_esports, color: Colors.teal),
                  title: Text(_getActionLabel('practice', language)),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PracticeScreen(
                          moduleName: baseTitle,
                        ),
                      ),
                    );
                    _loadModuleProgress();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.orange),
                  title: Text(_getActionLabel('quiz', language)),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          moduleName: baseTitle,
                        ),
                      ),
                    );
                    _loadModuleProgress();
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
                _localizedModuleTitle(module['title'] as String, language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (module['progress'] ?? 0.0) as double,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                _getModuleCompletionLabel((module['progress'] ?? 0.0) as double, language),
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

  String _getAppTitle(String language) {
    switch (language) {
      case 'te':
        return 'గ్రామ జ్ఞాన్';
      case 'hi':
        return 'गांव ज्ञान';
      default:
        return 'Gaon Gyaan';
    }
  }

  String _getGreeting(String? name, String language) {
    final displayName = name?.isNotEmpty == true ? name! : _getLearnerFallback(language);
    switch (language) {
      case 'te':
        return 'నమస్తే, $displayName!';
      case 'hi':
        return 'नमस्ते, $displayName!';
      default:
        return 'Hello, $displayName!';
    }
  }

  String _getLearnerFallback(String language) {
    switch (language) {
      case 'te':
        return 'స్నేహితుడా';
      case 'hi':
        return 'मित्र';
      default:
        return 'Learner';
    }
  }

  String _getCurrentLevelLabel(int level, String language) {
    switch (language) {
      case 'te':
        return 'ప్రస్తుత స్థాయి: $level';
      case 'hi':
        return 'वर्तमान स्तर: $level';
      default:
        return 'Current Level: $level';
    }
  }

  String _getOverallProgressLabel(double progress, String language) {
    final percent = (progress * 100).toInt();
    switch (language) {
      case 'te':
        return 'మొత్తం పురోగతి: $percent%';
      case 'hi':
        return 'कुल प्रगति: $percent%';
      default:
        return 'Overall Progress: $percent%';
    }
  }

  String _getModulesHeading(String language) {
    switch (language) {
      case 'te':
        return 'అభ్యాస మాడ్యూల్స్';
      case 'hi':
        return 'सीखने के मॉड्यूल';
      default:
        return 'Learning Modules';
    }
  }

  String _getModuleCompletionLabel(double progress, String language) {
    final percent = (progress * 100).toInt();
    switch (language) {
      case 'te':
        return '$percent% పూర్తి';
      case 'hi':
        return '$percent% पूरा';
      default:
        return '$percent% Complete';
    }
  }

  String _localizedModuleTitle(String baseTitle, String language) {
    final translations = {
      'Basic Smartphone Usage': {
        'te': 'ప్రాథమిక స్మార్ట్‌ఫోన్ ఉపయోగం',
        'hi': 'मूलभूत स्मार्टफोन उपयोग',
      },
      'Internet Navigation': {
        'te': 'ఇంటర్నెట్ మార్గదర్శనం',
        'hi': 'इंटरनेट नेविगेशन',
      },
      'Digital Payments': {
        'te': 'డిజిటల్ చెల్లింపులు',
        'hi': 'डिजिटल भुगतान',
      },
      'Government Services': {
        'te': 'ప్రభుత్వ సేవలు',
        'hi': 'सरकारी सेवाएं',
      },
    };

    final entry = translations[baseTitle];
    if (entry != null && entry.containsKey(language)) {
      return entry[language]!;
    }
    return baseTitle;
  }

  String _getOpeningModuleText(String title, String language) {
    switch (language) {
      case 'te':
        return '$title ను తెరవుతున్నాను';
      case 'hi':
        return '$title खोल रहा हूँ';
      default:
        return 'Opening $title';
    }
  }

  String _getActionLabel(String action, String language) {
    final labels = {
      'learn': {
        'te': 'నేర్చుకోండి',
        'hi': 'सीखें',
        'en': 'Learn',
      },
      'practice': {
        'te': 'అభ్యాసం చేయండి',
        'hi': 'अभ्यास करें',
        'en': 'Practice',
      },
      'quiz': {
        'te': 'క్విజ్ తీసుకోండి',
        'hi': 'प्रश्नोत्तरी दें',
        'en': 'Take Quiz',
      },
    };

    return labels[action]?[language] ?? labels[action]?['en'] ?? action;
  }
}
