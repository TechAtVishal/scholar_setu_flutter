class SchemeModel {
  final String id;
  final String name;
  final String shortName;
  final String ministry;
  final String category;
  final String amount;
  final String deadline;
  final String description;
  final String icon;
  final int color;
  final Map<String, dynamic> eligibility;
  final List<String> documents;
  final bool renewalRequired;

  const SchemeModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.ministry,
    required this.category,
    required this.amount,
    required this.deadline,
    required this.description,
    required this.icon,
    required this.color,
    required this.eligibility,
    required this.documents,
    this.renewalRequired = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'shortName': shortName,
    'ministry': ministry, 'category': category,
    'amount': amount, 'deadline': deadline,
    'description': description, 'icon': icon,
    'color': color, 'eligibility': eligibility,
    'documents': documents, 'renewalRequired': renewalRequired,
  };
}
