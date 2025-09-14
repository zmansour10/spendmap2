import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../domain/entities/settings_entity.dart';
import '../providers/settings_provider.dart';

class DataManagementPanel extends ConsumerWidget {
  final SettingsEntity settings;

  const DataManagementPanel({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Auto backup'),
            subtitle: Text('Backup every ${settings.backupFrequencyDays} days'),
            trailing: Switch(
              value: settings.autoBackup,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAutoBackup(value);
              },
            ),
          ),
          if (settings.lastBackupDate != null)
            ListTile(
              title: const Text('Last backup'),
              subtitle: Text(_formatDate(settings.lastBackupDate!)),
              leading: const Icon(Icons.history),
            ),
          const Divider(),
          ListTile(
            title: const Text('Export data'),
            subtitle: const Text('Export all expenses and settings'),
            leading: const Icon(Icons.download),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportOptions(context, ref),
          ),
          ListTile(
            title: const Text('Import data'),
            subtitle: const Text('Import from backup file'),
            leading: const Icon(Icons.upload),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImportDialog(context, ref),
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear all data'),
            subtitle: const Text('Delete all expenses and reset settings'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format for expenses only'),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, ref, 'csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              subtitle: const Text('Complete backup including settings'),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, ref, 'json');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, String format) async {
    try {
      final exportResult = await ref.read(exportSettingsProvider.future);

      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

      String filename;
      String content;

      if (format == 'csv') {
        filename = 'spendmap_expenses_$timestamp.csv';
        content = _convertToCSV(exportResult);
      } else {
        filename = 'spendmap_backup_$timestamp.json';
        content = const JsonEncoder.withIndent('  ').convert(exportResult);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to Documents/$filename'),
            action: SnackBarAction(
              label: 'Show Path',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(file.path)),
                );
              },
            ),
          ),
        );
      }

      // Update backup date
      ref.read(settingsProvider.notifier).updateBackupDate();

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Date,Amount,Category,Description,Currency');

    // Extract expenses from the data (assuming they're in the export)
    final expenses = data['expenses'] as List<dynamic>? ?? [];

    for (final expense in expenses) {
      final date = expense['date'] ?? '';
      final amount = expense['amount'] ?? 0;
      final category = expense['category'] ?? 'Unknown';
      final description = expense['description'] ?? '';
      final currency = data['settings']?['currency'] ?? 'USD';

      buffer.writeln('$date,$amount,"$category","$description",$currency');
    }

    return buffer.toString();
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Select a backup file to import. This will overwrite your current data. Make sure to create a backup first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importData(context, ref);
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;

        final importProvider = ref.read(importSettingsProvider.notifier);
        final success = await importProvider.importSettingsData(data);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import failed. Please check the file format.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your expenses and reset all settings to defaults. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('Type "DELETE" to confirm data deletion:'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  // Clear all data (this would need to be implemented in the repository)
                  await ref.read(settingsProvider.notifier).resetSettings();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to clear data: $e')),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}