import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

String fmtHms(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(sec)}';
}

String fmtHm(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m}m';
}

class StudyStore extends ChangeNotifier {
  StudyStore(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  List<StudySession> _sessions = [];
  final List<String> subjects = ['DSA', 'OS', 'DBMS', 'CN', 'TOC', 'Maths', 'Other'];
  int goalMinutes = 240;
  String subject = 'DSA';

  int _accSeconds = 0;
  DateTime? _runningSince;
  DateTime? _sessionStart;

  bool get isRunning => _runningSince != null;
  bool get isActive => _sessionStart != null;

  /// Sessions, newest first.
  List<StudySession> get sessions => List.unmodifiable(_sessions);

  int get elapsedSeconds {
    var s = _accSeconds;
    if (_runningSince != null) {
      s += DateTime.now().difference(_runningSince!).inSeconds;
    }
    return s;
  }

  // ---------- persistence ----------

  void _load() {
    final raw = _prefs.getString('sessions');
    if (raw != null) {
      _sessions = (jsonDecode(raw) as List)
          .map((e) => StudySession.fromJson(e as Map<String, dynamic>))
          .toList();
      _sortSessions();
    }
    goalMinutes = _prefs.getInt('goal') ?? goalMinutes;
    subject = _prefs.getString('subject') ?? subject;

    final a = _prefs.getString('active');
    if (a != null) {
      final j = jsonDecode(a) as Map<String, dynamic>;
      _accSeconds = j['acc'] as int;
      _sessionStart = DateTime.fromMillisecondsSinceEpoch(j['start'] as int);
      final since = j['since'] as int?;
      _runningSince =
          since == null ? null : DateTime.fromMillisecondsSinceEpoch(since);
      subject = j['subject'] as String;
    }
  }

  void _sortSessions() => _sessions.sort((a, b) => b.start.compareTo(a.start));

  Future<void> _saveSessions() => _prefs.setString(
      'sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));

  Future<void> _saveActive() {
    if (_sessionStart == null) return _prefs.remove('active');
    return _prefs.setString(
        'active',
        jsonEncode({
          'acc': _accSeconds,
          'start': _sessionStart!.millisecondsSinceEpoch,
          'since': _runningSince?.millisecondsSinceEpoch,
          'subject': subject,
        }));
  }

  // ---------- stopwatch controls ----------

  /// Start a new session, or resume a paused one.
  void start() {
    final now = DateTime.now();
    _sessionStart ??= now;
    _runningSince = now;
    _saveActive();
    notifyListeners();
  }

  void pause() {
    if (_runningSince == null) return;
    _accSeconds = elapsedSeconds;
    _runningSince = null;
    _saveActive();
    notifyListeners();
  }

  /// Ends the session and adds it to the daily total.
  /// Returns the saved duration in seconds (0 if nothing was saved).
  int finish() {
    final total = elapsedSeconds;
    final started = _sessionStart;
    if (started != null && total >= 1) {
      _sessions.add(StudySession(
        id: started.microsecondsSinceEpoch.toString(),
        start: started,
        seconds: total,
        subject: subject,
      ));
      _sortSessions();
      _saveSessions();
    }
    _reset();
    return total >= 1 ? total : 0;
  }

  void discard() => _reset();

  void _reset() {
    _accSeconds = 0;
    _runningSince = null;
    _sessionStart = null;
    _saveActive();
    notifyListeners();
  }

  // ---------- settings ----------

  void setSubject(String s) {
    subject = s;
    _prefs.setString('subject', s);
    notifyListeners();
  }

  void setGoal(int minutes) {
    goalMinutes = minutes;
    _prefs.setInt('goal', minutes);
    notifyListeners();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    _saveSessions();
    notifyListeners();
  }

  // ---------- stats ----------

  /// Total seconds studied on [day]; today also includes the live session.
  int secondsOn(DateTime day) {
    final d = dayOf(day);
    var total = 0;
    for (final s in _sessions) {
      if (dayOf(s.start) == d) total += s.seconds;
    }
    if (isActive && dayOf(_sessionStart!) == d) total += elapsedSeconds;
    return total;
  }

  int get todaySeconds => secondsOn(DateTime.now());

  /// The last 7 days, oldest first, ending today.
  List<MapEntry<DateTime, int>> last7Days() {
    final today = dayOf(DateTime.now());
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return MapEntry(d, secondsOn(d));
    });
  }

  int get weekTotal => last7Days().fold(0, (a, e) => a + e.value);

  int get streak {
    var day = dayOf(DateTime.now());
    if (secondsOn(day) == 0) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (secondsOn(day) > 0) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Seconds per subject over the last 7 days, largest first.
  List<MapEntry<String, int>> weekBySubject() {
    final from = dayOf(DateTime.now()).subtract(const Duration(days: 6));
    final map = <String, int>{};
    for (final s in _sessions) {
      if (!dayOf(s.start).isBefore(from)) {
        map[s.subject] = (map[s.subject] ?? 0) + s.seconds;
      }
    }
    if (isActive && !dayOf(_sessionStart!).isBefore(from)) {
      map[subject] = (map[subject] ?? 0) + elapsedSeconds;
    }
    final list = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}
