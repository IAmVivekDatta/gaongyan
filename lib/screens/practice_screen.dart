import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/database_factory.dart';
import '../services/tts_service.dart';

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
  final TTSService _tts = TTSService();
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
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<UserProvider>().preferredLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(widget.moduleName, language)),
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
                            _localizedPracticeTitle(practice['title'] as String, language),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getStepsCountLabel((practice['steps'] as List).length, language),
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
                        ..._buildStepsList(practice['title'] as String, practice['steps'] as List<String>, language),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _showPracticeSimulation(practice, language);
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(_getButtonLabel('try', language)),
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
                                        SnackBar(content: Text(_getCompletionMessage(language))),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: Text(_getButtonLabel('complete', language)),
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
        onPressed: () async {
          await _tts.speak(_getVoiceSummary(language), language: language);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.headphones),
      ),
    );
  }

  List<Widget> _buildStepsList(String practiceTitle, List<String> steps, String language) {
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
                _localizedStep(practiceTitle, step, language),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _showPracticeSimulation(Map<String, dynamic> practice, String language) async {
    final title = _localizedPracticeTitle(practice['title'] as String, language);
    final steps = (practice['steps'] as List<String>)
        .map((step) => _localizedStep(practice['title'] as String, step, language))
        .toList();
    final narration = _buildSimulationScript(title, steps, language);

    await _tts.speak(narration, language: language);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getSimulationTitle(title, language),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.teal.shade50,
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await _tts.speak(narration, language: language);
                  },
                  icon: const Icon(Icons.volume_up),
                  label: Text(_getReplayLabel(language)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle(String moduleName, String language) {
    final localizedModule = _localizedModuleName(moduleName, language);
    switch (language) {
      case 'te':
        return 'ప్రాక్టీస్: $localizedModule';
      case 'hi':
        return 'अभ्यास: $localizedModule';
      default:
        return 'Practice: $localizedModule';
    }
  }

  String _getStepsCountLabel(int count, String language) {
    switch (language) {
      case 'te':
        return '$count అడుగులు';
      case 'hi':
        return '$count चरण';
      default:
        return '$count steps';
    }
  }

  String _getButtonLabel(String key, String language) {
    final labels = {
      'try': {
        'te': 'ప్రయత్నించండి',
        'hi': 'आजमाएं',
        'en': 'Try it',
      },
      'complete': {
        'te': 'పూర్తయిందని గుర్తించండి',
        'hi': 'पूर्ण चिह्नित करें',
        'en': 'Mark as Complete',
      },
    };

    return labels[key]?[language] ?? labels[key]?['en'] ?? key;
  }

  String _getCompletionMessage(String language) {
    switch (language) {
      case 'te':
        return 'ప్రాక్టీస్ పూర్తి అయినట్లు గుర్తించబడింది!';
      case 'hi':
        return 'अभ्यास को पूर्ण के रूप में चिह्नित किया गया!';
      default:
        return 'Practice marked as completed!';
    }
  }

  String _getVoiceSummary(String language) {
    final titles = _practices
        .map((practice) => _localizedPracticeTitle(practice['title'] as String, language))
        .join(', ');
    switch (language) {
      case 'te':
        return 'ఈ మాడ్యూల్ కోసం మూడు ప్రాక్టీస్ చర్యలు ఉన్నాయి: $titles. అడుగులను చదవడానికి కార్యాచరణను ఎంచుకోండి లేదా ప్రయత్నించండి బటన్‌ను నొక్కి మార్గదర్శకాన్ని వినండి.';
      case 'hi':
        return 'इस मॉड्यूल के लिए तीन अभ्यास गतिविधियाँ हैं: $titles. चरण पढ़ने के लिए किसी गतिविधि का चयन करें या आजमाएं बटन दबाकर निर्देश सुनें.';
      default:
        return 'There are three practice activities for this module: $titles. Select an activity to review the steps or press Try it to hear guided instructions.';
    }
  }

  String _buildSimulationScript(String title, List<String> steps, String language) {
    final joinedSteps = steps.asMap().entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join(language == 'en' ? '. ' : ' ');
    switch (language) {
      case 'te':
        return '$title కోసం సూచనలు: $joinedSteps.';
      case 'hi':
        return '$title के लिए निर्देश: $joinedSteps।';
      default:
        return 'Here are the instructions for $title: $joinedSteps.';
    }
  }

  String _getSimulationTitle(String title, String language) {
    switch (language) {
      case 'te':
        return '$title - సూచనలు';
      case 'hi':
        return '$title - निर्देश';
      default:
        return '$title - Instructions';
    }
  }

  String _getReplayLabel(String language) {
    switch (language) {
      case 'te':
        return 'మళ్లీ వినండి';
      case 'hi':
        return 'फिर से सुनें';
      default:
        return 'Replay Audio';
    }
  }

  String _localizedModuleName(String moduleName, String language) {
    final translations = {
      'Basic Smartphone Usage': {
        'te': 'ప్రాథమిక స్మార్ట్‌ఫోన్ వినియోగం',
        'hi': 'मूलभूत स्मार्टफोन उपयोग',
      },
      'Internet Navigation': {
        'te': 'ఇంటర్నెట్ మార్గదర్శకం',
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

    final entry = translations[moduleName];
    if (entry != null && entry.containsKey(language)) {
      return entry[language]!;
    }
    return moduleName;
  }

  String _localizedPracticeTitle(String title, String language) {
    final translations = {
      'Making a Phone Call': {
        'te': 'ఫోన్ కాల్ చేయడం',
        'hi': 'फोन कॉल करना',
      },
      'Sending a Message': {
        'te': 'సందేశాన్ని పంపడం',
        'hi': 'संदेश भेजना',
      },
      'Taking a Photo': {
        'te': 'ఫోటో తీయడం',
        'hi': 'फोटो लेना',
      },
    };

    final entry = translations[title];
    if (entry != null && entry.containsKey(language)) {
      return entry[language]!;
    }
    return title;
  }

  String _localizedStep(String practiceTitle, String step, String language) {
    final translations = {
      'Making a Phone Call': {
        'Open the Phone app': {
          'te': 'ఫోన్ యాప్ తెరవండి',
          'hi': 'फोन ऐप खोलें',
        },
        'Type the phone number': {
          'te': 'ఫోన్ నంబర్ టైప్ చేయండి',
          'hi': 'फोन नंबर टाइप करें',
        },
        'Press the green call button': {
          'te': 'పచ్చ కాల్ బటన్ నొక్కండి',
          'hi': 'हरा कॉल बटन दबाएं',
        },
        'Wait for the other person to answer': {
          'te': 'ఇతర వ్యక్తి స్పందించేందుకు వేచి ఉండండి',
          'hi': 'दूसरे व्यक्ति के जवाब देने तक प्रतीक्षा करें',
        },
        'Press the red button to end the call': {
          'te': 'ముగించడానికి ఎరుపు బటన్ నొక్కండి',
          'hi': 'कॉल समाप्त करने के लिए लाल बटन दबाएं',
        },
      },
      'Sending a Message': {
        'Open the Messages app': {
          'te': 'మెసేజెస్ యాప్ తెరవండి',
          'hi': 'संदेश ऐप खोलें',
        },
        'Click on New Message': {
          'te': 'కొత్త సందేశం పై క్లిక్ చేయండి',
          'hi': 'नया संदेश पर क्लिक करें',
        },
        'Enter the recipient\'s number': {
          'te': 'గ్రహీత నంబర్ నమోదు చేయండి',
          'hi': 'प्राप्तकर्ता का नंबर दर्ज करें',
        },
        'Type your message': {
          'te': 'మీ సందేశం టైప్ చేయండి',
          'hi': 'अपना संदेश टाइप करें',
        },
        'Press the send button': {
          'te': 'సెండ్ బటన్ నొక్కండి',
          'hi': 'भेजें बटन दबाएं',
        },
      },
      'Taking a Photo': {
        'Open the Camera app': {
          'te': 'కెమెరా యాప్ తెరవండి',
          'hi': 'कैमरा ऐप खोलें',
        },
        'Point the camera at your subject': {
          'te': 'కెమెరాను లక్ష్యంపై ఉంచండి',
          'hi': 'कैमरा को अपने विषय की ओर करें',
        },
        'Make sure the image is clear': {
          'te': 'చిత్రం స్పష్టంగా ఉందా చూసుకోండి',
          'hi': 'सुनिश्चित करें कि छवि स्पष्ट है',
        },
        'Press the capture button': {
          'te': 'క్యాప్చర్ బటన్ నొక్కండి',
          'hi': 'कैप्चर बटन दबाएं',
        },
        'Check the photo in gallery': {
          'te': 'గ్యాలరీలో ఫోటోను తనిఖీ చేయండి',
          'hi': 'गैलरी में फोटो देखें',
        },
      },
    };

    final practiceTranslations = translations[practiceTitle];
    final stepTranslations = practiceTranslations?[step];
    if (stepTranslations != null && stepTranslations.containsKey(language)) {
      return stepTranslations[language]!;
    }
    return step;
  }
}
