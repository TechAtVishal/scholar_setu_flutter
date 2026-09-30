import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});
  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  int _tab = 0;

  final _mockApps = [
    {'id': 'APP-1029', 'name': 'Rahul Gond', 'scheme': 'Pre-Matric Scholarship (ST)', 'status': 'pending', 'score': 95},
    {'id': 'APP-1030', 'name': 'Priya Oraon', 'scheme': 'Post-Matric Scholarship', 'status': 'pending', 'score': 88},
    {'id': 'APP-1011', 'name': 'Amit Munda', 'scheme': 'National Fellowship', 'status': 'verified', 'score': 100},
    {'id': 'APP-1005', 'name': 'Sunita Bhil', 'scheme': 'Pre-Matric Scholarship (ST)', 'status': 'rejected', 'score': 45},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _mockApps.where((a) {
      if (_tab == 0) return a['status'] == 'pending';
      if (_tab == 1) return a['status'] == 'verified';
      return a['status'] == 'rejected';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodal Officer Portal'),
        backgroundColor: const Color(0xFF1565C0), // Distinct admin color
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(children: [
              Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.shield, color: Color(0xFF1565C0))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Dr. Sanjay Kumar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('District Nodal Officer • Ranchi', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ])),
            ]),
          ),
          Row(
            children: ['Pending', 'Verified', 'Rejected'].asMap().entries.map((e) {
              final active = _tab == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: active ? const Color(0xFF1565C0) : const Color(0xFFE0E0E0), width: active ? 3 : 1)),
                    ),
                    child: Text(e.value, textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: active ? const Color(0xFF1565C0) : AppTheme.textHint)),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: filtered.isEmpty
              ? const Center(child: Text('No applications in this category', style: TextStyle(color: AppTheme.textHint)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    final isPending = app['status'] == 'pending';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(app['id'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                                child: Text('AI Score: ${app["score"]}', style: const TextStyle(color: Color(0xFF1565C0), fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(app['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(app['scheme'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          const SizedBox(height: 12),
                          if (isPending) Row(children: [
                            Expanded(child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Re-upload Requested')));
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.warning, side: const BorderSide(color: AppTheme.warning)),
                              child: const Text('Request Docs'),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Verified ✓')));
                                setState(() { app['status'] = 'verified'; });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                              child: const Text('Verify'),
                            )),
                          ]),
                        ]),
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
