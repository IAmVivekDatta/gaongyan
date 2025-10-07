import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/database_factory.dart';

class PracticeScreen extends StatefulWidget {
  final String moduleName;

  const PracticeScreen({
    super.key,
    required this.moduleName,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final List<Map<String, dynamic>> _practices = [
    {
      'title': 'Making a Phone Call',
      'steps': [
        'Open the Phone app',
        'Type the phone number',
        'Press the green call button',
        'Wait for the other person to answer',
        'Press the red button to end the call'
      ],
      'completed': false,
    },
    {
      'title': 'Sending a Message',
      'steps': [
        'Open the Messages app',
        'Click on New Message',
        'Enter the recipient\'s number',
        'Type your message',
        'Press the send button'
      ],
      'completed': false,
    },
    {
      'title': 'Taking a Photo',
      'steps': [
        'Open the Camera app',
        'Point the camera at your subject',
        'Make sure the image is clear',
        'Press the capture button',
        'Check the photo in gallery'
      ],
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice: ${widget.moduleName}'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _practices.length,
        itemBuilder: (context, index) {
          final practice = _practices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            practice['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${(practice['steps'] as List).length} steps',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (practice['completed'] as bool)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildStepsList(practice['steps'] as List<String>),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement practice simulation
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Try it'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                setState(() {
                                  practice['completed'] = true;
                                });
                                final userId = Provider.of<UserProvider>(context, listen: false).userId;
                                final db = DatabaseFactory.getDatabaseService();
                                if (userId != null) {
                                  await db.updateProgress(userId, '${widget.moduleName}_practice', 1.0);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Practice marked as completed!')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Mark as Complete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement voice guidance
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.headphones),
      ),
    );
  }

  List<Widget> _buildStepsList(List<String> steps) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
