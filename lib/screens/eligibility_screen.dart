import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';
import '../data/schemes_data.dart';

class EligibilityScreen extends StatelessWidget {
  const EligibilityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppProvider>().profile;
    final results = EligibilityEngine.check(profile, kSchemes);
    final eligible = results.where((r) => r.eligible).toList();
    final notEligible = results.where((r) => !r.eligible).toList();
    final profileComplete = profile.category.isNotEmpty && profile.currentClass.isNotEmpty && profile.annualIncome.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Check Eligibility')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: eligible.isNotEmpty ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Icon(eligible.isNotEmpty ? Icons.check_circle : Icons.info, size: 48, color: eligible.isNotEmpty ? AppTheme.success : AppTheme.warning),
                const SizedBox(height: 10),
                Text(
                  eligible.isNotEmpty ? 'You are eligible for ${eligible.length} scholarship${eligible.length > 1 ? "s" : ""}!' : 'No schemes matched yet',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text(profileComplete ? 'Based on your profile information' : 'Complete your profile for accurate results',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ]),
            ),
            if (!profileComplete) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                  child: const Row(children: [
                    Icon(Icons.person, color: AppTheme.primary, size: 20), SizedBox(width: 10),
                    Expanded(child: Text('Complete Profile for accurate matching  \u2192', style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600))),
                  ]),
                ),
              ),
            ],
            if (eligible.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('\u2705 Eligible (${eligible.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...eligible.map((r) => _ResultCard(result: r, isEligible: true)),
            ],
            if (notEligible.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('\u26a0\ufe0f Not Eligible Yet (${notEligible.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...notEligible.map((r) => _ResultCard(result: r, isEligible: false)),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final EligibilityResult result;
  final bool isEligible;
  const _ResultCard({required this.result, required this.isEligible});
  @override
  Widget build(BuildContext context) {
    final scheme = result.scheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: isEligible ? AppTheme.success : AppTheme.warning, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(scheme.icon, style: const TextStyle(fontSize: 26)), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(scheme.shortName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(scheme.amount, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          if (isEligible) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, size: 14, color: AppTheme.success), SizedBox(width: 4),
              Text('Eligible', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        ...result.reasons.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('• ', style: TextStyle(color: isEligible ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.w800)),
            Expanded(child: Text(r, style: TextStyle(fontSize: 12, color: isEligible ? AppTheme.textSecondary : AppTheme.warning, height: 1.5))),
          ]),
        )),
        if (isEligible) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => context.push('/apply', extra: scheme),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            child: const Text('Apply Now  \u2192'),
          )),
        ],
      ]),
    );
  }
}
