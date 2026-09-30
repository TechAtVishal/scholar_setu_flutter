import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final apps = context.watch<AppProvider>().applications.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: apps.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.description_outlined, size: 72, color: AppTheme.textHint),
              const SizedBox(height: 12),
              const Text('No Applications Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textHint)),
              const SizedBox(height: 8),
              const Text('Apply for a scholarship to track status here', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (_, i) {
                final app = apps[i];
                final si = StatusHelper.get(app.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/application-detail', extra: app),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: (si['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                            child: Icon(si['icon'] as IconData, color: si['color'] as Color, size: 24)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(app.applicationId, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'monospace')),
                            const SizedBox(height: 2),
                            Text(app.schemeName, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Submitted: ${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          ])),
                          const Icon(Icons.chevron_right, color: AppTheme.textHint),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: (si['color'] as Color).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: si['color'] as Color, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(si['label'] as String, style: TextStyle(color: si['color'] as Color, fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
