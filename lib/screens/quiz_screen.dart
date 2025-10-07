import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/database_factory.dart';

class QuizScreen extends StatefulWidget {
  final String moduleName;

  const QuizScreen({
    super.key,
    required this.moduleName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the first step to turn on a smartphone?',
      'options': [
        'Press and hold the power button',
        'Tap the screen repeatedly',
        'Remove the battery',
        'Shake the phone'
      ],
      'correctAnswer': 0,
    },
    {
      'question': 'Which icon typically represents the internet browser?',
      'options': [
        'Envelope',
        'Globe or Compass',
        'Phone',
        'Camera'
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'How can you make text larger on your phone?',
      'options': [
        'Hold the phone closer',
        'Restart the phone',
        'Go to Settings and adjust font size',
        'Install more apps'
      ],
      'correctAnswer': 2,
    },
  ];

  void _checkAnswer(int selectedOption) {
    final isCorrect = selectedOption == _questions[_currentQuestionIndex]['correctAnswer'];
    
    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.moduleName}'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _quizCompleted
            ? _buildQuizComplete()
            : _buildQuizQuestion(),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    final question = _questions[_currentQuestionIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.orange.shade100,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
        const SizedBox(height: 24),
        Text(
          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          question['question'] as String,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        ..._buildOptions(question['options'] as List<String>),
      ],
    );
  }

  List<Widget> _buildOptions(List<String> options) {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton(
          onPressed: () => _checkAnswer(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.orange),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQuizComplete() {
    final percentage = (_score / _questions.length) * 100;
    // Update progress in DB when quiz is completed
    Future.microtask(() async {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final db = DatabaseFactory.getDatabaseService();
      if (userId != null) {
        await db.updateProgress(userId, '${widget.moduleName}_quiz', 1.0);
      }
    });
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 70 ? Icons.celebration : Icons.sentiment_satisfied,
            size: 100,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Complete!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score: $_score/${_questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.round()}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text('Return to Module'),
          ),
        ],
      ),
    );
  }
}
