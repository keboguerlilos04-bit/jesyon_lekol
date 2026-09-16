/// Mirrors a document in /schoolYears/{yearId}.
class SchoolYear {
  final String id;
  final String label; // e.g. "2026-2027"
  final DateTime startDate;
  final DateTime endDate;
  final bool active;

  const SchoolYear({
    required this.id,
    required this.label,
    required this.startDate,
    required this.endDate,
    this.active = false,
  });

  factory SchoolYear.fromMap(String id, Map<String, dynamic> map) {
    return SchoolYear(
      id: id,
      label: map['label'] as String? ?? '',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      active: map['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'active': active,
    };
  }
}
