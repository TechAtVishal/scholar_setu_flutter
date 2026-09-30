import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../data/schemes_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProv = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Language & Region', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
            child: Column(children: kLanguages.map((l) {
              final active = langProv.languageCode == l['code'];
              return ListTile(
                title: Text(l['native']!, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                subtitle: Text(l['label']!),
                trailing: active ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                onTap: () {
                  langProv.setLanguage(l['code']!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language changed to ${l["native"]}')));
                },
              );
            }).toList()),
          ),
          const SizedBox(height: 24),
          const Text('Accessibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
            child: Column(children: [
              SwitchListTile(
                title: const Text('High Contrast Text'),
                value: false,
                onChanged: (v) {},
                activeColor: AppTheme.primary,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Screen Reader Optimization'),
                value: true,
                onChanged: (v) {},
                activeColor: AppTheme.primary,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
            child: const Column(children: [
              ListTile(title: Text('App Version'), trailing: Text('1.0.0 (SIH 2026)')),
              Divider(height: 1),
              ListTile(title: Text('Privacy Policy'), trailing: Icon(Icons.chevron_right)),
              Divider(height: 1),
              ListTile(title: Text('Terms of Service'), trailing: Icon(Icons.chevron_right)),
            ]),
          ),
          const SizedBox(height: 40),
          const Center(child: Text('Ministry of Tribal Affairs', style: TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w600))),
          const Center(child: Text('Made by Team CipherGuard', style: TextStyle(color: AppTheme.textHint))),
        ],
      ),
    );
  }
}
