import 'package:flutter_tts/flutter_tts.dart';

// Voice quality settings
enum VoiceQuality {
  standard,
  enhanced,
  premium,
  neural
}

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Default to Telugu for the primary experience
    await _flutterTts.setLanguage("te-IN");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  final Map<String, String> _languageCodes = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'te': 'te-IN',
  };

  Future<void> speak(String text, {String language = "te"}) async {
    await init();
    final languageCode = _languageCodes[language] ?? "te-IN";
    await _flutterTts.setLanguage(languageCode);
    // Reduce speech rate for clarity in Telugu
    if (languageCode == 'te-IN') {
      await _flutterTts.setSpeechRate(0.4);
    } else {
      await _flutterTts.setSpeechRate(0.5);
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<List<String>> getLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return languages.cast<String>();
  }

  // ============== PREMIUM VOICE ENHANCEMENTS ==============

  // Premium voice configurations for different languages
  final Map<String, List<String>> _premiumVoices = {
    'en-US': [
      'com.apple.ttsbundle.Samantha-compact', // Neural voice
      'com.apple.ttsbundle.Alex-compact',
      'com.apple.voice.compact.en-US.Zoe',
      'Microsoft Aria Online (Natural) - English (United States)',
      'Microsoft Jenny Online (Natural) - English (United States)',
      'Microsoft Guy Online (Natural) - English (United States)',
    ],
    'hi-IN': [
      'com.apple.voice.compact.hi-IN.Lekha',
      'Microsoft Swara Online (Natural) - Hindi (India)',
      'Microsoft Madhur Online (Natural) - Hindi (India)',
    ],
    'te-IN': [
      'com.apple.voice.compact.te-IN.Shruti',
      'Microsoft Shruti Online (Natural) - Telugu (India)',
    ],
  };

  VoiceQuality _currentQuality = VoiceQuality.premium;
  String? _currentVoice;

  /// Set premium voice quality
  Future<void> setVoiceQuality(VoiceQuality quality) async {
    await init();
    _currentQuality = quality;
    
    // Apply quality-specific settings
    switch (quality) {
      case VoiceQuality.standard:
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
        break;
      case VoiceQuality.enhanced:
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setPitch(0.95);
        break;
      case VoiceQuality.premium:
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(0.9);
        await _configurePremiumSettings();
        break;
      case VoiceQuality.neural:
        await _flutterTts.setSpeechRate(0.35);
        await _flutterTts.setPitch(0.85);
        await _configurePremiumSettings();
        break;
    }
  }

  /// Configure premium-specific settings
  Future<void> _configurePremiumSettings() async {
    try {
      // Enable shared timeline for smoother speech
      await _flutterTts.awaitSpeakCompletion(true);
      
      // Set audio session category for better quality (iOS)
      await _flutterTts.setSharedInstance(true);
      
      // Configure queue mode for continuous speech
      await _flutterTts.setQueueMode(1);
      
    } catch (e) {
  // print('Premium settings configuration failed: $e'); // Use logging in production
    }
  }

  /// Get available premium voices for a language
  Future<List<String>> getPremiumVoices({String? languageCode}) async {
    await init();
    
    try {
      final allVoices = await _flutterTts.getVoices;
      final availableVoices = <String>[];
      
      for (var voice in allVoices) {
        final voiceName = voice['name'] as String?;
        final voiceLocale = voice['locale'] as String?;
        
        if (voiceName != null) {
          if (languageCode == null || voiceLocale == languageCode) {
            // Check if it's a premium voice
            final premiumVoicesForLang = _premiumVoices[voiceLocale] ?? [];
            if (premiumVoicesForLang.contains(voiceName) || 
                voiceName.toLowerCase().contains('neural') ||
                voiceName.toLowerCase().contains('premium') ||
                voiceName.toLowerCase().contains('enhanced')) {
              availableVoices.add(voiceName);
            }
          }
        }
      }
      
      return availableVoices;
    } catch (e) {
  // print('Error getting premium voices: $e'); // Use logging in production
      return [];
    }
  }

  /// Set specific premium voice
  Future<bool> setPremiumVoice(String voiceName, {String? languageCode}) async {
    await init();
    
    try {
      if (languageCode != null) {
        await _flutterTts.setLanguage(languageCode);
      }
      
      await _flutterTts.setVoice({"name": voiceName, "locale": languageCode ?? "en-US"});
      _currentVoice = voiceName;
      return true;
    } catch (e) {
  // print('Error setting premium voice: $e'); // Use logging in production
      return false;
    }
  }

  /// Get best available premium voice for language
  Future<String?> getBestPremiumVoice(String languageCode) async {
    final premiumVoices = await getPremiumVoices(languageCode: languageCode);
    
    if (premiumVoices.isNotEmpty) {
      // Prioritize neural voices
      for (final voice in premiumVoices) {
        if (voice.toLowerCase().contains('neural') || 
            voice.toLowerCase().contains('online')) {
          return voice;
        }
      }
      // Return first available premium voice
      return premiumVoices.first;
    }
    
    return null;
  }

  /// Enhanced speak function with premium voice support
  Future<void> speakPremium(
    String text, {
    String language = "en",
    VoiceQuality quality = VoiceQuality.premium,
    String? customVoice,
    double? customRate,
    double? customPitch,
  }) async {
    await init();
    
    final languageCode = _languageCodes[language] ?? "en-US";
    await _flutterTts.setLanguage(languageCode);
    
    // Set custom voice or get best premium voice
    if (customVoice != null) {
      await setPremiumVoice(customVoice, languageCode: languageCode);
    } else {
      final bestVoice = await getBestPremiumVoice(languageCode);
      if (bestVoice != null) {
        await setPremiumVoice(bestVoice, languageCode: languageCode);
      }
    }
    
    // Apply quality settings
    await setVoiceQuality(quality);
    
    // Apply custom settings if provided
    if (customRate != null) {
      await _flutterTts.setSpeechRate(customRate);
    }
    if (customPitch != null) {
      await _flutterTts.setPitch(customPitch);
    }
    
    // Speak with premium quality
    await _flutterTts.speak(text);
  }

  /// Get current voice information
  Future<Map<String, dynamic>?> getCurrentVoiceInfo() async {
    try {
      return await _flutterTts.getDefaultVoice;
    } catch (e) {
  // print('Error getting current voice info: $e'); // Use logging in production
      return null;
    }
  }

  /// Check if premium voices are available
  Future<bool> arePremiumVoicesAvailable() async {
    final premiumVoices = await getPremiumVoices();
    return premiumVoices.isNotEmpty;
  }

  /// Get voice quality as string
  String get currentQualityName => switch (_currentQuality) {
    VoiceQuality.standard => 'Standard',
    VoiceQuality.enhanced => 'Enhanced',
    VoiceQuality.premium => 'Premium',
    VoiceQuality.neural => 'Neural',
  };

  /// Get current voice name
  String? get currentVoiceName => _currentVoice;

  /// Reset to default voice
  Future<void> resetToDefaultVoice() async {
    await init();
    _currentVoice = null;
    _currentQuality = VoiceQuality.premium;
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
}