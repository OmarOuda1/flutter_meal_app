import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Toggle between light and dark mode'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Recipe Source'),
            subtitle: const Text('Select the API to fetch recipes from'),
            trailing: DropdownButton<String>(
              value: settings.apiSource,
              items: const [
                DropdownMenuItem(
                  value: 'themealdb',
                  child: Text('TheMealDB (Free)'),
                ),
                DropdownMenuItem(
                  value: 'dummyjson',
                  child: Text('DummyJSON (Free)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setApiSource(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Credits'),
            subtitle: const Text('View open source credits and APIs used'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showCredits(context),
          ),
        ],
      ),
    );
  }

  void _showCredits(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Credits'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<String>(
              future: rootBundle.loadString('assets/credits.md'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error loading credits: \${snapshot.error}');
                }
                return Markdown(data: snapshot.data ?? 'No credits found.');
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
