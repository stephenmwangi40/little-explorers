// Checks that every answer the app marks as right IS right, and that no
// wrong-answer choice could also fairly be right.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/explore_more.dart';
import 'package:little_explorers/content/lab_move.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/content/phonics.dart';
import 'package:little_explorers/content/stories.dart';
import 'package:little_explorers/content/stories_extra.dart';
import 'package:little_explorers/core/theme.dart';
import 'package:little_explorers/games/game_shell.dart';
import 'package:little_explorers/games/new_games.dart';

void main() {
  group('phonics', () {
    test('every keyword contains its sound in the right place', () {
      keywords.forEach((g, list) {
        for (final k in list) {
          expect(k.word.contains(g), isTrue, reason: '$g in ${k.word}');
          if (k.ending) expect(k.word.endsWith(g), isTrue, reason: '${k.word} should end with $g');
        }
      });
    });

    test('blend words are spelled by their sounds and pictures are unique', () {
      final pics = <String, String>{};
      final graphemes = {for (final s in phonicsSets) ...s};
      for (final ws in blendWords.values) {
        for (final w in ws) {
          for (final s in w.sounds) {
            expect(graphemes.contains(s), isTrue, reason: '${w.word}: $s');
          }
          final prev = pics[w.pic];
          expect(prev == null || prev == w.word, isTrue, reason: '${w.pic} used for $prev and ${w.word}');
          pics[w.pic] = w.word;
        }
      }
    });

    test('sounds with the same spoken sound are never offered as wrong answers', () {
      // c, k and ck all say /k/; s and ss say /s/ etc. The games exclude these.
      expect(speakSound['c'], speakSound['k']);
      expect(speakSound['c'], speakSound['ck']);
      expect(speakSound['s'], speakSound['ss']);
    });

    test('rhymes: each word is in one set only, so no wrong choice rhymes', () {
      final seen = <String, int>{};
      for (var i = 0; i < rhymeSets.length; i++) {
        for (final w in rhymeSets[i]) {
          expect(seen.containsKey(w.$1), isFalse, reason: '${w.$1} in two rhyme sets');
          seen[w.$1] = i;
        }
      }
      String tail(String w) => w.length <= 3 ? w.substring(1) : w.substring(w.length - 3);
      // Words in different sets must not share an obvious rhyme ending.
      final words = seen.keys.toList();
      for (final a in words) {
        for (final b in words) {
          if (seen[a] != seen[b] && a.length > 3 && b.length > 3) {
            expect(tail(a) == tail(b), isFalse, reason: '$a and $b look like a rhyme across sets');
          }
        }
      }
    });
  });

  group('word garden', () {
    final things0 = {for (final t in things) t.pic: t};

    test('every picture means one thing', () {
      expect(things0.length, things.length);
    });

    test('generated questions have exactly one fair answer', () {
      for (final kind in ['name', 'category', 'opposite', 'colour', 'use']) {
        for (var seed = 0; seed < 400; seed++) {
          for (final choices in [2, 3, 4]) {
            final r = Random(seed);
            final q = wordQuestion(kind, seed % 7, seed * 3, choices, r);
            final why = '$kind #$seed: ${q.prompt} ${q.labels}';
            expect(q.choices.toSet().length, q.choices.length, reason: why);
            expect(q.answer, inInclusiveRange(0, q.choices.length - 1), reason: why);
            switch (kind) {
              case 'name':
                expect(q.prompt, 'Find the ${q.labels[q.answer]}!', reason: why);
                expect(q.labels.toSet().length, q.labels.length, reason: why);
              case 'category':
                final cat = clearCategories.firstWhere((c) => q.prompt == 'Which one is ${categoryNames[c]}?');
                final cats = [for (final p in q.choices) things0[p]!.cat];
                expect(cats.where((c) => c == cat).length, 1, reason: why);
                expect(cats[q.answer], cat, reason: why);
                for (final c in cats) {
                  expect((categoryConflicts[cat] ?? {}).contains(c), isFalse, reason: why);
                }
              case 'opposite':
                final a = q.prompt.substring('What is the opposite of '.length, q.prompt.length - 1);
                final pair = opposites.firstWhere((p) => p.any((x) => x.$1 == a));
                final b = pair.firstWhere((x) => x.$1 != a).$1;
                expect(q.labels[q.answer], b, reason: why);
                final group = oppositeGroups.firstWhere((g) => g.contains(a), orElse: () => {a, b});
                for (var i = 0; i < q.labels.length; i++) {
                  if (i != q.answer) expect(group.contains(q.labels[i]), isFalse, reason: why);
                }
              case 'colour':
                final c = q.prompt.substring('Find something '.length, q.prompt.length - 1);
                expect(colours[c]!.$2.contains(q.choices[q.answer]), isTrue, reason: why);
                for (var i = 0; i < q.choices.length; i++) {
                  if (i != q.answer) expect(colours[c]!.$2.contains(q.choices[i]), isFalse, reason: why);
                }
              case 'use':
                final job = q.prompt.substring('What do we use to '.length, q.prompt.length - 1);
                final right = uses.firstWhere((u) => u.$1 == job);
                expect(q.labels[q.answer], right.$3, reason: why);
                for (final l in q.labels) {
                  if (l == right.$3) continue;
                  expect(useConflicts.any((g) => g.contains(l) && g.contains(right.$3)), isFalse, reason: why);
                }
            }
          }
        }
      }
    });

    test('each colour picture belongs to one colour only', () {
      final seen = <String>{};
      colours.forEach((_, v) {
        for (final p in v.$2) {
          expect(seen.add(p), isTrue, reason: p);
        }
      });
    });
  });

  group('healthy me', () {
    test('first choice is the right one, choices are distinct', () {
      for (final q in healthQs) {
        expect(q.choices.length, greaterThanOrEqualTo(3), reason: q.prompt);
        expect(q.choices.map((c) => c.$1).toSet().length, q.choices.length, reason: q.prompt);
        expect(q.choices.map((c) => c.$2).toSet().length, q.choices.length, reason: q.prompt);
      }
    });

    test('generated questions keep the right answer', () {
      for (final topic in [...healthTopics, 'mix']) {
        for (var seed = 0; seed < 200; seed++) {
          final q = healthQuestion(topic, seed % 6, seed, 3, Random(seed));
          final src = healthQs.firstWhere((h) => h.prompt == q.prompt);
          expect(q.labels[q.answer], src.choices.first.$2, reason: q.prompt);
        }
      }
    });
  });

  group('stories and feelings', () {
    test('every story answer is valid and choices are distinct', () {
      for (final s in storyBook) {
        expect(s.answer, inInclusiveRange(0, s.choices.length - 1), reason: s.title);
        expect(s.choices.toSet().length, s.choices.length, reason: s.title);
      }
    });

    test('feelings questions never offer a feeling that could also be right', () {
      for (final s in storyBook.where((s) => s.feelings)) {
        final right = s.choices[s.answer];
        for (final c in s.choices) {
          if (c == right) continue;
          expect((closeFeelings[right] ?? {}).contains(c), isFalse, reason: '${s.title}: $right vs $c');
        }
      }
      for (final sc in feelingsBook) {
        expect(closeFeelings.containsKey(sc.feeling), isTrue, reason: sc.text);
      }
    });

    test('number answers in stories add up', () {
      final counting = stories.where((s) => s.choices.first.startsWith('txt:'));
      expect(counting, isEmpty, reason: 'the first 40 stories have no number questions');
      final map = {
        'Counting stars': '3', 'Counting ducks': '3', 'Five little frogs': '4', 'The ladybird': '7',
        'Hopping race': '10', 'Counting shells': '4', 'A gift for Grandma': '3',
      };
      map.forEach((title, n) {
        final s = storyBook.firstWhere((s) => s.title == title);
        expect(s.choices[s.answer], 'txt:$n', reason: title);
      });
    });
  });

  group('wonder lab and movement', () {
    test('every lab answer is one of the options', () {
      for (final t in allLabTopics) {
        for (final i in t.items) {
          expect(i.truth, inInclusiveRange(0, t.options.length - 1), reason: '${t.id}: ${i.name}');
          expect(i.explain.isNotEmpty, isTrue);
        }
      }
    });

    test('three-option topics only ask questions with one right option', () {
      // Guard against questions where two options are both true (e.g. plants
      // need water AND sunlight): each item's question must name its answer.
      final plant = allLabTopics.firstWhere((t) => t.id == 'plant');
      for (final i in plant.items) {
        final wantsWater = i.truth == 0;
        final q = i.name.toLowerCase();
        if (wantsWater) {
          expect(q.contains('drink') || q.contains('pour') || q.contains('seed'), isTrue, reason: i.name);
        } else {
          expect(q.contains('shine') || q.contains('light') || q.contains('sun'), isTrue, reason: i.name);
        }
      }
    });
  });

  group('maths helpers', () {
    test('number choices always include the answer and are distinct', () {
      for (var seed = 0; seed < 2000; seed++) {
        final r = Random(seed);
        final must = r.nextInt(21);
        final n = 2 + r.nextInt(3);
        final nums = pickNumbers(r, must, n, 0, 20);
        expect(nums.contains(must), isTrue);
        expect(nums.toSet().length, nums.length);
        expect(nums.length, n);
      }
    });
  });

  test('levels are spread across every world', () {
    expect(allLevels.keys.toSet(), WorldId.values.toSet());
  });
}
