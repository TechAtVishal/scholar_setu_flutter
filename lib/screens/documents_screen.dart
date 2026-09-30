import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../data/schemes_data.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final docs = prov.documents;
    final uploadedCount = kDocumentTypes.keys.where((k) => docs[k]?['status'] == 'verified').length;
    final total = kDocumentTypes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Documents')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('Documents Verified', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 6),
                Text('$uploadedCount / $total', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                  value: total > 0 ? uploadedCount / total : 0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DigiLocker integration requires API credentials'))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBDEFB))),
                    child: const Row(children: [
                      Icon(Icons.cloud, color: Color(0xFF2196F3), size: 26),
                      SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Fetch from DigiLocker', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                        Text('Auto-import Aadhaar, income cert, marksheets', style: TextStyle(fontSize: 12, color: Color(0xFF1976D2))),
                      ])),
                      Icon(Icons.chevron_right, color: Color(0xFF2196F3)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Required Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...kDocumentTypes.entries.map((entry) {
                  final doc = docs[entry.key];
                  final info = entry.value;
                  Color statusColor;
                  String statusText;
                  IconData statusIcon;
                  if (doc == null) { statusColor = AppTheme.textHint; statusText = 'Not uploaded'; statusIcon = Icons.cloud_upload_outlined; }
                  else if (doc['status'] == 'verified') { statusColor = AppTheme.success; statusText = '\u2713 Verified'; statusIcon = Icons.check_circle; }
                  else if (doc['status'] == 'rejected') { statusColor = AppTheme.error; statusText = '\u2717 Rejected - re-upload'; statusIcon = Icons.cancel; }
                  else { statusColor = AppTheme.warning; statusText = '\u23f3 Verifying...'; statusIcon = Icons.pending; }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)]),
                    child: Row(children: [
                      Text(info['icon']!, style: const TextStyle(fontSize: 24)), const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(info['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(statusText, style: TextStyle(fontSize: 12, color: statusColor)),
                      ])),
                      const SizedBox(width: 10),
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _showUploadSheet(context, prov, entry.key, info['label']!),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          backgroundColor: AppTheme.primaryLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(doc != null ? 'Replace' : 'Upload', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9))),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.verified_user_outlined, color: AppTheme.success, size: 18),
                    SizedBox(width: 10),
                    Expanded(child: Text('All documents are automatically validated using OCR. Name, DOB, and category are cross-verified to prevent errors and rejections.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF388E3C), height: 1.5))),
                  ]),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, AppProvider prov, String docKey, String label) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload $label', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary), title: const Text('Camera'), onTap: () { Navigator.pop(context); _simulateUpload(context, prov, docKey, 'camera'); }),
            ListTile(leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _simulateUpload(context, prov, docKey, 'gallery'); }),
            ListTile(leading: const Icon(Icons.cloud_outlined, color: Color(0xFF2196F3)), title: const Text('DigiLocker'), onTap: () { Navigator.pop(context); _simulateUpload(context, prov, docKey, 'digilocker'); }),
          ],
        ),
      ),
    );
  }

  void _simulateUpload(BuildContext context, AppProvider prov, String docKey, String source) async {
    await prov.addDocument(docKey, {'type': docKey, 'source': source, 'status': 'pending', 'uploadedAt': DateTime.now().toIso8601String()});
    await Future.delayed(const Duration(seconds: 2));
    await prov.addDocument(docKey, {'type': docKey, 'source': source, 'status': 'verified', 'uploadedAt': DateTime.now().toIso8601String()});
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document verified \u2705'), backgroundColor: AppTheme.success));
  }
}
