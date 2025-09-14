import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  static const List<Map<String, dynamic>> themeOptions = [
    {
      'value': 'system',
      'name': 'System',
      'description': 'Follow device setting',
      'icon': Icons.brightness_auto,
    },
    {
      'value': 'light',
      'name': 'Light',
      'description': 'Always use light theme',
      'icon': Icons.light_mode,
    },
    {
      'value': 'dark',
      'name': 'Dark',
      'description': 'Always use dark theme',
      'icon': Icons.dark_mode,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTheme = themeOptions.firstWhere(
      (theme) => theme['value'] == currentTheme,
      orElse: () => themeOptions.first,
    );

    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(selectedTheme['description']),
      leading: Icon(selectedTheme['icon'] as IconData),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemePicker(context),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Select Theme',
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
            ...themeOptions.map((theme) {
              final isSelected = theme['value'] == currentTheme;

              return ListTile(
                leading: Icon(
                  theme['icon'] as IconData,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  theme['name'],
                  style: isSelected
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
                subtitle: Text(theme['description']),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onThemeChanged(theme['value']);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static String getThemeName(String themeValue) {
    final theme = themeOptions.firstWhere(
      (theme) => theme['value'] == themeValue,
      orElse: () => themeOptions.first,
    );
    return theme['name'];
  }

  static IconData getThemeIcon(String themeValue) {
    final theme = themeOptions.firstWhere(
      (theme) => theme['value'] == themeValue,
      orElse: () => themeOptions.first,
    );
    return theme['icon'] as IconData;
  }
}