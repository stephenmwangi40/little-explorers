import '../core/theme.dart';
import 'lab_move.dart';
import 'phonics.dart';
import 'stories_more.dart';

enum GameType {
  letterSound,
  trace,
  blend,
  caseMatch,
  sightWord,
  rhyme,
  count,
  quickLook,
  compare,
  makeN,
  numeral,
  addSub,
  numberOrder,
  compareNumbers,
  shapeSort,
  pattern,
  shapeFind,
  size,
  solid,
  position,
  shapeCount,
  story,
  feelings,
  lab,
  move,
}

class Level {
  final WorldId world;
  final int number; // 1-based
  final String title;
  final GameType type;
  final String skill;
  final int difficulty; // 0 easiest .. 4 stretch
  final Map<String, Object> p;
  final String sticker; // picture id (see Pic)

  const Level(this.world, this.number, this.title, this.type, this.skill, this.difficulty, this.p, this.sticker);

  String get id => '${world.name}_$number';
}

/// 160 levels in each of 6 worlds = 960 levels.
const levelsPerWorld = 160;

/// Free tier: the daily adventure plus this many levels in each world.
const freeLevelsPerWorld = 1;

int _difficulty(int n) => ((n - 1) * 5) ~/ levelsPerWorld; // 0..4

final Map<WorldId, List<Level>> allLevels = {
  WorldId.alpha: _letters(),
  WorldId.math: _math(),
  WorldId.shapes: _shapes(),
  WorldId.story: _stories(),
  WorldId.lab: _lab(),
  WorldId.move: _move(),
};

final Map<String, Level> _byId = {
  for (final ls in allLevels.values)
    for (final l in ls) l.id: l,
};

Level? levelById(String id) => _byId[id];

/// Takes items from several queues in turn until all are empty.
List<T> _interleave<T>(List<List<T>> queues) {
  final out = <T>[];
  final idx = List.filled(queues.length, 0);
  var any = true;
  while (any) {
    any = false;
    for (var q = 0; q < queues.length; q++) {
      if (idx[q] < queues[q].length) {
        out.add(queues[q][idx[q]++]);
        any = true;
      }
    }
  }
  return out;
}

// ---------------------------------------------------------------- letters

