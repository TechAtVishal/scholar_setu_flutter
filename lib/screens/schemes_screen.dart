import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';
import '../data/schemes_data.dart';
import '../models/scheme_model.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});
  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _search = '';
  String _category = 'all';
  final _ctrl = TextEditingController();

  static const _cats = [
    {'id': 'all', 'label': 'All'},
    {'id': 'pre-matric', 'label': 'Pre-Matric'},
    {'id': 'post-matric', 'label': 'Post-Matric'},
    {'id': 'fellowship', 'label': 'Fellowship'},
    {'id': 'school', 'label': 'School'},
    {'id': 'overseas', 'label': 'Overseas'},
  ];

  List<SchemeModel> get _filtered => kSchemes.where((s) =>
    s.name.toLowerCase().contains(_search.toLowerCase()) &&
    (_category == 'all' || s.category == _category)).toList();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppProvider>().profile;
    final elig = EligibilityEngine.check(profile, kSchemes);
    final eligMap = {for (var e in elig) e.scheme.id: e.eligible};

    return Scaffold(
      appBar: AppBar(title: const Text('All Scholarships')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search scholarships...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _ctrl.clear(); setState(() => _search = '');
                      }) : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _cats.map((c) {
                final active = _category == c['id'];
                return GestureDetector(
                  onTap: () => setState(() => _category = c['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppTheme.primary : const Color(0xFFE0E0E0)),
                    ),
                    child: Text(c['label']!, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No schemes found', style: TextStyle(color: AppTheme.textHint)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      final isEligible = eligMap[s.id] ?? false;
                      final ds = DeadlineHelper.getStatus(s.deadline);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/scheme-detail', extra: s),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56, height: 56,
                                      decoration: BoxDecoration(
                                        color: Color(s.color).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14)),
                                      child: Center(child: Text(s.icon, style: const TextStyle(fontSize: 30))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text(s.ministry, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                      ],
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(children: [
                                  const Icon(Icons.payments_outlined, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 4),
                                  Text(s.amount, style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 14),
                                  Icon(Icons.calendar_today, size: 13, color: ds['color'] as Color),
                                  const SizedBox(width: 4),
                                  Text(ds['label'] as String, style: TextStyle(fontSize: 12, color: ds['color'] as Color, fontWeight: FontWeight.w600)),
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isEligible ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(8)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(isEligible ? Icons.check_circle : Icons.help, size: 14, color: isEligible ? AppTheme.success : AppTheme.warning),
                                      const SizedBox(width: 4),
                                      Text(isEligible ? 'Eligible' : 'Check Eligibility',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isEligible ? AppTheme.success : AppTheme.warning)),
                                    ]),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => context.push('/apply', extra: s),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    child: const Text('Apply'),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
