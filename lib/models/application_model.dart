class ApplicationTimeline {
  final String status;
  final String label;
  final DateTime? date;
  final String note;
  final bool done;

  const ApplicationTimeline({
    required this.status,
    required this.label,
    this.date,
    required this.note,
    required this.done,
  });

  Map<String, dynamic> toJson() => {
    'status': status, 'label': label,
    'date': date?.toIso8601String(), 'note': note, 'done': done,
  };

  factory ApplicationTimeline.fromJson(Map<String, dynamic> j) => ApplicationTimeline(
    status: j['status'], label: j['label'],
    date: j['date'] != null ? DateTime.parse(j['date']) : null,
    note: j['note'], done: j['done'] ?? false,
  );
}

class ApplicationModel {
  final String id;
  final String applicationId;
  final String schemeId;
  final String schemeName;
  String status;
  final DateTime submittedAt;
  final Map<String, dynamic> formData;
  List<ApplicationTimeline> timeline;

  ApplicationModel({
    required this.id,
    required this.applicationId,
    required this.schemeId,
    required this.schemeName,
    required this.status,
    required this.submittedAt,
    required this.formData,
    required this.timeline,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'applicationId': applicationId,
    'schemeId': schemeId, 'schemeName': schemeName,
    'status': status, 'submittedAt': submittedAt.toIso8601String(),
    'formData': formData,
    'timeline': timeline.map((t) => t.toJson()).toList(),
  };

  factory ApplicationModel.fromJson(Map<String, dynamic> j) => ApplicationModel(
    id: j['id'], applicationId: j['applicationId'],
    schemeId: j['schemeId'], schemeName: j['schemeName'],
    status: j['status'], submittedAt: DateTime.parse(j['submittedAt']),
    formData: Map<String, dynamic>.from(j['formData'] ?? {}),
    timeline: (j['timeline'] as List? ?? [])
        .map((t) => ApplicationTimeline.fromJson(t))
        .toList(),
  );
}
