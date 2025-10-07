import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Gaon Gyaan',
      'welcomeBack': 'Welcome Back!',
      'continueJourney': 'Continue your digital learning journey',
      'learningModules': 'Learning Modules',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'help': 'Help',
      'progress': 'Progress',
    },
    'te': {
      'appTitle': 'గ్రామ జ్ఞాన్',
      'welcomeBack': 'తిరిగి స్వాగతం!',
      'continueJourney': 'మీ డిజిటల్ అభ్యాస ప్రయాణాన్ని కొనసాగించండి',
      'learningModules': 'అభ్యాస మాడ్యూల్స్',
      'profile': 'ప్రొఫైల్',
      'settings': 'సెట్టింగ్స్',
      'language': 'భాష',
      'help': 'సహాయం',
      'progress': 'పురోగతి',
    },
    'hi': {
      'appTitle': 'गांव ज्ञान',
      'welcomeBack': 'वापसी पर स्वागत है!',
      'continueJourney': 'अपनी डिजिटल सीखने की यात्रा जारी रखें',
      'learningModules': 'सीखने के मॉड्यूल',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'help': 'मदद',
      'progress': 'प्रगति',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack']!;
  String get continueJourney => _localizedValues[locale.languageCode]!['continueJourney']!;
  String get learningModules => _localizedValues[locale.languageCode]!['learningModules']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get help => _localizedValues[locale.languageCode]!['help']!;
  String get progress => _localizedValues[locale.languageCode]!['progress']!;
}
