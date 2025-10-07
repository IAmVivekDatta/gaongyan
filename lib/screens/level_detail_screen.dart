import 'package:flutter/material.dart';

class LevelDetailScreen extends StatelessWidget {
  const LevelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated data for current and next level
    int currentLevel = 2;
    int nextLevel = currentLevel + 1;
    List<String> requiredModules = [
      'Module 1: Basics',
      'Module 2: Practice',
      'Module 3: Quiz',
      'Module 4: Project',
    ];
    List<String> completedModules = [
      'Module 1: Basics',
      'Module 2: Practice',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Level $nextLevel Details'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To reach Level $nextLevel, complete these modules:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...requiredModules.map((module) {
              bool done = completedModules.contains(module);
              return ListTile(
                leading: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? Colors.green : Colors.grey,
                ),
                title: Text(
                  module,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: done ? Colors.black : Colors.grey,
                  ),
                ),
                trailing: done
                    ? const Text('Done', style: TextStyle(color: Colors.green))
                    : const Text('Pending', style: TextStyle(color: Colors.orange)),
              );
            }),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: completedModules.length == requiredModules.length
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Congratulations! You can now level up!')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_upward),
                label: const Text('Level Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
