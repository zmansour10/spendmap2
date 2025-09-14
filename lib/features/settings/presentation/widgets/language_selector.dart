import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
    {
      'code': 'de',
      'name': 'German',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
    },
    {
      'code': 'fr',
      'name': 'French',
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },
    {
      'code': 'it',
      'name': 'Italian',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
    },
    {
      'code': 'pt',
      'name': 'Portuguese',
      'nativeName': 'Português',
      'flag': '🇵🇹',
    },
    {
      'code': 'ru',
      'name': 'Russian',
      'nativeName': 'Русский',
      'flag': '🇷🇺',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'nativeName': '日本語',
      'flag': '🇯🇵',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'nativeName': '한국어',
      'flag': '🇰🇷',
    },
    {
      'code': 'zh',
      'name': 'Chinese (Simplified)',
      'nativeName': '简体中文',
      'flag': '🇨🇳',
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'nativeName': 'हिन्दी',
      'flag': '🇮🇳',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = supportedLanguages.firstWhere(
      (language) => language['code'] == currentLanguage,
      orElse: () => supportedLanguages.first,
    );

    return ListTile(
      title: const Text('Language'),
      subtitle: Text('${selectedLanguage['nativeName']} (${selectedLanguage['name']})'),
      leading: Text(
        selectedLanguage['flag']!,
        style: const TextStyle(fontSize: 24),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguagePicker(context),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = supportedLanguages[index];
                    final isSelected = language['code'] == currentLanguage;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            language['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        language['nativeName']!,
                        style: isSelected
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                      ),
                      subtitle: Text(language['name']!),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        onLanguageChanged(language['code']!);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'App restart may be required for language changes to take full effect.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String getLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (language) => language['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['name']!;
  }

  static String getLanguageNativeName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (language) => language['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['nativeName']!;
  }

  static String getLanguageFlag(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (language) => language['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['flag']!;
  }
}