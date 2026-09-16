/// Mirrors a document in /classes/{classId}.
/// Named ClassModel because `Class` is a reserved word in Dart.
class ClassModel {
  final String id;
  final String name; // e.g. "7eme AF"
  final String yearId;
  final String? headTeacherUid;
  final int capacity;

  const ClassModel({
    required this.id,
    required this.name,
    required this.yearId,
    this.headTeacherUid,
    this.capacity = 0,
  });

  factory ClassModel.fromMap(String id, Map<String, dynamic> map) {
    return ClassModel(
      id: id,
      name: map['name'] as String? ?? '',
      yearId: map['yearId'] as String? ?? '',
      headTeacherUid: map['headTeacherUid'] as String?,
      capacity: map['capacity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'yearId': yearId,
      'headTeacherUid': headTeacherUid,
      'capacity': capacity,
    };
  }
}