List<Level> _letters() {
  final out = <Level>[];
  final taught = <String>[];
  void add(String title, GameType t, String skill, Map<String, Object> p, String sticker) {
    final n = out.length + 1;
    out.add(Level(WorldId.alpha, n, title, t, skill, _difficulty(n), p, sticker));
  }

  void snd(List<String> gs, {String? title}) {
    for (final g in gs) {
      if (!taught.contains(g)) taught.add(g);
    }
    add(title ?? gs.map((g) => '/$g/').join(' & ') + (gs.length == 1 ? ' sound' : ''), GameType.letterSound,
        'snd_${gs.first}', {'targets': gs, 'taught': List<String>.from(taught)}, 'txt:${gs.first}');
  }

  void tr(String l) => add(
      l.toUpperCase() == l ? 'Trace big $l' : 'Trace $l', GameType.trace, 'trace_${l.toLowerCase()}', {'letter': l}, 'txt:$l');

  void blend({int? only}) {
    final pool = only != null
        ? blendWords[only]!
        : [
            for (final ws in blendWords.values)
              for (final w in ws)
                if (w.sounds.every(taught.contains)) w
          ];
    int newest(BlendWord w) => w.sounds.map(taught.indexOf).reduce((a, b) => a > b ? a : b);
    final sorted = [...pool];
    if (only == null) sorted.sort((a, b) => newest(b).compareTo(newest(a)));
    final first = sorted.map((w) => w.word).toSet().take(2).join(', ');
    add('Blend $first…', GameType.blend, only == 9 ? 'blend_cc' : 'blend_${setOf(taught.last)}',
        {'taught': List<String>.from(taught), 'only': ?only}, sorted.first.pic);
  }

  // Sets 1-6 (levels 1-40).
  snd(['s']);
  snd(['a']);
  tr('s');
  tr('a');
  snd(['t', 'p']);
  tr('t');
  tr('p');
  blend();
  snd(['i', 'n']);
  tr('i');
  tr('n');
  blend();
  snd(phonicsSets[0], title: 'Sound check: s a t p i n');
  snd(['m', 'd']);
  tr('m');
  tr('d');
  snd(['g', 'o']);
  tr('g');
  tr('o');
  blend();
  snd(['c', 'k']);
  tr('c');
  tr('k');
  blend();
  snd(['ck', 'e']);
  tr('e');
  snd(['u', 'r']);
  tr('u');
  tr('r');
  blend();
  snd(['h', 'b']);
  tr('h');
  tr('b');
  snd(['f', 'l']);
  tr('f');
  tr('l');
  blend();
  snd(['ss', 'ff', 'll'], title: 'Double letters: ss ff ll');
  snd(['sh', 'ch', 'th', 'ng'], title: 'Two letters, one sound: sh ch th ng');
  blend();

  // Set 7 (levels 41-52).
  snd(['j', 'v']);
  tr('j');
  tr('v');
  snd(['w', 'x']);
  tr('w');
  tr('x');
  snd(['y', 'z']);
  tr('y');
  tr('z');
  snd(['qu']);
  blend();
  snd(phonicsSets[6], title: 'Sound check: j v w x y z qu');

  // Set 8 vowel teams (levels 53-62).
  for (final pair in const [
    ['ai', 'ee'],
    ['igh', 'oa'],
    ['oo', 'ar'],
    ['or', 'ur'],
    ['ow', 'oi'],
  ]) {
    snd(pair);
    blend();
  }

  // Levels 63-160: capitals, tricky words, rhymes, longer words and review.
  final mixed = <void Function()>[];
  final upper = [for (final c in 'abcdefghijklmnopqrstuvwxyz'.split('')) () => tr(c.toUpperCase())];
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  final cases = [
    for (var i = 0; i < 13; i++)
      () => add('Big and small letters', GameType.caseMatch, 'case',
          {'letters': alphabet.substring(i * 2, (i * 2 + 4).clamp(0, 26)).split('')}, 'txt:${alphabet[i * 2].toUpperCase()}'),
  ];
  final rhymes = [
    for (var i = 0; i < 16; i++) () => add('Rhyme time', GameType.rhyme, 'rhyme', {'offset': i * 3}, rhymeSets[(i * 3) % rhymeSets.length].first.$2),
  ];
  final sight = [
    for (var i = 0; i < 20; i++)
      () {
        final words = sightWords.sublist((i * 2).clamp(0, sightWords.length - 2), (i * 2 + 3).clamp(0, sightWords.length));
        final known = sightWords.sublist(0, (i * 2 + 6).clamp(6, sightWords.length));
        add('Tricky words: ${words.take(2).join(', ')}', GameType.sightWord, 'sight', {'words': words, 'known': known},
            'txt:${words.first}');
      },
  ];
  final longer = [for (var i = 0; i < 12; i++) () => blend(only: 9)];
  final review = [
    for (var i = 0; i < 11; i++)
      () => add(i < 8 ? 'Sound check: set ${i + 1}' : 'All my sounds', GameType.letterSound, 'snd_review',
          {'targets': i < 8 ? phonicsSets[i] : [for (final s in phonicsSets) ...s], 'taught': List<String>.from(taught)},
          'txt:${phonicsSets[i % 8].first}'),
  ];
  mixed.addAll(_interleave([upper, sight, rhymes, cases, longer, review]));
  for (final f in mixed) {
    f();
  }
  assert(out.length == levelsPerWorld, 'letters: ${out.length}');
  return out;
}

// ---------------------------------------------------------------- math

