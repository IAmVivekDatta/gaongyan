/// Centralized storage for all YouTube video links for modules and steps.
/// Each value is a YouTube video ID (not the full URL).
/// Example usage: 'RwKZTvBH7JM'
library;

class ModuleVideoLinks {
  // Format: [moduleTitle][stepIndex] = videoId
  static const Map<String, List<String?>> videoLinks = {
    // Basic Smartphone Usage
    'Basic Smartphone Usage': [
      'RNN5oYmeUNM', // Introduction done
      'czFq3XuMsAM', // Basic Concepts done
      'Z0RftGxQniI', // Practical Exercise done
      'ZicmcHHtAhU', // Quiz
    ],
    // Internet Navigation
    'Internet Navigation': [
      'T6exB49AgD8', // Introduction
      'CmMTIxHqtQQ', // Basic Concepts
      'Z6TPUZlv_98', // Practical Exercise
      '3BLiGrfeUeI', // Quiz
    ],
    // Digital Payments
    'Digital Payments': [
      'EPyNSrs-7q4', // Introduction
      'KKxFxE2wMqY', // Basic Concepts
      '4NP0UPvH4Ys', // Practical Exercise
      'V0e3WNma1QM', // Quiz
    ],
    // Government Services
    'Government Services': [
      'O0fGmbcxFzo', // Introduction
      'jm1s2-Ssnmw', // Basic Concepts
      'aUop8RpBqPw', // Practical Exercise
      'feROJYQKDeM', // Quiz
    ],
  };

  /// Get the videoId for a given module and step index
  static String? getVideoId(String moduleTitle, int stepIndex) {
    return videoLinks[moduleTitle]?[stepIndex];
  }
}
