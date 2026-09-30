import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../data/schemes_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  late Map<String, TextEditingController> _ctrls;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      final p = context.read<AppProvider>().profile;
      _ctrls = {
        'fullName': TextEditingController(text: p.fullName),
        'dob': TextEditingController(text: p.dob),
        'gender': TextEditingController(text: p.gender),
        'mobile': TextEditingController(text: p.mobileNumber),
        'guardian': TextEditingController(text: p.guardianName),
        'subTribe': TextEditingController(text: p.subTribe),
        'state': TextEditingController(text: p.state),
        'district': TextEditingController(text: p.district),
        'institution': TextEditingController(text: p.institution),
        'course': TextEditingController(text: p.course),
        'currentClass': TextEditingController(text: p.currentClass),
        'income': TextEditingController(text: p.annualIncome),
        'bankAcc': TextEditingController(text: p.bankAccountNumber),
        'ifsc': TextEditingController(text: p.ifscCode),
        'bankName': TextEditingController(text: p.bankName),
      };
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final prov = context.read<AppProvider>();
    final p = prov.profile;
    await prov.updateProfile(p.copyWith(
      fullName: _ctrls['fullName']!.text, dob: _ctrls['dob']!.text,
      gender: _ctrls['gender']!.text, mobileNumber: _ctrls['mobile']!.text,
      guardianName: _ctrls['guardian']!.text, subTribe: _ctrls['subTribe']!.text,
      state: _ctrls['state']!.text, district: _ctrls['district']!.text,
      institution: _ctrls['institution']!.text, course: _ctrls['course']!.text,
      currentClass: _ctrls['currentClass']!.text, annualIncome: _ctrls['income']!.text,
      bankAccountNumber: _ctrls['bankAcc']!.text, ifscCode: _ctrls['ifsc']!.text,
      bankName: _ctrls['bankName']!.text,
    ));
    setState(() => _editing = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved ✓'), backgroundColor: AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final profile = prov.profile;
    final strength = profile.profileStrength;
    final pct = profile.profilePercent;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            title: const Text('My Profile'),
            actions: [
              TextButton(
                onPressed: _editing ? _save : () => setState(() => _editing = true),
                child: Text(_editing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)]),
                      child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(profile.fullName.isEmpty ? 'Student' : profile.fullName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 14),
                    Text('Profile Strength: $strength/10', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    const SizedBox(height: 6),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                      value: pct, backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 6)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Section(title: 'Personal Information', children: [
                  _FieldRow('Full Name', _ctrls['fullName']!, editing: _editing),
                  _FieldRow('Date of Birth', _ctrls['dob']!, editing: _editing),
                  _FieldRow('Gender', _ctrls['gender']!, editing: _editing),
                  _FieldRow('Mobile', _ctrls['mobile']!, editing: _editing, keyboard: TextInputType.phone),
                  _FieldRow('Guardian Name', _ctrls['guardian']!, editing: _editing),
                  _FieldRow('Sub-Tribe', _ctrls['subTribe']!, editing: _editing),
                ]),
                const SizedBox(height: 12),
                _Section(title: 'Location', children: [
                  _FieldRow('State', _ctrls['state']!, editing: _editing),
                  _FieldRow('District', _ctrls['district']!, editing: _editing),
                ]),
                const SizedBox(height: 12),
                _Section(title: 'Academic Details', children: [
                  _FieldRow('Institution', _ctrls['institution']!, editing: _editing),
                  _FieldRow('Course', _ctrls['course']!, editing: _editing),
                  _FieldRow('Class/Level', _ctrls['currentClass']!, editing: _editing),
                  _FieldRow('Annual Income (₹)', _ctrls['income']!, editing: _editing, keyboard: TextInputType.number),
                ]),
                const SizedBox(height: 12),
                _Section(title: 'Bank Details (for DBT)', children: [
                  _FieldRow('Bank Account No.', _ctrls['bankAcc']!, editing: _editing, keyboard: TextInputType.number),
                  _FieldRow('IFSC Code', _ctrls['ifsc']!, editing: _editing),
                  _FieldRow('Bank Name', _ctrls['bankName']!, editing: _editing),
                ]),
                const SizedBox(height: 16),
                // Quick actions
                ...[
                  _ActionRow(Icons.settings_outlined, 'Settings & Language', () => context.push('/settings')),
                  _ActionRow(Icons.folder_outlined, 'My Documents', () => context.push('/documents')),
                  _ActionRow(Icons.verified_user_outlined, 'Officer Dashboard', () => context.push('/officer')),
                  _ActionRow(Icons.logout, 'Logout', () => _confirmLogout(context, prov), color: AppTheme.error),
                ],
                const SizedBox(height: 16),
                const Center(child: Text('ScholarSetu v1.0 · SIH 2026 · CipherGuard', style: TextStyle(fontSize: 12, color: AppTheme.textHint))),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider prov) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async { Navigator.pop(context); await prov.logout(); if (context.mounted) context.go('/login'); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: const Text('Logout'),
        ),
      ],
    ));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.3)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _FieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editing;
  final TextInputType? keyboard;
  const _FieldRow(this.label, this.controller, {required this.editing, this.keyboard});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
      Expanded(
        child: editing
            ? TextField(controller: controller, keyboardType: keyboard,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)))
            : Text(controller.text.isEmpty ? '—' : controller.text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), textAlign: TextAlign.right),
      ),
    ]),
  );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionRow(this.icon, this.label, this.onTap, {this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
        border: color != null ? Border.all(color: color!.withOpacity(0.25)) : null),
      child: Row(children: [
        Icon(icon, size: 20, color: color ?? AppTheme.textSecondary), const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary))),
        const Icon(Icons.chevron_right, color: AppTheme.textHint),
      ]),
    ),
  );
}
