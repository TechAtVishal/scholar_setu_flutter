import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';
import '../data/schemes_data.dart';
import '../utils/app_theme.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});
  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String _selected = 'en';

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.language, size: 36, color: Colors.white),
                const SizedBox(height: 10),
                const Text('Select Your Language', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Your language. Your scholarship.', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 2.3, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: kLanguages.length,
              itemBuilder: (_, i) {
                final lang = kLanguages[i];
                final isSelected = _selected == lang['code'];
                return GestureDetector(
                  onTap: () => setState(() => _selected = lang['code']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFFE0E0E0), width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lang['native']!, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                              Text(lang['label']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await langProvider.setLanguage(_selected);
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Continue  →'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
