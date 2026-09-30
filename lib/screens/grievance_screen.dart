import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';

class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});
  @override
  State<GrievanceScreen> createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  String _type = '';
  final _descCtrl = TextEditingController();
  bool _loading = false;

  final _types = [
    {'id': 'payment', 'icon': Icons.payments_outlined, 'label': 'Payment Delay / Failed'},
    {'id': 'rejection', 'icon': Icons.cancel_outlined, 'label': 'Unfair Rejection'},
    {'id': 'document', 'icon': Icons.file_upload_outlined, 'label': 'Document Upload Issue'},
    {'id': 'technical', 'icon': Icons.bug_report_outlined, 'label': 'App / Technical Error'},
    {'id': 'other', 'icon': Icons.help_outline, 'label': 'Other Issue'},
  ];

  Future<void> _submit() async {
    if (_type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a grievance type'), backgroundColor: AppTheme.error));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe your issue'), backgroundColor: AppTheme.error));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Grievance Submitted', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, size: 64, color: AppTheme.success),
          const SizedBox(height: 12),
          Text('Ticket ID:\nGRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}', textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Your nodal officer has been notified. Expected resolution: 7 working days.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            child: const Text('Back to Home'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Grievance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0B2))),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Grievances are escalated directly to your District Nodal Officer and State Welfare Department.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE65100), height: 1.5))),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('What is the issue regarding?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ..._types.map((t) {
              final active = _type == t['id'];
              return GestureDetector(
                onTap: () => setState(() => _type = t['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: active ? AppTheme.primary : const Color(0xFFE0E0E0), width: active ? 2 : 1),
                  ),
                  child: Row(children: [
                    Icon(t['icon'] as IconData, color: active ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t['label'] as String, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppTheme.primary : AppTheme.textPrimary))),
                    if (active) const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Please describe your problem in detail...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Grievance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
