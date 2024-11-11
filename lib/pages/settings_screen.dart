import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pockettracer/services/theme_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:pockettracer/vo/balance.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  String _currency = 'USD';
  final Balance _balance = Balance();

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            'Appearance',
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark/light theme'),
                value: themeService.isDarkMode,
                onChanged: (bool value) {
                  themeService.toggleDarkMode();
                },
              ),
            ],
          ),
          _buildSection(
            'Regional',
            [
              ListTile(
                title: const Text('Currency'),
                subtitle: Text(_currency),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showCurrencyPicker,
              ),
            ],
          ),
          _buildSection(
            'Account',
            [
              ListTile(
                title: const Text('Export Data'),
                leading: const Icon(Icons.download),
                onTap: () => _showExportDialog(context),
              ),
              ListTile(
                title: const Text('Clear All Data'),
                leading: const Icon(Icons.delete_forever),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: _showClearDataDialog,
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportDataAsJson();
              },
              child: const Text('JSON'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportDataAsCsv();
              },
              child: const Text('CSV'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportDataAsJson() async {
    try {
      final transactions = _balance.transactions;
      final data = transactions.map((t) => t.toJson()).toList();
      final jsonData = jsonEncode(data);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save JSON File',
        fileName:
            'pockettracer_export_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile == null) {
        return;
      }

      final file = File(outputFile);
      await file.writeAsString(jsonData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to $outputFile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    }
  }

  Future<void> _exportDataAsCsv() async {
    try {
      final transactions = _balance.transactions;
      final csvData = StringBuffer();

      csvData.writeln('Date,Title,Amount,Category,Type');

      for (var transaction in transactions) {
        csvData.writeln('${transaction.date.toIso8601String()},'
            '"${transaction.title}",'
            '${transaction.amount},'
            '"${transaction.category}",'
            '${transaction.isExpense ? "Expense" : "Income"}');
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV File',
        fileName:
            'pockettracer_export_${DateTime.now().millisecondsSinceEpoch}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile == null) {
        return;
      }

      final file = File(outputFile);
      await file.writeAsString(csvData.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to $outputFile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    }
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD - US Dollar'),
              onTap: () {
                setState(() {
                  _currency = 'USD';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('EUR - Euro'),
              onTap: () {
                setState(() {
                  _currency = 'EUR';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('GBP - British Pound'),
              onTap: () {
                setState(() {
                  _currency = 'GBP';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
              'Are you sure you want to clear all data? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _clearAllData();
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    await _balance.clearAllData();

    setState(() {
      _notifications = true;
      _currency = 'USD';
    });
  }
}
