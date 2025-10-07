
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/module_provider.dart';
import 'level_detail_screen.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  Widget _buildProgressSection(BuildContext context, List<Map<String, dynamic>> modules) {
    // Calculate current level and XP dynamically
    int maxLevel = 4;
    int currentLevel = 0;
    double totalProgress = 0.0;
    for (int level = maxLevel; level >= 1; level--) {
      final modulesForLevel = modules.where((m) => m['level'] == level);
      if (modulesForLevel.isNotEmpty && modulesForLevel.every((m) => (m['progress'] ?? 0.0) >= 1.0)) {
        currentLevel = level;
        break;
      }
    }
    for (var m in modules) {
      totalProgress += (m['progress'] ?? 0.0) as double;
    }
    int currentXP = (totalProgress * 100).toInt();
    int xpForNextLevel = 100;
    double progress = (currentXP % xpForNextLevel) / xpForNextLevel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFffd700), Color(0xFFff9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Intl.message('Current Level', name: 'currentLevel'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        Intl.message('Level $currentLevel', name: 'level', args: [currentLevel], examples: const {'level': 2}),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  Intl.message('Max: $maxLevel', name: 'maxLevel', args: [maxLevel], examples: const {'maxLevel': 10}),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  minHeight: 18,
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Positioned(
                left: 12 + (progress * 220).clamp(0, 220),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    Intl.message('$currentXP / $xpForNextLevel XP', name: 'progress', args: [currentXP, xpForNextLevel], examples: const {'currentXP': 25, 'xpForNextLevel': 50}),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Intl.message('Level $currentLevel', name: 'level', args: [currentLevel], examples: const {'level': 2}),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Intl.message('Level $maxLevel', name: 'level', args: [maxLevel], examples: const {'level': 10}),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementCards() {
    final achievements = [
      {
        'title': 'First Step',
        'description': 'Complete your first module',
        'icon': Icons.star,
        'color': Colors.blue,
        'unlocked': true,
      },
      {
        'title': 'Quick Learner',
        'description': 'Complete 5 modules',
        'icon': Icons.flash_on,
        'color': Colors.green,
        'unlocked': true,
      },
      {
        'title': 'Perfect Score',
        'description': 'Get 100% in a quiz',
        'icon': Icons.grade,
        'color': Colors.purple,
        'unlocked': false,
      },
      {
        'title': 'Helper',
        'description': 'Help 3 other learners',
        'icon': Icons.people,
        'color': Colors.orange,
        'unlocked': false,
      },
    ];

    return achievements.map((achievement) {
      final bool unlocked = achievement['unlocked'] as bool;
      final Color baseColor = achievement['color'] as Color;

      return Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: unlocked ? baseColor.withOpacity(0.1) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                achievement['icon'] as IconData,
                size: 48,
                color: unlocked ? baseColor : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                achievement['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? baseColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement['description'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: unlocked ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
  final moduleProvider = Provider.of<ModuleProvider>(context);
  final userModules = moduleProvider.modules;
  final completedModules = userModules
    .where((m) => (m['progress'] ?? 0.0) >= 1.0)
    .map((m) => m['title'] as String)
    .toList();

    // Example: 4 levels, each with required modules
    final List<Map<String, dynamic>> levels = [
      {
        'level': 1,
        'title': 'Level 1: Getting Started',
        'requiredModules': ['Basic Smartphone Usage'],
      },
      {
        'level': 2,
        'title': 'Level 2: Digital Skills',
        'requiredModules': ['Internet Navigation'],
      },
      {
        'level': 3,
        'title': 'Level 3: Practice & Quiz',
        'requiredModules': ['Digital Payments'],
      },
      {
        'level': 4,
        'title': 'Level 4: Mastery',
        'requiredModules': ['Government Services'],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message('Achievements App', name: 'appTitle')),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Pass real data to LevelDetailScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelDetailScreen(
                      currentLevel: 1, // You can make this dynamic
                      requiredModules: levels[0]['requiredModules'],
                      completedModules: completedModules,
                    ),
                  ),
                );
              },
              child: _buildProgressSection(context, userModules),
            ),
            const SizedBox(height: 24),
            Text(
              Intl.message('Your Badges', name: 'yourBadges'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: _buildAchievementCards(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Intl.message('Levels', name: 'levels'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final required = level['requiredModules'] as List<String>;
                      final completed = required.every((m) => completedModules.contains(m));
                      return Card(
                        color: completed ? Colors.orange.shade100 : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            Icons.emoji_events,
                            color: completed ? Colors.orange : Colors.grey,
                          ),
                          title: Text(level['title']),
                          subtitle: Text('Complete all required modules to finish this level.'),
                          trailing: completed
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
