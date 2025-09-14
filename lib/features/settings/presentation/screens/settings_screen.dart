import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../widgets/currency_selector.dart';
import '../widgets/theme_selector.dart';
import '../widgets/language_selector.dart';
import '../widgets/data_management_panel.dart';
import '../../domain/entities/settings_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../categories/domain/entities/category_entity.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // App Preferences Section
            _buildSectionHeader(context, 'App Preferences'),
            _buildSettingsCard(
              context,
              children: [
                CurrencySelector(
                  currentCurrency: settings.currency,
                  onCurrencyChanged: (currency) {
                    ref.read(settingsProvider.notifier).setCurrency(currency);
                  },
                ),
                const Divider(),
                LanguageSelector(
                  currentLanguage: settings.language,
                  onLanguageChanged: (language) {
                    ref.read(settingsProvider.notifier).setLanguage(language);
                  },
                ),
                const Divider(),
                ThemeSelector(
                  currentTheme: settings.themeMode.name,
                  onThemeChanged: (theme) {
                    ref.read(settingsProvider.notifier).setThemeMode(theme);
                  },
                ),
                const Divider(),
                _buildDefaultCategoryTile(context, ref, settings, categoriesAsync),
              ],
            ),

            const SizedBox(height: 24),

            // Display Settings Section
            _buildSectionHeader(context, 'Display Settings'),
            _buildSettingsCard(
              context,
              children: [
                SwitchListTile(
                  title: const Text('Show cents in amounts'),
                  subtitle: const Text('Display amounts with decimal places'),
                  value: settings.showCentsInAmounts,
                  onChanged: (value) {
                    final updatedSettings = settings.copyWith(
                      showCentsInAmounts: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  },
                ),
                SwitchListTile(
                  title: const Text('Compact expense view'),
                  subtitle: const Text('Use compact layout for expense lists'),
                  value: settings.useCompactExpenseView,
                  onChanged: (value) {
                    final updatedSettings = settings.copyWith(
                      useCompactExpenseView: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  },
                ),
                SwitchListTile(
                  title: const Text('Show expense categories'),
                  subtitle: const Text('Display category labels in expense lists'),
                  value: settings.showExpenseCategories,
                  onChanged: (value) {
                    final updatedSettings = settings.copyWith(
                      showExpenseCategories: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(context, 'Notifications'),
            _buildSettingsCard(
              context,
              children: [
                SwitchListTile(
                  title: const Text('Enable notifications'),
                  subtitle: const Text('Receive app notifications'),
                  value: settings.enableNotifications,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Daily spending reminders'),
                  subtitle: const Text('Get reminded to track daily expenses'),
                  value: settings.dailySpendingReminders,
                  onChanged: settings.enableNotifications ? (value) {
                    final updatedSettings = settings.copyWith(
                      dailySpendingReminders: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  } : null,
                ),
                SwitchListTile(
                  title: const Text('Budget alerts'),
                  subtitle: const Text('Get notified when approaching budget limits'),
                  value: settings.budgetAlerts,
                  onChanged: settings.enableNotifications ? (value) {
                    final updatedSettings = settings.copyWith(
                      budgetAlerts: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  } : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSectionHeader(context, 'Privacy & Security'),
            _buildSettingsCard(
              context,
              children: [
                SwitchListTile(
                  title: const Text('Require biometric authentication'),
                  subtitle: const Text('Use fingerprint or face unlock'),
                  value: settings.requireBiometrics,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setBiometricsRequired(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Hide amounts in recents'),
                  subtitle: const Text('Hide expense amounts in app switcher'),
                  value: settings.hideAmountsInRecents,
                  onChanged: (value) {
                    final updatedSettings = settings.copyWith(
                      hideAmountsInRecents: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader(context, 'Data Management'),
            DataManagementPanel(settings: settings),

            const SizedBox(height: 24),

            // Advanced Settings Section
            _buildSectionHeader(context, 'Advanced'),
            _buildSettingsCard(
              context,
              children: [
                SwitchListTile(
                  title: const Text('Confirm before deleting'),
                  subtitle: const Text('Ask for confirmation when deleting expenses'),
                  value: settings.confirmBeforeDelete,
                  onChanged: (value) {
                    final updatedSettings = settings.copyWith(
                      confirmBeforeDelete: value,
                    );
                    ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
                  },
                ),
                ListTile(
                  title: const Text('Reset all settings'),
                  subtitle: const Text('Restore default settings (cannot be undone)'),
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  onTap: () => _showResetDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Info Section
            _buildSectionHeader(context, 'About'),
            _buildSettingsCard(
              context,
              children: [
                ListTile(
                  title: const Text('App Version'),
                  subtitle: Text(settings.appVersion),
                  leading: const Icon(Icons.info_outline),
                ),
                ListTile(
                  title: const Text('Created'),
                  subtitle: Text(_formatDate(settings.createdAt)),
                  leading: const Icon(Icons.calendar_today),
                ),
                ListTile(
                  title: const Text('Last Updated'),
                  subtitle: Text(_formatDate(settings.updatedAt)),
                  leading: const Icon(Icons.update),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDefaultCategoryTile(
    BuildContext context,
    WidgetRef ref,
    SettingsEntity settings,
    AsyncValue categoriesAsync,
  ) {
    return categoriesAsync.when(
      loading: () => const ListTile(
        title: Text('Default category'),
        subtitle: Text('Loading categories...'),
        leading: Icon(Icons.category),
        trailing: CircularProgressIndicator(),
      ),
      error: (error, _) => ListTile(
        title: const Text('Default category'),
        subtitle: Text('Error loading categories: $error'),
        leading: const Icon(Icons.category),
        trailing: const Icon(Icons.error, color: Colors.red),
      ),
      data: (categories) {
        CategoryEntity? defaultCategory;

        if (categories.isNotEmpty) {
          try {
            defaultCategory = categories.firstWhere(
              (cat) => cat.id == settings.defaultCategoryId,
            );
          } catch (e) {
            // Category not found, use first category or null
            defaultCategory = categories.isNotEmpty ? categories.first : null;
          }
        }

        return ListTile(
          title: const Text('Default category'),
          subtitle: Text(settings.defaultCategoryId != null && defaultCategory != null
            ? defaultCategory.name
            : 'None selected'),
          leading: settings.defaultCategoryId != null && defaultCategory != null
            ? Icon(
                defaultCategory.icon,
                color: defaultCategory.color,
              )
            : const Icon(Icons.category),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCategorySelector(context, ref, categories, settings.defaultCategoryId),
        );
      },
    );
  }

  void _showCategorySelector(
    BuildContext context,
    WidgetRef ref,
    List categories,
    int? currentCategoryId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Default Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.not_interested),
              title: const Text('None'),
              trailing: currentCategoryId == null
                ? const Icon(Icons.check, color: Colors.green)
                : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setDefaultCategory(null);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...categories.map((category) => ListTile(
              leading: Icon(
                category.icon,
                color: category.color,
              ),
              title: Text(category.name),
              trailing: currentCategoryId == category.id
                ? const Icon(Icons.check, color: Colors.green)
                : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setDefaultCategory(category.id);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(settingsProvider.notifier).resetSettings();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resetting settings: $e')),
                  );
                }
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}