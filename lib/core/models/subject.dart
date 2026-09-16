/// Mirrors a document in /subjects/{subjectId}.
class Subject {
  final String id;
  final String name;
  final double coefficient;
  final String classId;

  const Subject({
    required this.id,
    required this.name,
    required this.coefficient,
    required this.classId,
  });

  factory Subject.fromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      name: map['name'] as String? ?? '',
      coefficient: (map['coefficient'] as num?)?.toDouble() ?? 1.0,
      classId: map['classId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'coefficient': coefficient,
      'classId': classId,
    };
  }
}
