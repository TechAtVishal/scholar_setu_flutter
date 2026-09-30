import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/scheme_model.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';
import '../data/schemes_data.dart';

class SchemeDetailScreen extends StatelessWidget {
  final SchemeModel scheme;
  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final ds = DeadlineHelper.getStatus(scheme.deadline);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            title: Text(scheme.shortName),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(scheme.color), Color(scheme.color).withOpacity(0.75)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 44),
                      Text(scheme.icon, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(scheme.name, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20)),
                        child: Text(scheme.amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ],
                  ),
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
                  Wrap(
                    spacing: 10,
                    children: [
                      _MetaChip(icon: Icons.calendar_today, label: 'Deadline: ${ds["label"]}', color: ds['color'] as Color),
                      _MetaChip(icon: Icons.refresh, label: scheme.renewalRequired ? 'Annual Renewal' : 'One-time', color: AppTheme.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'About this Scholarship',
                    child: Text(scheme.description, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Eligibility Criteria',
                    child: Column(children: [
                      _Criteria(icon: Icons.people, label: 'Category: ${(scheme.eligibility["category"] as List).join(", ")}'),
                      const SizedBox(height: 8),
                      _Criteria(icon: Icons.account_balance, label: scheme.eligibility["income"] != null
                          ? 'Max Family Income: ₹${scheme.eligibility["income"].toString()}/year'
                          : 'No Income Limit'),
                      const SizedBox(height: 8),
                      _Criteria(icon: Icons.location_on, label: 'Available in All States / UTs'),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Required Documents',
                    child: Column(
                      children: scheme.documents.map((d) {
                        final info = kDocumentTypes[d];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(children: [
                            Text(info?['icon'] ?? '📄', style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(info?['label'] ?? d, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                              child: const Text('Required', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/apply', extra: scheme),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        elevation: 5, shadowColor: AppTheme.primary.withOpacity(0.4)),
                      child: const Text('Apply for this Scholarship  →'),
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

class _MetaChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _MetaChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4)]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _Section extends StatelessWidget {
  final String title; final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _Criteria extends StatelessWidget {
  final IconData icon; final String label;
  const _Criteria({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 16, color: AppTheme.primary), const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5))),
  ]);
}
