import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/database_factory.dart';
import '../data/module_video_links.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ModuleScreen extends StatefulWidget {
  final String title;
  
  const ModuleScreen({
    super.key,
    required this.title,
  });

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  // Removed unused _db field
  int _currentStep = 0;
  // Removed unused _inlineController field

  @override
  void initState() {
    super.initState();
    // No YoutubePlayer initialization needed
  }

  Future<void> _launchYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch YouTube.')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> get _steps {
    // Dynamically fetch videoId for each step from ModuleVideoLinks
    return [
      {
        'title': 'Introduction',
        'content': 'Welcome to this learning module. Here you will learn the basics step by step.',
        'hasVideo': false,
        'videoId': ModuleVideoLinks.getVideoId(widget.title, 0),
      },
      {
        'title': 'Basic Concepts',
        'content': 'Let\'s start with the fundamental concepts you need to know.',
        'hasVideo': true,
        'videoId': ModuleVideoLinks.getVideoId(widget.title, 1),
      },
      {
        'title': 'Practical Exercise',
        'content': 'Now let\'s practice what we\'ve learned with some hands-on exercises.',
        'hasVideo': true,
        'videoId': ModuleVideoLinks.getVideoId(widget.title, 2),
      },
      {
        'title': 'Quiz',
        'content': 'Test your knowledge with this quick quiz.',
        'hasVideo': true,
        'videoId': ModuleVideoLinks.getVideoId(widget.title, 3),
      },
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () async {
          if (_currentStep < _steps.length - 1) {
            setState(() => _currentStep += 1);
          } else {
            // User finished all steps, mark module as complete
            final userId = Provider.of<UserProvider>(context, listen: false).userId;
            final db = DatabaseFactory.getDatabaseService();
            if (userId != null) {
              await db.updateProgress(userId, widget.title, 1.0);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.title} marked as completed!')),
                );
              }
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: List.generate(
          _steps.length,
          (index) => _buildStep(_steps[index], index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.headphones),
        onPressed: () {
          // TODO: Implement voice guidance for current step
        },
      ),
    );
  }

  Step _buildStep(Map<String, dynamic> stepData, int stepIndex) {
    final debugVideoId = stepData['videoId'];
    // ignore: avoid_print
    print('Module: ${widget.title}, Step: $stepIndex, VideoId: $debugVideoId');
    return Step(
      title: Text(
        stepData['title'] as String,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stepData['content'] as String),
          const SizedBox(height: 16),
          if (stepData['hasVideo'] == true && stepData['videoId'] != null && (stepData['videoId'] as String).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: stepData['videoId'] as String,
                    flags: const YoutubePlayerFlags(
                      autoPlay: false,
                      mute: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _launchYouTube(stepData['videoId'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Open in YouTube'),
                ),
              ],
            ),
        ],
      ),
    isActive: _currentStep >= stepIndex,
    state: _currentStep > stepIndex
      ? StepState.complete
      : StepState.indexed,
    );
  }
}
