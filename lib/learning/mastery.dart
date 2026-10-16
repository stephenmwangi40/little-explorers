/// The learning engine: mastery, spaced review and adaptive difficulty.
///
/// Rules (from the build brief):
/// - A skill is "secure" after >= 80% correct over the last 10 items with no
///   hint, across at least 2 different days.
/// - Secure skills come back for review after 1, 3, 7 and 21 days.
/// - 2 misses in a row -> easier; 5 correct in a row -> harder.
library;

class Attempt {
  final int t; // epoch ms
  final bool ok;
  final bool hint;
  const Attempt(this.t, this.ok, this.hint);

  bool get clean => ok && !hint;

  Map<String, dynamic> toJson() => {'t': t, 'o': ok, 'h': hint};
  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(j['t'] as int, j['o'] as bool, j['h'] as bool);
}

class SkillRecord {
  final List<Attempt> attempts;
  bool secure;
  int reviewStage; // index into reviewDays for the NEXT review
  int? nextReview; // epoch ms
  int streakOk;
  int streakMiss;

  SkillRecord({
    List<Attempt>? attempts,
    this.secure = false,
    this.reviewStage = 0,
    this.nextReview,
    this.streakOk = 0,
    this.streakMiss = 0,
  }) : attempts = attempts ?? [];

  Map<String, dynamic> toJson() => {
        'a': attempts.map((a) => a.toJson()).toList(),
        's': secure,
        'r': reviewStage,
        'n': nextReview,
        'so': streakOk,
        'sm': streakMiss,
      };

  factory SkillRecord.fromJson(Map<String, dynamic> j) => SkillRecord(
        attempts: (j['a'] as List).map((e) => Attempt.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        secure: j['s'] as bool? ?? false,
        reviewStage: j['r'] as int? ?? 0,
        nextReview: j['n'] as int?,
        streakOk: j['so'] as int? ?? 0,
        streakMiss: j['sm'] as int? ?? 0,
      );

  /// Share of clean (correct, no hint) answers in the last 10 attempts.
  double get accuracy {
    final last = recent(10);
    if (last.isEmpty) return 0;
    return last.where((a) => a.clean).length / last.length;
  }

  List<Attempt> recent(int n) => attempts.length <= n ? attempts : attempts.sublist(attempts.length - n);
}

class MasteryEngine {
  static const reviewDays = [1, 3, 7, 21];
  static const keep = 30;

  static int _day(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  static bool meetsMastery(SkillRecord r) {
    final last = r.recent(10);
    if (last.length < 10) return false;
    final clean = last.where((a) => a.clean).length;
    final days = last.map((a) => _day(a.t)).toSet().length;
    return clean >= 8 && days >= 2;
  }

  static bool isDue(SkillRecord r, DateTime now) =>
      r.secure && r.nextReview != null && r.nextReview! <= now.millisecondsSinceEpoch;

  /// Records one answer and updates mastery, review schedule and streaks.
  static void record(SkillRecord r, {required bool ok, required bool hint, required DateTime now}) {
    final wasDue = isDue(r, now);
    r.attempts.add(Attempt(now.millisecondsSinceEpoch, ok, hint));
    if (r.attempts.length > keep) r.attempts.removeRange(0, r.attempts.length - keep);

    if (ok && !hint) {
      r.streakOk++;
      r.streakMiss = 0;
    } else if (!ok) {
      r.streakMiss++;
      r.streakOk = 0;
    }

    if (!r.secure) {
      if (meetsMastery(r)) {
        r.secure = true;
        r.reviewStage = 0;
        r.nextReview = now.add(Duration(days: reviewDays[0])).millisecondsSinceEpoch;
      }
      return;
    }

    // Secure skill: demote if the child is clearly struggling again.
    final last3 = r.recent(3);
    if (last3.length == 3 && last3.where((a) => !a.ok).length >= 2) {
      r.secure = false;
      r.reviewStage = 0;
      r.nextReview = null;
      return;
    }

    if (wasDue) {
      if (ok && !hint) {
        r.reviewStage++;
        r.nextReview = r.reviewStage < reviewDays.length
            ? now.add(Duration(days: reviewDays[r.reviewStage])).millisecondsSinceEpoch
            : null; // long-term memory: no more scheduled reviews
      } else {
        r.reviewStage = 0;
        r.nextReview = now.add(Duration(days: reviewDays[0])).millisecondsSinceEpoch;
      }
    }
  }

  /// -1 easier, 0 same, +1 harder.
  static int difficultyDelta(SkillRecord? r) {
    if (r == null) return 0;
    if (r.streakMiss >= 2) return -1;
    if (r.streakOk >= 5) return 1;
    return 0;
  }
}
