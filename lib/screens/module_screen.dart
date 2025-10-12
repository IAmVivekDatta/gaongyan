import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/database_factory.dart';
import '../data/module_video_links.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tts_service.dart';

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

  List<Map<String, dynamic>> _buildSteps(String language) {
  final titles = _localizedStepTitles(language);
  final contents = _localizedStepContents(language);

    return List.generate(titles.length, (index) {
      return {
        'title': titles[index],
        'content': contents[index],
        'hasVideo': true,
        'videoId': ModuleVideoLinks.getVideoId(widget.title, index),
      };
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final language = context.watch<UserProvider>().preferredLanguage;
    final steps = _buildSteps(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () async {
          if (_currentStep < steps.length - 1) {
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
          steps.length,
          (index) => _buildStep(steps[index], index, language),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.headphones),
        onPressed: () async {
          final stepText = steps[_currentStep]['content'] as String? ?? '';
          // Use TTSService to speak the step content
          try {
            final tts = TTSService();
            await tts.speak(stepText, language: language);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice guidance failed: $e')),
            );
          }
        },
      ),
    );
  }

  Step _buildStep(Map<String, dynamic> stepData, int stepIndex, String language) {
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

  List<String> _localizedStepTitles(String language) {
    final translations = {
      'te': ['పరిచయం', 'ప్రాధమిక అంశాలు', 'ప్రాయోగిక అభ్యాసం', 'మీరు స్వయంగా ప్రయత్నించండి'],
      'hi': ['परिचय', 'मूलभूत अवधारणा', 'व्यावहारिक अभ्यास', 'खुद आजमाएं'],
      'en': ['Introduction', 'Basic Concepts', 'Practical Exercise', 'Try Your Self'],
    };

    return translations[language] ?? translations['en']!;
  }

  List<String> _localizedStepContents(String language) {
    final translations = {
      'te': [
        'ఈ అభ్యాస భాగానికి స్వాగతం. మీరు ప్రతి అడుగులో ప్రాథమిక సమాచారం నేర్చుకుంటారు. ముందుకు సాగేందుకు తదుపరి బటన్‌ను నొక్కండి.',
        'ముందుగా తెలుసుకోవాల్సిన ముఖ్యమైన ఆలోచనలు చూద్దాం.',
        'ఇప్పుడు మనం నేర్చుకున్నదాన్ని ప్రాయోగికంగా అభ్యాసం చేసుకుందాం.',
        'ఇప్పుడో చిన్న పరీక్ష ద్వారా మీ అవగాహనను పరీక్షించండి.',
      ],
      'hi': [
        'इस मॉड्यूल में आपका स्वागत है। आप हर चरण में मूल बातें सीखेंगे। आगे बढ़ने के लिए अगला बटन दबाएं.',
        'पहले आवश्यक बुनियादी सिद्धांतों को समझते हैं.',
        'अब हम अभ्यास के माध्यम से जो सीखा है उसे दोहराते हैं.',
        'अब एक छोटे क्विज़ के साथ अपने ज्ञान की जाँच करें.',
      ],
      'en': [
        'Welcome to this learning module. Here you will learn the basics step by step. Continue your journey by tapping the next button.',
        'Let\'s start with the fundamental concepts you need to know.',
        'Now let\'s practice what we\'ve learned with some hands-on exercises.',
        'Test your knowledge with this quick quiz.',
      ],
    };

    return translations[language] ?? translations['en']!;
  }
}
