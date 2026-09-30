import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../models/user_profile_model.dart';

class EligibilityResult {
  final SchemeModel scheme;
  final bool eligible;
  final List<String> reasons;
  const EligibilityResult({required this.scheme, required this.eligible, required this.reasons});
}

class EligibilityEngine {
  static List<EligibilityResult> check(UserProfileModel profile, List<SchemeModel> schemes) {
    final results = <EligibilityResult>[];
    for (final scheme in schemes) {
      final reasons = <String>[];
      var eligible = true;

      // Category check
      final cats = scheme.eligibility['category'] as List<dynamic>?;
      if (cats != null && !cats.contains(profile.category)) {
        eligible = false;
        reasons.add('Requires category: ${cats.join(" / ")}');
      }

      // Education level
      final levels = scheme.eligibility['level'] as List<dynamic>?;
      if (levels != null && profile.currentClass.isNotEmpty) {
        if (!levels.contains(profile.currentClass)) {
          eligible = false;
          reasons.add('Your class (${profile.currentClass}) is not covered by this scheme');
        }
      }

      // Income check
      final maxIncome = scheme.eligibility['income'] as int?;
      if (maxIncome != null && profile.annualIncome.isNotEmpty) {
        final income = int.tryParse(profile.annualIncome) ?? 0;
        if (income > maxIncome) {
          eligible = false;
          reasons.add('Family income ₹${_formatIncome(income)} exceeds limit of ₹${_formatIncome(maxIncome)}');
        }
      }

      if (eligible) reasons.add('You appear eligible based on your profile');
      results.add(EligibilityResult(scheme: scheme, eligible: eligible, reasons: reasons));
    }
    results.sort((a, b) => (b.eligible ? 1 : 0) - (a.eligible ? 1 : 0));
    return results;
  }

  static String _formatIncome(int amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toString();
  }

  static List<String> getMissingDocs(SchemeModel scheme, Map<String, Map<String, dynamic>> uploaded) {
    return scheme.documents.where((d) {
      final doc = uploaded[d];
      return doc == null || doc['status'] == 'rejected';
    }).toList();
  }
}

class DeadlineHelper {
  static Map<String, dynamic> getStatus(String deadline) {
    try {
      final dl = DateTime.parse(deadline);
      final diff = dl.difference(DateTime.now()).inDays;
      if (diff < 0) return {'label': 'Closed', 'color': const Color(0xFFF44336)};
      if (diff <= 7) return {'label': '$diff days left', 'color': const Color(0xFFFF5722)};
      if (diff <= 30) return {'label': '$diff days left', 'color': const Color(0xFFFF9800)};
      return {'label': '$diff days left', 'color': const Color(0xFF4CAF50)};
    } catch (_) {
      return {'label': 'No Deadline', 'color': const Color(0xFF888888)};
    }
  }
}

class StatusHelper {
  static const Map<String, Map<String, dynamic>> _statusMap = {
    'draft': {'label': 'Draft', 'color': Color(0xFF9E9E9E), 'icon': Icons.edit_note},
    'submitted': {'label': 'Submitted', 'color': Color(0xFF2196F3), 'icon': Icons.upload},
    'under_review': {'label': 'Under Review', 'color': Color(0xFFFF9800), 'icon': Icons.find_in_page},
    'pending_docs': {'label': 'Docs Needed', 'color': Color(0xFFFF5722), 'icon': Icons.folder_open},
    'institute_verified': {'label': 'Institute Verified', 'color': Color(0xFF8BC34A), 'icon': Icons.verified},
    'state_approved': {'label': 'State Approved', 'color': Color(0xFF4CAF50), 'icon': Icons.check_circle},
    'sanctioned': {'label': 'Sanctioned', 'color': Color(0xFF009688), 'icon': Icons.thumb_up},
    'disbursed': {'label': 'Amount Credited', 'color': Color(0xFF4CAF50), 'icon': Icons.payments},
    'rejected': {'label': 'Rejected', 'color': Color(0xFFF44336), 'icon': Icons.cancel},
  };

  static Map<String, dynamic> get(String status) {
    return _statusMap[status] ?? {'label': status, 'color': const Color(0xFF888888), 'icon': Icons.help};
  }
}

bool validateAadhaar(String num) {
  final clean = num.replaceAll(' ', '');
  return RegExp(r'^\d{12}$').hasMatch(clean);
}

bool validateIFSC(String code) {
  return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(code);
}

String formatAadhaar(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final limited = digits.length > 12 ? digits.substring(0, 12) : digits;
  final buffer = StringBuffer();
  for (int i = 0; i < limited.length; i++) {
    if (i == 4 || i == 8) buffer.write(' ');
    buffer.write(limited[i]);
  }
  return buffer.toString();
}