List<Level> _math() {
  const fruit = ['orange', 'apple', '🍓', '🍌', '🍐', '🥕', '🐞', '🐟', '⭐', '🍪'];
  final spec = <List<Object>>[
    // Phase 1: counting to 10, comparing, quick look, make 5/10.
    ['count', 3, 'scatter'], ['numeral', 3], ['count', 3, 'line'], ['compare', 'more', 4], ['quick', 3],
    ['count', 5, 'scatter'], ['numeral', 5], ['compare', 'more', 5], ['count', 5, 'line'], ['quick', 4],
    ['count', 5, 'array'], ['compare', 'fewer', 5], ['make', 5], ['count', 6, 'scatter'], ['quick', 5],
    ['numeral', 7], ['count', 7, 'line'], ['compare', 'mixed', 6], ['make', 5], ['count', 8, 'array'],
    ['quick', 5], ['numeral', 10], ['count', 9, 'scatter'], ['compare', 'mixed', 8], ['make', 10],
    ['count', 10, 'scatter'], ['quick', 5], ['count', 10, 'array'], ['make', 10], ['compare', 'mixed', 10],
    ['numeral', 10], ['count', 10, 'line'], ['make', 5], ['quick', 5], ['make', 10],
    ['count', 10, 'scatter'], ['compare', 'mixed', 10], ['numeral', 20], ['make', 10], ['count', 10, 'array'],
  ];
  // Phase 2: teens, adding and taking away to 5, number order.
  for (var k = 0; k < 5; k++) {
    spec.addAll([
      ['count', 11 + k * 2, 'array'], ['addsub', 'add', 5], ['order', 'next', 1, 20], ['cmpnum', 10],
      ['count', 12 + k * 2, 'array'], ['addsub', 'sub', 5], ['quick', 6], ['make', 10],
    ]);
  }
  // Phase 3: to 10, skip counting by 2s, numbers to 20.
  for (var k = 0; k < 5; k++) {
    spec.addAll([
      ['addsub', 'add', 10], ['addsub', 'sub', 10], ['order', 'missing', 1, 20], ['order', 'next', 2, 20],
      ['cmpnum', 20], ['count', 20, 'array'], ['numeral', 20], ['addsub', 'mix', 10],
    ]);
  }
  // Phase 4: to 20, counting by 5s and 10s.
  for (var k = 0; k < 5; k++) {
    spec.addAll([
      ['addsub', 'add', 20], ['order', 'next', 5, 50], ['addsub', 'sub', 20], ['order', 'next', 10, 100],
      ['make', 10], ['addsub', 'mix', 20], ['order', 'missing', 2, 40], ['cmpnum', 50],
    ]);
  }
  final out = <Level>[];
  for (var i = 0; i < spec.length; i++) {
    final s = spec[i];
    final n = i + 1;
    final d = _difficulty(n);
    final sticker = fruit[i % fruit.length];
    final level = switch (s[0]) {
      'count' => Level(WorldId.math, n, 'Count to ${s[1]}', GameType.count, 'count_${s[1]}', d,
          {'max': s[1], 'layout': (s[1] as int) > 10 ? 'array' : s[2], 'item': fruit[i % fruit.length]}, sticker),
      'numeral' => Level(WorldId.math, n, 'Find the number', GameType.numeral, 'numeral_${s[1]}', d, {'max': s[1]}, 'txt:${s[1]}'),
      'compare' => Level(
          WorldId.math,
          n,
          s[1] == 'more' ? 'More or less?' : s[1] == 'fewer' ? 'Which has fewer?' : 'More or fewer?',
          GameType.compare,
          'compare_${s[1]}',
          d,
          {'mode': s[1], 'max': s[2]},
          sticker),
      'quick' => Level(WorldId.math, n, 'Quick look', GameType.quickLook, 'subitise', d, {'max': s[1]}, sticker),
      'make' => Level(WorldId.math, n, 'Make ${s[1]}', GameType.makeN, 'make_${s[1]}', d, {'target': s[1]}, 'txt:${s[1]}'),
      'addsub' => Level(
          WorldId.math,
          n,
          '${s[1] == 'add' ? 'Adding' : s[1] == 'sub' ? 'Taking away' : 'Add or take away'} to ${s[2]}',
          GameType.addSub,
          '${s[1] == 'sub' ? 'subtract' : 'add'}_${s[2]}',
          d,
          {'op': s[1], 'max': s[2]},
          s[1] == 'sub' ? 'txt:−' : 'txt:+'),
      'order' => Level(
          WorldId.math,
          n,
          s[2] == 1 ? 'Number line to ${s[3]}' : 'Count by ${s[2]}s',
          GameType.numberOrder,
          s[2] == 1 ? 'order' : 'skip_${s[2]}',
          d,
          {'mode': s[1], 'step': s[2], 'max': s[3], 'back': s[1] == 'missing'},
          'txt:${s[2]}'),
      _ => Level(WorldId.math, n, 'Bigger number to ${s[1]}', GameType.compareNumbers, 'compare_numbers', d,
          {'max': s[1]}, 'txt:${s[1]}'),
    };
    out.add(level);
  }
  assert(out.length == levelsPerWorld, 'math: ${out.length}');
  return out;
}

// ---------------------------------------------------------------- shapes

