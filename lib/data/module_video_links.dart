/// Centralized storage for all YouTube video links for modules and steps.
/// Each value is a YouTube video ID (not the full URL).
/// Example usage: 'RwKZTvBH7JM'
library;

class ModuleVideoLinks {
  // Format: [moduleTitle][stepIndex] = videoId
  static const Map<String, List<String?>> videoLinks = {
    // Basic Smartphone Usage
    'Basic Smartphone Usage': [
      'RNN5oYmeUNM', // Introduction
      '1JZG9x_VOwA', // Basic Concepts
      '5LetLwpsiW0', // Practical Exercise
      '_e_BOkIsmJI', // Quiz
    ],
    // Internet Navigation
    'Internet Navigation': [
      'F4fbwKV9dBU', // Introduction
      'x3c1ih2NJEg', // Basic Concepts
      'UXsomnDkntI', // Practical Exercise
      '_aKJaVDUgag', // Quiz
    ],
    // Digital Payments
    'Digital Payments': [
      'c4O4jWw5d8I', // Introduction
      '2ugB_KI7ZR8', // Basic Concepts
      '229QbEiFKj8', // Practical Exercise
      'o94rq8fK-fw', // Quiz
    ],
    // Government Services
    'Government Services': [
      'u8d4f1QbzjM', // Introduction
      'jm1s2-Ssnmw', // Basic Concepts
      'aUop8RpBqPw', // Practical Exercise
      'QvntNVtU8qk', // Quiz
    ],
  };

  /// Get the videoId for a given module and step index
  static String? getVideoId(String moduleTitle, int stepIndex) {
    return videoLinks[moduleTitle]?[stepIndex];
  }
}
