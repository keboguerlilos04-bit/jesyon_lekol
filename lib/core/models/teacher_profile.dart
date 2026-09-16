/// Mirrors a document in /teachers/{uid}.
class TeacherProfile {
  final String uid;
  final List<String> subjectIds;
  final List<String> classIds;

  const TeacherProfile({
    required this.uid,
    required this.subjectIds,
    required this.classIds,
  });

  factory TeacherProfile.fromMap(String uid, Map<String, dynamic> map) {
    return TeacherProfile(
      uid: uid,
      subjectIds: List<String>.from(map['subjectIds'] as List? ?? const []),
      classIds: List<String>.from(map['classIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectIds': subjectIds,
      'classIds': classIds,
    };
  }
}
