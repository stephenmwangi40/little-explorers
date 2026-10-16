import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/lab_move.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/content/phonics.dart';
import 'package:little_explorers/content/stories_more.dart';
import 'package:little_explorers/core/theme.dart';

void main() {
  test('960 levels: 160 in every world, unique ids, numbered in order', () {
    final ids = <String>{};
    for (final w in WorldId.values) {
      final ls = allLevels[w]!;
      expect(ls.length, 160, reason: w.name);
      for (var i = 0; i < ls.length; i++) {
        expect(ls[i].number, i + 1);
        expect(ids.add(ls[i].id), isTrue, reason: 'duplicate ${ls[i].id}');
        expect(ls[i].difficulty, inInclusiveRange(0, 4));
      }
    }
    expect(ids.length, 960);
  });

  test('phonics follows the systematic order s a t p i n first', () {
    final first = allLevels[WorldId.alpha]!.where((l) => l.type == GameType.letterSound).first;
    expect((first.p['targets'] as List).first, 's');
    expect(phonicsSets.first, ['s', 'a', 't', 'p', 'i', 'n']);
  });

  test('every grapheme has a spoken sound and keywords that contain it', () {
    for (final s in phonicsSets) {
      for (final g in s) {
        expect(speakSound[g], isNotNull, reason: g);
        for (final k in keywords[g]!) {
          expect(k.word.contains(g), isTrue, reason: '$g in ${k.word}');
        }
      }
    }
  });

  test('blend levels only use taught sounds and have enough words', () {
    for (final l in allLevels[WorldId.alpha]!.where((l) => l.type == GameType.blend)) {
      final taught = (l.p['taught'] as List).cast<String>();
      final only = l.p['only'] as int?;
      final pool = only != null
          ? blendWords[only]!
          : [for (final ws in blendWords.values) ...ws.where((w) => w.sounds.every(taught.contains))];
      expect(pool.map((w) => w.pic).toSet().length, greaterThanOrEqualTo(3), reason: l.title);
      for (final w in pool) {
        expect(w.sounds.every(taught.contains), isTrue, reason: '${w.word} in ${l.title}');
      }
    }
  });

  test('every letter-sound level has distractors', () {
    for (final l in allLevels[WorldId.alpha]!.where((l) => l.type == GameType.letterSound)) {
      final taught = (l.p['taught'] as List).cast<String>();
      for (final t in (l.p['targets'] as List).cast<String>()) {
        expect(keywords[t], isNotNull, reason: t);
        final all = {...taught, ...phonicsSets[setOf(t) - 1]};
        expect(all.where((g) => speakSound[g] != speakSound[t]), isNotEmpty, reason: t);
      }
    }
  });

  test('all 26 capital letters are traced; sight words and rhymes valid', () {
    final traced = allLevels[WorldId.alpha]!.where((l) => l.type == GameType.trace).map((l) => l.p['letter']).toSet();
    for (final c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {
      expect(traced.contains(c), isTrue, reason: c);
    }
    for (final l in allLevels[WorldId.alpha]!.where((l) => l.type == GameType.sightWord)) {
      final words = (l.p['words'] as List).cast<String>();
      final known = (l.p['known'] as List).cast<String>();
      expect(words.every(known.contains), isTrue, reason: l.title);
      expect(known.length, greaterThanOrEqualTo(4));
    }
    expect(rhymeSets.every((s) => s.length >= 2), isTrue);
  });

  test('stories, scenarios, lab topics and moves are valid', () {
    expect(allStories.length, 120);
    for (final s in allStories) {
      expect(s.answer, inInclusiveRange(0, s.choices.length - 1), reason: s.title);
    }
    expect(scenarios.length, greaterThanOrEqualTo(40));
    expect(allLabTopics.length, 20);
    for (final t in allLabTopics) {
      for (final i in t.items) {
        expect(i.truth, inInclusiveRange(0, t.options.length - 1), reason: '${t.id} ${i.name}');
      }
      expect(t.options.length, t.optionLabels.length);
    }
    for (final l in allLevels[WorldId.move]!) {
      final ms = (l.p['moves'] as List).cast<int>();
      expect(ms.every((m) => m >= 0 && m < moves.length), isTrue);
      expect(ms[0] != ms[1], isTrue, reason: l.title);
    }
  });

  test('number-order levels always have a valid sequence', () {
    for (final l in allLevels[WorldId.math]!.where((l) => l.type == GameType.numberOrder)) {
      final step = l.p['step'] as int, maxN = l.p['max'] as int;
      expect(maxN ~/ step, greaterThanOrEqualTo(5), reason: l.title);
    }
    expect(Random(1).nextInt(3), isNonNegative);
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
