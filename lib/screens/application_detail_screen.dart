import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/application_model.dart';
import '../utils/app_theme.dart';
import '../utils/eligibility_engine.dart';

const _statusOrder = ['submitted', 'under_review', 'institute_verified', 'state_approved', 'sanctioned', 'disbursed'];

class ApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final si = StatusHelper.get(application.status);
    final currentIdx = _statusOrder.indexOf(application.status);
    final steps = [
      _Step('submitted', 'Submitted', application.submittedAt, 'Application submitted to NSP portal', true),
      _Step('under_review', 'Under Review', null, 'Awaiting institute verification', currentIdx >= 1),
      _Step('institute_verified', 'Institute Verified', null, 'Nodal officer to verify documents', currentIdx >= 2),
      _Step('state_approved', 'State Approved', null, 'State welfare dept approval', currentIdx >= 3),
      _Step('sanctioned', 'Sanctioned', null, 'Amount sanctioned by Ministry', currentIdx >= 4),
      _Step('disbursed', 'Amount Credited', null, 'Credited to bank account via DBT', currentIdx >= 5),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Application Status')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(gradient: LinearGradient(
                colors: [si['color'] as Color, (si['color'] as Color).withOpacity(0.75)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(children: [
                Icon(si['icon'] as IconData, size: 48, color: Colors.white),
                const SizedBox(height: 10),
                Text(si['label'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text(application.applicationId, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), fontFamily: 'monospace')),
                const SizedBox(height: 4),
                Text(application.schemeName, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Section(title: 'Application Timeline', child: Column(children: List.generate(steps.length, (i) {
                  final step = steps[i];
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(children: [
                      Container(width: 28, height: 28,
                        decoration: BoxDecoration(color: step.done ? si['color'] as Color : const Color(0xFFE0E0E0), shape: BoxShape.circle),
                        child: step.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                      if (i < steps.length - 1) Container(width: 2, height: 50, color: step.done ? (si['color'] as Color).withOpacity(0.3) : const Color(0xFFE0E0E0)),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(child: Padding(
                      padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 0 : 0, top: 4),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(step.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: step.done ? AppTheme.textPrimary : AppTheme.textHint)),
                        if (step.date != null) Text('${step.date!.day}/${step.date!.month}/${step.date!.year}', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                        Text(step.note, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
                        SizedBox(height: i < steps.length - 1 ? 0 : 0),
                      ]),
                    )),
                  ]);
                }))),
                const SizedBox(height: 12),
                _Section(title: 'Application Details', child: Column(children: [
                  ['Application ID', application.applicationId],
                  ['Submitted On', '${application.submittedAt.day}/${application.submittedAt.month}/${application.submittedAt.year}'],
                  ['Student Name', application.formData['fullName'] ?? '-'],
                  ['Mobile', application.formData['mobileNumber'] ?? '-'],
                  ['Institution', application.formData['institution'] ?? '-'],
                ].map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(row[0], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    Flexible(child: Text(row[1], textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  ]),
                )).toList())),
                if (application.status == 'disbursed') ...[
                  const SizedBox(height: 12),
                  Container(width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8E6C9))),
                    child: const Column(children: [
                      Icon(Icons.payments, size: 36, color: AppTheme.success), SizedBox(height: 8),
                      Text('Amount Credited!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                      SizedBox(height: 4),
                      Text('Scholarship credited to your bank account via DBT', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF388E3C))),
                    ])),
                ],
                if (['submitted', 'under_review'].contains(application.status)) ...[
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.report_problem_outlined, color: AppTheme.error),
                      label: const Text('Raise a Grievance', style: TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error), padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => context.push('/grievance'),
                    )),
                ],
                const SizedBox(height: 30),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String status, label, note;
  final DateTime? date;
  final bool done;
  const _Step(this.status, this.label, this.date, this.note, this.done);
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
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 12), child,
    ]),
  );
}
