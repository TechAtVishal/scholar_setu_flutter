import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/scheme_model.dart';
import '../data/schemes_data.dart';

class ApplicationFormScreen extends StatefulWidget {
  final SchemeModel scheme;
  const ApplicationFormScreen({super.key, required this.scheme});
  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  int _step = 0;
  bool _loading = false;
  final _form = GlobalKey<FormState>();

  final Map<String, TextEditingController> _ctrls = {};
  String _gender = '';
  String _currentClass = '';

  TextEditingController _c(String key) => _ctrls.putIfAbsent(key, () {
    final p = context.read<AppProvider>().profile;
    final Map<String, String> vals = {
      'fullName': p.fullName, 'dob': p.dob, 'aadhaar': p.aadhaarNumber,
      'mobile': p.mobileNumber, 'guardian': p.guardianName, 'subTribe': p.subTribe,
      'district': p.district, 'institution': p.institution, 'course': p.course,
      'income': p.annualIncome, 'bankAcc': p.bankAccountNumber, 'ifsc': p.ifscCode,
      'bankName': p.bankName,
    };
    return TextEditingController(text: vals[key] ?? '');
  });

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  static const _steps = ['Personal', 'Academic', 'Bank', 'Review'];

  Widget _buildPersonal() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _InputField('Full Name *', _c('fullName'), required: true),
    _InputField('Date of Birth (DD/MM/YYYY) *', _c('dob'), required: true, hint: 'DD/MM/YYYY'),
    _SectionLabel('Gender *'),
    Wrap(spacing: 10, children: ['Male', 'Female', 'Other'].map((g) => ChoiceChip(
      label: Text(g),
      selected: _gender == g,
      onSelected: (_) => setState(() => _gender = g),
      selectedColor: AppTheme.primaryLight,
      side: BorderSide(color: _gender == g ? AppTheme.primary : const Color(0xFFE0E0E0)),
      labelStyle: TextStyle(color: _gender == g ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600),
    )).toList()),
    const SizedBox(height: 12),
    _InputField('Aadhaar Number *', _c('aadhaar'), required: true, keyboardType: TextInputType.number),
    _InputField('Mobile Number *', _c('mobile'), required: true, keyboardType: TextInputType.phone),
    _InputField('Guardian Name *', _c('guardian'), required: true),
    _InputField('Sub-Tribe / Community', _c('subTribe')),
    _InputField('District *', _c('district'), required: true),
  ]);

  Widget _buildAcademic() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _InputField('Institution / School Name *', _c('institution'), required: true),
    _InputField('Course / Class *', _c('course'), required: true),
    _SectionLabel('Current Class / Level *'),
    Wrap(spacing: 8, runSpacing: 8, children: kEducationLevels.map((l) => ChoiceChip(
      label: Text(l['label']!, style: const TextStyle(fontSize: 12)),
      selected: _currentClass == l['id'],
      onSelected: (_) => setState(() => _currentClass = l['id']!),
      selectedColor: AppTheme.primaryLight,
      side: BorderSide(color: _currentClass == l['id']! ? AppTheme.primary : const Color(0xFFE0E0E0)),
      labelStyle: TextStyle(color: _currentClass == l['id']! ? AppTheme.primary : AppTheme.textSecondary),
    )).toList()),
    const SizedBox(height: 12),
    _InputField('Annual Family Income (₹) *', _c('income'), required: true, keyboardType: TextInputType.number),
  ]);

  Widget _buildBank() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB))),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info, color: Color(0xFF1565C0), size: 18), SizedBox(width: 10),
        Expanded(child: Text('Amount will be directly credited via DBT (Direct Benefit Transfer)',
          style: TextStyle(fontSize: 13, color: Color(0xFF1565C0), height: 1.5))),
      ]),
    ),
    _InputField('Bank Account Number *', _c('bankAcc'), required: true, keyboardType: TextInputType.number),
    _InputField('IFSC Code *', _c('ifsc'), required: true),
    _InputField('Bank Name *', _c('bankName'), required: true),
    Container(
      padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082))),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.warning_amber, color: Color(0xFFF57F17), size: 18), SizedBox(width: 10),
        Expanded(child: Text('Ensure bank account is in your name and Aadhaar-linked. Mismatches cause payment delays.',
          style: TextStyle(fontSize: 12, color: Color(0xFFF57F17), height: 1.5))),
      ]),
    ),
  ]);

  Widget _buildReview() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Scheme', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(widget.scheme.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 2),
        Text(widget.scheme.amount, style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
      ]),
    ),
    ...[
      ['Full Name', _c('fullName').text],
      ['Date of Birth', _c('dob').text],
      ['Gender', _gender],
      ['Mobile', _c('mobile').text],
      ['Institution', _c('institution').text],
      ['Course', _c('course').text],
      ['Bank Account', _c('bankAcc').text.isNotEmpty ? '****${_c("bankAcc").text.substring(_c("bankAcc").text.length > 4 ? _c("bankAcc").text.length - 4 : 0)}' : '-'],
      ['IFSC', _c('ifsc').text],
    ].map((row) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(row[0], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Flexible(child: Text(row[1].isEmpty ? '—' : row[1], textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    )).toList(),
  ]);

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final app = await context.read<AppProvider>().addApplication(
      schemeId: widget.scheme.id,
      schemeName: widget.scheme.name,
      formData: {
        'fullName': _c('fullName').text, 'dob': _c('dob').text,
        'gender': _gender, 'aadhaarNumber': _c('aadhaar').text,
        'mobileNumber': _c('mobile').text, 'guardianName': _c('guardian').text,
        'institution': _c('institution').text, 'course': _c('course').text,
        'currentClass': _currentClass, 'annualIncome': _c('income').text,
        'bankAccountNumber': _c('bankAcc').text, 'ifscCode': _c('ifsc').text,
        'bankName': _c('bankName').text,
      },
    );
    if (!mounted) return;
    setState(() => _loading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Application Submitted! 🎉', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, size: 64, color: AppTheme.success),
          const SizedBox(height: 12),
          Text('Application ID:\n${app.applicationId}', textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          const Text('Track your application in the Track tab.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
        actions: [ElevatedButton(
          onPressed: () { Navigator.pop(context); context.go('/track'); },
          child: const Text('View Application'),
        )],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply: ${widget.scheme.shortName}')),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIdx = i ~/ 2;
                  return Expanded(child: Container(height: 2, color: stepIdx < _step ? AppTheme.primary : const Color(0xFFE0E0E0)));
                }
                final stepIdx = i ~/ 2;
                final active = stepIdx == _step;
                final done = stepIdx < _step;
                return Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: done || active ? AppTheme.primary : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle),
                  child: Center(child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${stepIdx + 1}', style: TextStyle(color: done || active ? Colors.white : AppTheme.textHint, fontWeight: FontWeight.w700, fontSize: 13))),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_steps[_step], textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          // Scheme tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6)]),
              child: Row(children: [
                Text(widget.scheme.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.scheme.shortName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(widget.scheme.amount, style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: [_buildPersonal(), _buildAcademic(), _buildBank(), _buildReview()][_step],
              ),
            ),
          ),
          // Nav buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2))]),
            child: Row(children: [
              if (_step > 0) ...[ 
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                  child: const Text('← Back', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : () {
                    if (_step < _steps.length - 1) setState(() => _step++);
                    else _submit();
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_step < _steps.length - 1 ? 'Next →' : 'Submit Application',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;
  final String? hint;
  const _InputField(this.label, this.controller, {this.required = false, this.keyboardType, this.hint});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint ?? label.replaceAll(' *', '')),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      ),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
  );
}