List<Level> _shapes() {
  const kinds = ['circle', 'triangle', 'square', 'rectangle', 'circle', 'triangle', 'square', 'star'];
  const patterns = ['AB', 'ABB', 'AAB', 'ABC', 'AABB'];
  final slots = [
    GameType.shapeSort, GameType.pattern, GameType.shapeFind, GameType.solid,
    GameType.size, GameType.position, GameType.pattern, GameType.shapeCount,
  ];
  final out = <Level>[];
  for (var i = 0; i < levelsPerWorld; i++) {
    final n = i + 1;
    final d = _difficulty(n);
    final t = slots[i % 8];
    final cycle = i ~/ 8;
    final p = <String, Object>{};
    var title = '';
    var skill = '';
    switch (t) {
      case GameType.shapeSort:
        p['rotate'] = cycle > 0;
        p['four'] = d >= 1;
        p['star'] = d >= 3;
        title = cycle == 0 ? 'Shape homes' : 'Turned shapes';
        skill = 'shape_sort';
      case GameType.pattern:
        final pat = patterns[(d + (i % 8 == 6 ? 1 : 0) + (cycle % 2)).clamp(0, 4)];
        p['pattern'] = pat;
        p['fruit'] = cycle.isOdd;
        title = i % 8 == 6 ? 'Pattern puzzle' : 'What comes next?';
        skill = 'pattern_${pat.toLowerCase()}';
      case GameType.shapeFind:
        final k = kinds[cycle % kinds.length];
        p['target'] = k;
        p['choices'] = 3 + (d >= 2 ? 1 : 0);
        title = 'Find the $k';
        skill = 'shape_find';
      case GameType.size:
        p['ask'] = cycle.isEven ? 'bigger' : 'smaller';
        p['choices'] = d >= 2 ? 3 : 2;
        title = cycle.isEven ? 'Which is bigger?' : 'Which is smaller?';
        skill = 'size';
      case GameType.solid:
        title = '3D shapes';
        skill = 'solids';
      case GameType.position:
        title = 'On, under, next to';
        skill = 'position';
      case GameType.shapeCount:
        title = 'Count the shapes';
        skill = 'shape_count';
      default:
        break;
    }
    out.add(Level(WorldId.shapes, n, title, t, skill, d, p,
        'shape:${kinds[i % kinds.length]}:${['FFEF476F', 'FF4DA3FF', 'FFFFD166', 'FF3DBE7A'][i % 4]}'));
  }
  return out;
}

// ---------------------------------------------------------------- story

List<Level> _stories() {
  final out = <Level>[];
  var story = 0, feel = 0;
  for (var n = 1; n <= levelsPerWorld; n++) {
    // Every 4th level is a "How would you feel?" level.
    if (n % 4 == 0) {
      out.add(Level(WorldId.story, n, 'How would you feel?', GameType.feelings, 'feelings', _difficulty(n),
          {'offset': feel * 3}, scenarios[(feel * 3) % scenarios.length].pic));
      feel++;
    } else {
      final s = allStories[story];
      out.add(Level(WorldId.story, n, s.title, GameType.story, s.feelings ? 'story_feel' : 'story_detail', _difficulty(n),
          {'story': story}, s.scene.first));
      story++;
    }
  }
  return out;
}

// ---------------------------------------------------------------- lab

List<Level> _lab() {
  // Each of the 20 topics appears 8 times, spread across the world.
  final out = <Level>[];
  final per = levelsPerWorld ~/ allLabTopics.length;
  for (var round = 0; round < per; round++) {
    for (final topic in allLabTopics) {
      final n = out.length + 1;
      out.add(Level(WorldId.lab, n, topic.title, GameType.lab, 'lab_${topic.id}', _difficulty(n),
          {'topic': topic.id, 'offset': round * 3}, topic.items[(round * 3) % topic.items.length].pic));
    }
  }
  return out;
}

// ---------------------------------------------------------------- move

List<Level> _move() => [
      for (var i = 0; i < levelsPerWorld; i++)
        Level(WorldId.move, i + 1, moves[i % moves.length].name, GameType.move, 'move', _difficulty(i + 1), {
          'moves': [
            i % moves.length,
            (i * 7 + 11) % moves.length == i % moves.length ? (i + 1) % moves.length : (i * 7 + 11) % moves.length,
            if (i >= 64) (i * 13 + 5) % moves.length,
          ],
          'reps': 3 + i ~/ 40,
        }, moves[i % moves.length].pic),
    ];
