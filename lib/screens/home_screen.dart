import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';
import '../data/schemes_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final profile = prov.profile;
    final eligibility = EligibilityEngine.check(profile, kSchemes);
    final eligibleCount = eligibility.where((e) => e.eligible).length;
    final pending = prov.pendingApplications;

    final quickActions = [
      {'icon': Icons.search, 'label': 'Eligibility', 'color': const Color(0xFF9C27B0), 'route': '/eligibility'},
      {'icon': Icons.folder_open, 'label': 'Documents', 'color': const Color(0xFF2196F3), 'route': '/documents'},
      {'icon': Icons.chat_bubble_outline, 'label': 'ScholarBot', 'color': const Color(0xFF4CAF50), 'route': '/chatbot'},
      {'icon': Icons.report_problem_outlined, 'label': 'Grievance', 'color': const Color(0xFFFF5722), 'route': '/grievance'},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            title: const Text('ScholarSetu'),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (prov.unreadNotifications > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 1.5)),
                        child: Center(
                          child: Text('${prov.unreadNotifications}', style: const TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(), style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                    Text(profile.fullName.isEmpty ? 'Student 👋' : '${profile.fullName} 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatCard(value: '$eligibleCount', label: 'Eligible'),
                        const SizedBox(width: 8),
                        _StatCard(value: '${pending.length}', label: 'Active'),
                        const SizedBox(width: 8),
                        _StatCard(value: '${prov.applications.where((a) => a.status == "disbursed").length}', label: 'Paid'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prov.offlineQueue.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('${prov.offlineQueue.length} items pending sync', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: quickActions.length,
                    itemBuilder: (_, i) {
                      final a = quickActions[i];
                      return GestureDetector(
                        onTap: () => context.push(a['route'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: (a['color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14)),
                                child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24)),
                              const SizedBox(width: 10),
                              Text(a['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Eligible Scholarships', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      TextButton(onPressed: () => context.go('/schemes'), child: const Text('View All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (eligibleCount == 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          const Icon(Icons.person_outline, size: 48, color: AppTheme.textHint),
                          const SizedBox(height: 8),
                          const Text('Complete your profile to see eligible schemes', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: () => context.go('/profile'), child: const Text('Complete Profile')),
                        ],
                      ),
                    )
                  else
                    ...eligibility.where((e) => e.eligible).take(3).map((e) => _SchemeCard(e: e)).toList(),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Applications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        TextButton(onPressed: () => context.go('/track'), child: const Text('View All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...pending.take(2).map((app) {
                      final si = StatusHelper.get(app.status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () => context.push('/application-detail', extra: app),
                          title: Text(app.schemeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text(app.applicationId, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (si['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(si['label'] as String, style: TextStyle(color: si['color'] as Color, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.push('/officer'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)]),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, color: AppTheme.success, size: 26),
                          SizedBox(width: 12),
                          Expanded(child: Text('Officer / Nodal Verifier Login', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Icon(Icons.chevron_right, color: AppTheme.textHint),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final dynamic e;
  const _SchemeCard({required this.e});
  @override
  Widget build(BuildContext context) {
    final scheme = e.scheme;
    final ds = DeadlineHelper.getStatus(scheme.deadline);
    return GestureDetector(
      onTap: () => context.push('/scheme-detail', extra: scheme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Color(scheme.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(scheme.icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme.shortName, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(scheme.amount, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: ds['color'] as Color),
                      const SizedBox(width: 4),
                      Text(ds['label'] as String, style: TextStyle(fontSize: 11, color: ds['color'] as Color, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/apply', extra: scheme),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
