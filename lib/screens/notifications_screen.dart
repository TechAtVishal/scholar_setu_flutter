import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

const _demoNotifs = [
  {'id': 'n1', 'type': 'deadline', 'icon': '\u23f0', 'title': 'Deadline Approaching!', 'body': 'Pre-Matric Scholarship deadline is in 5 days. Submit your application now.', 'minsAgo': 60, 'read': false},
  {'id': 'n2', 'type': 'status', 'icon': '\ud83d\udccb', 'title': 'Application Update', 'body': 'Your application has been moved to Under Review.', 'minsAgo': 1440, 'read': false},
  {'id': 'n3', 'type': 'payment', 'icon': '\ud83d\udcb0', 'title': 'Renewal Reminder', 'body': 'Your Post Matric scholarship is due for renewal. Complete by Oct 31.', 'minsAgo': 2880, 'read': true},
  {'id': 'n4', 'type': 'document', 'icon': '\ud83d\udcc4', 'title': 'Document Verified', 'body': 'Your Aadhaar card has been successfully verified via eKYC.', 'minsAgo': 4320, 'read': true},
];

String _timeAgo(int minsAgo) {
  if (minsAgo < 60) return '${minsAgo}m ago';
  if (minsAgo < 1440) return '${minsAgo ~/ 60}h ago';
  return '${minsAgo ~/ 1440}d ago';
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final all = [
      ..._demoNotifs.map((n) => {...n, 'isDemo': true}),
      ...prov.notifications.map((n) => {...n, 'isDemo': false}),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: all.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.textHint),
              SizedBox(height: 12),
              Text('No notifications yet', style: TextStyle(color: AppTheme.textHint, fontSize: 16)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: all.length,
              itemBuilder: (_, i) {
                final n = all[i];
                final unread = n['read'] != true;
                return GestureDetector(
                  onTap: () { if (!(n['isDemo'] as bool)) prov.markNotificationRead(n['id'] as String); },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: unread ? AppTheme.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: unread ? AppTheme.primary.withOpacity(0.25) : const Color(0xFFF0F0F0)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(n['icon'] as String, style: const TextStyle(fontSize: 22)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(n['title'] as String, style: TextStyle(fontSize: 14, fontWeight: unread ? FontWeight.w700 : FontWeight.w500, color: AppTheme.textPrimary))),
                          Text(_timeAgo(n['minsAgo'] as int? ?? 0), style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        ]),
                        const SizedBox(height: 4),
                        Text(n['body'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
                      ])),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                      ],
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
