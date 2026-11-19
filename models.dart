class StudySession {
  final String id;
  final DateTime start;
  final int seconds;
  final String subject;
  final String note;

  const StudySession({
    required this.id,
    required this.start,
    required this.seconds,
    required this.subject,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.millisecondsSinceEpoch,
        'seconds': seconds,
        'subject': subject,
        'note': note,
      };

  factory StudySession.fromJson(Map<String, dynamic> j) => StudySession(
        id: j['id'] as String,
        start: DateTime.fromMillisecondsSinceEpoch(j['start'] as int),
        seconds: j['seconds'] as int,
        subject: j['subject'] as String,
        note: (j['note'] as String?) ?? '',
      );
}
