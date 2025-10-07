import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English'; // Default to English
  bool _voiceGuidanceEnabled = true;
  bool _notificationsEnabled = true;
  double _textSize = 1.0;

  final Map<String, String> _languages = {
    'English': 'en',
    'తెలుగు': 'te',
    'हिंदी': 'hi',
  };

  final Map<String, String> _languageCodes = {
    'en': 'English',
    'te': 'తెలుగు',
    'hi': 'हिंदी',
  };

  @override
  void initState() {
    super.initState();
    // Initialize language selection from UserProvider
    final userProvider = context.read<UserProvider>();
    _selectedLanguage = _languageCodes[userProvider.preferredLanguage] ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message('Settings', name: 'settings')),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          _buildSection(
            Intl.message('Language & Text', name: 'languageText'),
            [
              ListTile(
                title: Text(Intl.message('Select Language', name: 'selectLanguage')),
                subtitle: Text(_selectedLanguage),
                leading: const Icon(Icons.language, color: Colors.indigo),
                onTap: _showLanguageDialog,
              ),
              ListTile(
                title: Text(Intl.message('Text Size', name: 'textSize')),
                subtitle: Slider(
                  value: _textSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 3,
                  label: _getTextSizeLabel(),
                  activeColor: Colors.indigo,
                  onChanged: (value) {
                    setState(() {
                      _textSize = value;
                    });
                  },
                ),
                leading: const Icon(Icons.text_fields, color: Colors.indigo),
              ),
            ],
          ),
          _buildSection(
            Intl.message('Accessibility', name: 'accessibility'),
            [
              SwitchListTile(
                title: Text(Intl.message('Voice Guidance', name: 'voiceGuidance')),
                subtitle: Text(Intl.message('Audio instructions for navigation', name: 'audioInstructions')),
                secondary: const Icon(Icons.record_voice_over, color: Colors.indigo),
                value: _voiceGuidanceEnabled,
                activeThumbColor: Colors.indigo,
                onChanged: (bool value) {
                  setState(() {
                    _voiceGuidanceEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(Intl.message('Notifications', name: 'notifications')),
                subtitle: Text(Intl.message('Reminders and updates', name: 'remindersUpdates')),
                secondary: const Icon(Icons.notifications, color: Colors.indigo),
                value: _notificationsEnabled,
                activeThumbColor: Colors.indigo,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            'Storage',
            [
              ListTile(
                title: const Text('Download Learning Content'),
                subtitle: const Text('Save modules for offline use'),
                leading: const Icon(Icons.download, color: Colors.indigo),
                onTap: () {
                  // TODO: Implement content download
                },
              ),
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up space'),
                leading: const Icon(Icons.cleaning_services, color: Colors.indigo),
                onTap: () {
                  // TODO: Implement cache clearing
                },
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info, color: Colors.indigo),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description, color: Colors.indigo),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip, color: Colors.indigo),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  String _getTextSizeLabel() {
    if (_textSize <= 0.8) return 'Small';
    if (_textSize <= 1.0) return 'Normal';
    if (_textSize <= 1.2) return 'Large';
    return 'Extra Large';
  }



  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.key),
                value: entry.key,
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                    final userProvider = context.read<UserProvider>();
                    userProvider.updatePreferredLanguage(_languages[value]!);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
