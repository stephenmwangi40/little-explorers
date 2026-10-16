import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/lab_move.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/content/phonics.dart';
import 'package:little_explorers/content/stories.dart';
import 'package:little_explorers/core/theme.dart';

void main() {
  test('every world has 40 levels (30-50 target) with unique ids', () {
    final ids = <String>{};
    for (final w in WorldId.values) {
      final ls = allLevels[w]!;
      expect(ls.length, levelsPerWorld, reason: w.name);
      for (var i = 0; i < ls.length; i++) {
        expect(ls[i].number, i + 1);
        expect(ids.add(ls[i].id), isTrue, reason: 'duplicate ${ls[i].id}');
      }
    }
    expect(ids.length, 240);
  });

  test('phonics follows the systematic order s a t p i n first', () {
    final first = allLevels[WorldId.alpha]!.where((l) => l.type == GameType.letterSound).first;
    expect((first.p['targets'] as List).first, 's');
    expect(phonicsSets.first, ['s', 'a', 't', 'p', 'i', 'n']);
  });

  test('blend levels only use taught sounds and have enough words', () {
    for (final l in allLevels[WorldId.alpha]!.where((l) => l.type == GameType.blend)) {
      final taught = (l.p['taught'] as List).cast<String>();
      final pool = [for (final ws in blendWords.values) ...ws.where((w) => w.sounds.every(taught.contains))];
      expect(pool.map((w) => w.pic).toSet().length, greaterThanOrEqualTo(3), reason: l.title);
    }
  });

  test('every keyword sound has a distractor available', () {
    for (final l in allLevels[WorldId.alpha]!.where((l) => l.type == GameType.letterSound)) {
      final taught = (l.p['taught'] as List).cast<String>();
      for (final t in (l.p['targets'] as List).cast<String>()) {
        expect(keywords[t], isNotNull, reason: t);
        final all = {...taught, ...phonicsSets[setOf(t) - 1]};
        final others = all.where((g) => speakSound[g] != speakSound[t]);
        expect(others, isNotEmpty, reason: 'no distractor for $t');
      }
    }
  });

  test('stories are valid', () {
    expect(stories.length, 40);
    for (final s in stories) {
      expect(s.answer, inInclusiveRange(0, s.choices.length - 1));
      expect(s.pages, isNotEmpty);
    }
  });

  test('lab topics and moves are valid', () {
    for (final t in labTopics) {
      for (final i in t.items) {
        expect(i.truth, inInclusiveRange(0, t.options.length - 1), reason: '${t.id} ${i.name}');
      }
      expect(t.options.length, t.optionLabels.length);
    }
    for (final l in allLevels[WorldId.move]!) {
      for (final m in (l.p['moves'] as List).cast<int>()) {
        expect(m, inInclusiveRange(0, moves.length - 1));
      }
    }
  });

  test('stickers resolve', () {
    for (final ls in allLevels.values) {
      for (final l in ls) {
        expect(l.sticker, isNotEmpty);
        expect(levelById(l.id), same(l));
      }
    }
  });
}
