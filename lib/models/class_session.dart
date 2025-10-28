class ClassSession {
  final String teacherName;
  final String subject;
  final String date;
  final String time;
  final bool isActive;

  ClassSession({
    required this.teacherName,
    required this.subject,
    required this.date,
    required this.time,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherName': teacherName,
      'subject': subject,
      'date': date,
      'time': time,
      'isActive': isActive,
    };
  }
}
