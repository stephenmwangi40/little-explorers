import '../core/theme.dart';
import 'lab_move.dart';
import 'phonics.dart';
import 'stories.dart';

enum GameType {
  letterSound,
  trace,
  blend,
  count,
  quickLook,
  compare,
  makeN,
  numeral,
  shapeSort,
  pattern,
  shapeFind,
  size,
  story,
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

const levelsPerWorld = 40;

/// Free tier: the daily adventure plus this many levels in each world.
const freeLevelsPerWorld = 1;

final Map<WorldId, List<Level>> allLevels = {
  WorldId.alpha: _letters(),
  WorldId.math: _math(),
  WorldId.shapes: _shapes(),
  WorldId.story: _stories(),
  WorldId.lab: _lab(),
  WorldId.move: _move(),
};

Level? levelById(String id) {
  for (final l in allLevels.values) {
    for (final lv in l) {
      if (lv.id == id) return lv;
    }
  }
  return null;
}

// ---------------------------------------------------------------- letters

List<Level> _letters() {
  final out = <Level>[];
  final taught = <String>[];
  void add(String title, GameType t, String skill, Map<String, Object> p, String sticker) {
    final n = out.length + 1;
    out.add(Level(WorldId.alpha, n, title, t, skill, (n - 1) ~/ 8, p, sticker));
  }

  void snd(List<String> gs, {String? title}) {
    for (final g in gs) {
      if (!taught.contains(g)) taught.add(g);
    }
    add(title ?? gs.map((g) => '/$g/').join(' & ') + (gs.length == 1 ? ' sound' : ''), GameType.letterSound,
        'snd_${gs.first}', {'targets': gs, 'taught': List<String>.from(taught)}, 'txt:${gs.first}');
  }

  void tr(String l) => add('Trace $l', GameType.trace, 'trace_$l', {'letter': l}, 'txt:$l');

  void blend({int? maxSet}) {
    final pool = [
      for (final ws in blendWords.values)
        for (final w in ws)
          if (w.sounds.every(taught.contains)) w
    ];
    // Words that use the newest sounds first.
    int newest(BlendWord w) => w.sounds.map(taught.indexOf).reduce((a, b) => a > b ? a : b);
    pool.sort((a, b) => newest(b).compareTo(newest(a)));
    final words = pool.map((w) => w.word).toSet().toList();
    final first = words.take(2).join(', ');
    add('Blend $first…', GameType.blend, 'blend_${setOf(taught.last)}', {'taught': List<String>.from(taught)},
        pool.isEmpty ? '🔤' : pool.first.pic);
  }

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
  assert(out.length == levelsPerWorld);
  return out;
}

// ---------------------------------------------------------------- math

List<Level> _math() {
  const fruit = ['orange', 'apple', '🍓', '🍌', '🍐', '🥕', '🐞', '🐟', '⭐', '🍪'];
  final spec = <List<Object>>[
    ['count', 3, 'scatter'], ['numeral', 3], ['count', 3, 'line'], ['compare', 'more', 4], ['quick', 3],
    ['count', 5, 'scatter'], ['numeral', 5], ['compare', 'more', 5], ['count', 5, 'line'], ['quick', 4],
    ['count', 5, 'array'], ['compare', 'fewer', 5], ['make', 5], ['count', 6, 'scatter'], ['quick', 5],
    ['numeral', 7], ['count', 7, 'line'], ['compare', 'mixed', 6], ['make', 5], ['count', 8, 'array'],
    ['quick', 5], ['numeral', 10], ['count', 9, 'scatter'], ['compare', 'mixed', 8], ['make', 10],
    ['count', 10, 'scatter'], ['quick', 5], ['count', 10, 'array'], ['make', 10], ['compare', 'mixed', 10],
    ['numeral', 10], ['count', 10, 'line'], ['make', 5], ['quick', 5], ['make', 10],
    ['count', 10, 'scatter'], ['compare', 'mixed', 10], ['numeral', 20], ['make', 10], ['count', 10, 'array'],
  ];
  final out = <Level>[];
  for (var i = 0; i < spec.length; i++) {
    final s = spec[i];
    final n = i + 1;
    final d = i ~/ 8;
    final sticker = fruit[i % fruit.length];
    switch (s[0]) {
      case 'count':
        out.add(Level(WorldId.math, n, 'Count to ${s[1]}', GameType.count, 'count_${s[1]}', d,
            {'max': s[1], 'layout': s[2], 'item': fruit[i % fruit.length]}, sticker));
      case 'numeral':
        out.add(Level(WorldId.math, n, 'Find the number', GameType.numeral, 'numeral_${s[1]}', d,
            {'max': s[1]}, 'txt:${s[1]}'));
      case 'compare':
        final mode = s[1] as String;
        out.add(Level(WorldId.math, n, mode == 'more' ? 'More or less?' : mode == 'fewer' ? 'Which has fewer?' : 'More or fewer?',
            GameType.compare, 'compare_$mode', d, {'mode': mode, 'max': s[2]}, sticker));
      case 'quick':
        out.add(Level(WorldId.math, n, 'Quick look', GameType.quickLook, 'subitise', d, {'max': s[1]}, sticker));
      case 'make':
        out.add(Level(WorldId.math, n, 'Make ${s[1]}', GameType.makeN, 'make_${s[1]}', d, {'target': s[1]}, 'txt:${s[1]}'));
    }
  }
  assert(out.length == levelsPerWorld);
  return out;
}

// ---------------------------------------------------------------- shapes

List<Level> _shapes() {
  const titles = {
    GameType.shapeSort: 'Shape homes',
    GameType.pattern: 'What comes next?',
    GameType.shapeFind: 'Shape hunt',
    GameType.size: 'Big & small',
  };
  const kinds = ['circle', 'triangle', 'square', 'rectangle', 'circle', 'triangle', 'square', 'star'];
  const patterns = ['AB', 'ABB', 'AAB', 'ABC', 'AABB'];
  final slots = [
    GameType.shapeSort, GameType.pattern, GameType.shapeFind, GameType.shapeSort,
    GameType.size, GameType.pattern, GameType.shapeFind, GameType.pattern,
  ];
  final out = <Level>[];
  for (var i = 0; i < levelsPerWorld; i++) {
    final d = i ~/ 8;
    final t = slots[i % 8];
    final n = i + 1;
    final p = <String, Object>{};
    var title = titles[t]!;
    var skill = 'shapes';
    switch (t) {
      case GameType.shapeSort:
        p['rotate'] = d > 0 || i % 8 == 3;
        p['four'] = d >= 1;
        p['star'] = d >= 3;
        if (i % 8 == 3) title = 'Turned shapes';
        skill = 'shape_sort';
      case GameType.pattern:
        final pat = patterns[(d + (i % 8 == 7 ? 1 : 0)).clamp(0, 4)];
        p['pattern'] = pat;
        p['fruit'] = i % 8 == 5;
        if (i % 8 == 7) title = 'Pattern puzzle';
        skill = 'pattern_${pat.toLowerCase()}';
      case GameType.shapeFind:
        final k = kinds[(i ~/ 2) % kinds.length];
        p['target'] = k;
        p['choices'] = 3 + (d >= 2 ? 1 : 0);
        title = 'Find the $k';
        skill = 'shape_find';
      case GameType.size:
        p['ask'] = d.isEven ? 'bigger' : 'smaller';
        p['choices'] = d >= 2 ? 3 : 2;
        title = d.isEven ? 'Which is bigger?' : 'Which is smaller?';
        skill = 'size';
      default:
        break;
    }
    out.add(Level(WorldId.shapes, n, title, t, skill, d, p,
        'shape:${kinds[i % kinds.length]}:${['FFEF476F', 'FF4DA3FF', 'FFFFD166', 'FF3DBE7A'][i % 4]}'));
  }
  return out;
}

// ---------------------------------------------------------------- story

List<Level> _stories() => [
      for (var i = 0; i < stories.length; i++)
        Level(WorldId.story, i + 1, stories[i].title, GameType.story,
            stories[i].feelings ? 'story_feel' : 'story_detail', i ~/ 8, {'story': i}, stories[i].scene.first),
    ];

// ---------------------------------------------------------------- lab

List<Level> _lab() {
  const counts = {'float': 5, 'magnet': 4, 'hot': 4, 'day': 4, 'plant': 5, 'light': 4, 'weather': 5, 'homes': 5, 'senses': 4};
  final used = {for (final k in counts.keys) k: 0};
  final out = <Level>[];
  var t = 0;
  while (out.length < levelsPerWorld) {
    final topic = labTopics[t % labTopics.length];
    t++;
    if (used[topic.id]! >= counts[topic.id]!) continue;
    final k = used[topic.id]!;
    used[topic.id] = k + 1;
    final n = out.length + 1;
    out.add(Level(WorldId.lab, n, topic.title, GameType.lab, 'lab_${topic.id}', (n - 1) ~/ 8,
        {'topic': topic.id, 'offset': k * 2}, topic.items[(k * 2) % topic.items.length].pic));
  }
  return out;
}

// ---------------------------------------------------------------- move

List<Level> _move() => [
      for (var i = 0; i < levelsPerWorld; i++)
        Level(WorldId.move, i + 1, moves[(i * 2) % moves.length].name, GameType.move, 'move', i ~/ 8, {
          'moves': [(i * 2) % moves.length, (i * 2 + 1) % moves.length],
          'reps': 3 + i ~/ 8,
        }, moves[(i * 2) % moves.length].pic),
    ];
