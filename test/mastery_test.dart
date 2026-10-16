import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/learning/mastery.dart';

void main() {
  final day1 = DateTime(2026, 10, 1, 9);
  final day2 = DateTime(2026, 10, 2, 9);

  void answer(SkillRecord r, int n, {required bool ok, bool hint = false, required DateTime at}) {
    for (var i = 0; i < n; i++) {
      MasteryEngine.record(r, ok: ok, hint: hint, now: at.add(Duration(minutes: i)));
    }
  }

  test('not secure with 10 correct on a single day', () {
    final r = SkillRecord();
    answer(r, 10, ok: true, at: day1);
    expect(r.secure, isFalse);
  });

  test('secure after >= 80% clean over last 10, across 2 days', () {
    final r = SkillRecord();
    answer(r, 5, ok: true, at: day1);
    answer(r, 2, ok: false, at: day1.add(const Duration(hours: 1)));
    answer(r, 2, ok: true, at: day2);
    // 9 attempts so far: not enough evidence yet.
    expect(r.secure, isFalse);
    answer(r, 1, ok: true, at: day2.add(const Duration(hours: 1)));
    // Last 10: 5 ok (day 1), 2 miss, 3 ok (day 2) -> 8 clean over 2 days.
    expect(r.secure, isTrue);
    expect(r.nextReview, day2.add(const Duration(hours: 1)).add(const Duration(days: 1)).millisecondsSinceEpoch);
  });

  test('hinted answers do not count toward mastery', () {
    final r = SkillRecord();
    answer(r, 5, ok: true, hint: true, at: day1);
    answer(r, 5, ok: true, hint: true, at: day2);
    expect(r.secure, isFalse);
  });

  test('review schedule goes 1, 3, 7, 21 days', () {
    final r = SkillRecord();
    answer(r, 5, ok: true, at: day1);
    answer(r, 5, ok: true, at: day2);
    expect(r.secure, isTrue);
    var now = day2;
    for (final gap in [3, 7, 21]) {
      now = DateTime.fromMillisecondsSinceEpoch(r.nextReview!);
      expect(MasteryEngine.isDue(r, now), isTrue);
      MasteryEngine.record(r, ok: true, hint: false, now: now);
      expect(DateTime.fromMillisecondsSinceEpoch(r.nextReview!).difference(now).inDays, gap);
    }
    now = DateTime.fromMillisecondsSinceEpoch(r.nextReview!);
    MasteryEngine.record(r, ok: true, hint: false, now: now);
    expect(r.nextReview, isNull, reason: 'long-term after the 21-day review');
  });

  test('a miss at review restarts the schedule at 1 day', () {
    final r = SkillRecord();
    answer(r, 5, ok: true, at: day1);
    answer(r, 5, ok: true, at: day2);
    final due = DateTime.fromMillisecondsSinceEpoch(r.nextReview!);
    MasteryEngine.record(r, ok: false, hint: false, now: due);
    expect(r.secure, isTrue);
    expect(r.reviewStage, 0);
    expect(DateTime.fromMillisecondsSinceEpoch(r.nextReview!).difference(due).inDays, 1);
  });

  test('demoted after 2 misses in the last 3', () {
    final r = SkillRecord();
    answer(r, 5, ok: true, at: day1);
    answer(r, 5, ok: true, at: day2);
    expect(r.secure, isTrue);
    answer(r, 2, ok: false, at: day2.add(const Duration(hours: 2)));
    expect(r.secure, isFalse);
    expect(r.nextReview, isNull);
  });

  test('adaptive difficulty: 2 misses easier, 5 correct harder', () {
    final r = SkillRecord();
    expect(MasteryEngine.difficultyDelta(r), 0);
    answer(r, 2, ok: false, at: day1);
    expect(MasteryEngine.difficultyDelta(r), -1);
    answer(r, 4, ok: true, at: day1);
    expect(MasteryEngine.difficultyDelta(r), 0);
    answer(r, 1, ok: true, at: day1);
    expect(MasteryEngine.difficultyDelta(r), 1);
  });

  test('json round trip', () {
    final r = SkillRecord();
    answer(r, 3, ok: true, at: day1);
    final back = SkillRecord.fromJson(r.toJson());
    expect(back.attempts.length, 3);
    expect(back.streakOk, 3);
  });
}
