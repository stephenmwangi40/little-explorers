/// Systematic phonics content. Letter SOUNDS first, in a fixed order.
/// set 1 s a t p i n; set 2 m d g o c k; set 3 ck e u r; set 4 h b f l;
/// set 5 ss ff ll; set 6 sh ch th ng.
library;

const phonicsSets = [
  ['s', 'a', 't', 'p', 'i', 'n'],
  ['m', 'd', 'g', 'o', 'c', 'k'],
  ['ck', 'e', 'u', 'r'],
  ['h', 'b', 'f', 'l'],
  ['ss', 'ff', 'll'],
  ['sh', 'ch', 'th', 'ng'],
];

/// Graphemes taught up to and including [set] (1-based).
List<String> taughtUpTo(int set) => [for (var i = 0; i < set; i++) ...phonicsSets[i]];

int setOf(String g) => phonicsSets.indexWhere((s) => s.contains(g)) + 1;

/// How the narrator should SAY a sound (text-to-speech cannot read /a/).
const speakSound = {
  's': 'sss', 'a': 'ah', 't': 'tuh', 'p': 'puh', 'i': 'ih', 'n': 'nnn',
  'm': 'mmm', 'd': 'duh', 'g': 'guh', 'o': 'oh', 'c': 'kuh', 'k': 'kuh',
  'ck': 'kuh', 'e': 'eh', 'u': 'uh', 'r': 'rrr', 'h': 'huh', 'b': 'buh',
  'f': 'fff', 'l': 'lll', 'ss': 'sss', 'ff': 'fff', 'll': 'lll',
  'sh': 'shh', 'ch': 'chuh', 'th': 'thh', 'ng': 'ng',
};

class Keyword {
  final String word;
  final String pic;
  final bool ending; // the sound is at the end (ck, ss, ff, ll, ng)
  const Keyword(this.word, this.pic, {this.ending = false});
}

/// A keyword picture for each sound. "apple" uses Tiko's painted apple.
const keywords = <String, List<Keyword>>{
  's': [Keyword('sun', '☀️'), Keyword('sock', '🧦'), Keyword('snail', '🐌')],
  'a': [Keyword('apple', 'apple'), Keyword('ant', '🐜'), Keyword('alligator', '🐊')],
  't': [Keyword('tent', '⛺'), Keyword('tiger', '🐯'), Keyword('tomato', '🍅')],
  'p': [Keyword('pig', '🐷'), Keyword('pan', 'pan'), Keyword('penguin', '🐧')],
  'i': [Keyword('insect', '🐞'), Keyword('in', '📥'), Keyword('itch', '🦟')],
  'n': [Keyword('nest', '🪺'), Keyword('nose', '👃'), Keyword('net', 'net')],
  'm': [Keyword('moon', '🌙'), Keyword('mouse', '🐭'), Keyword('monkey', '🐵')],
  'd': [Keyword('dog', '🐶'), Keyword('duck', '🦆'), Keyword('drum', '🥁')],
  'g': [Keyword('goat', '🐐'), Keyword('gift', '🎁'), Keyword('guitar', '🎸')],
  'o': [Keyword('octopus', '🐙'), Keyword('otter', '🦦'), Keyword('olive', '🫒')],
  'c': [Keyword('cat', '🐱'), Keyword('carrot', '🥕'), Keyword('cup', '☕')],
  'k': [Keyword('kite', '🪁'), Keyword('key', '🔑'), Keyword('kangaroo', '🦘')],
  'ck': [Keyword('duck', '🦆', ending: true), Keyword('sock', '🧦', ending: true), Keyword('rock', '🪨', ending: true)],
  'e': [Keyword('egg', '🥚'), Keyword('elephant', '🐘'), Keyword('elf', '🧝')],
  'u': [Keyword('umbrella', '☂️'), Keyword('up', '⬆️'), Keyword('under', '⬇️')],
  'r': [Keyword('rabbit', '🐰'), Keyword('rain', '🌧️'), Keyword('rocket', '🚀')],
  'h': [Keyword('hat', '🎩'), Keyword('horse', '🐴'), Keyword('house', '🏠')],
  'b': [Keyword('bus', '🚌'), Keyword('ball', '⚽'), Keyword('banana', '🍌')],
  'f': [Keyword('fish', '🐟'), Keyword('fox', '🦊'), Keyword('frog', '🐸')],
  'l': [Keyword('lion', '🦁'), Keyword('leaf', '🍃'), Keyword('lemon', '🍋')],
  'ss': [Keyword('dress', '👗', ending: true), Keyword('kiss', '💋', ending: true), Keyword('grass', '🌱', ending: true)],
  'ff': [Keyword('cliff', '🏔️', ending: true), Keyword('puff', '💨', ending: true), Keyword('sniff', '👃', ending: true)],
  'll': [Keyword('bell', '🔔', ending: true), Keyword('doll', '🪆', ending: true), Keyword('shell', '🐚', ending: true)],
  'sh': [Keyword('ship', '🚢'), Keyword('shell', '🐚'), Keyword('shoe', '👟')],
  'ch': [Keyword('chick', '🐥'), Keyword('cheese', '🧀'), Keyword('cherry', '🍒')],
  'th': [Keyword('thumb', '👍'), Keyword('three', '3️⃣'), Keyword('thunder', '⛈️')],
  'ng': [Keyword('ring', '💍', ending: true), Keyword('king', '👑', ending: true), Keyword('swing', '🛝', ending: true)],
};

class BlendWord {
  final List<String> sounds;
  final String pic;
  const BlendWord(this.sounds, this.pic);
  String get word => sounds.join();
}

/// Decodable words that use only graphemes from the listed set or earlier.
const blendWords = <int, List<BlendWord>>{
  1: [
    BlendWord(['p', 'a', 'n'], 'pan'), BlendWord(['p', 'i', 'n'], 'pin'), BlendWord(['t', 'a', 'p'], '🚰'),
    BlendWord(['t', 'i', 'n'], '🥫'), BlendWord(['a', 'n', 't'], '🐜'), BlendWord(['n', 'a', 'p'], '😴'),
    BlendWord(['s', 'i', 't'], '🪑'), BlendWord(['p', 'a', 't'], '🫳'), BlendWord(['s', 'a', 't'], '🧘'),
  ],
  2: [
    BlendWord(['d', 'o', 'g'], '🐶'), BlendWord(['c', 'a', 't'], '🐱'), BlendWord(['p', 'i', 'g'], '🐷'),
    BlendWord(['m', 'o', 'p'], '🧹'), BlendWord(['m', 'a', 'p'], '🗺️'), BlendWord(['d', 'i', 'g'], '⛏️'),
    BlendWord(['c', 'a', 'p'], '🧢'), BlendWord(['p', 'o', 't'], '🍲'), BlendWord(['k', 'i', 'd'], '🧒'),
    BlendWord(['d', 'o', 't'], '⚫'), BlendWord(['c', 'o', 't'], '🛏️'), BlendWord(['t', 'o', 'p'], '🔝'),
  ],
  3: [
    BlendWord(['n', 'e', 't'], 'net'), BlendWord(['p', 'e', 'n'], '🖊️'), BlendWord(['r', 'e', 'd'], '🔴'),
    BlendWord(['r', 'u', 'n'], '🏃'), BlendWord(['c', 'u', 'p'], '☕'), BlendWord(['s', 'u', 'n'], '☀️'),
    BlendWord(['r', 'a', 't'], '🐀'), BlendWord(['n', 'u', 't'], '🥜'), BlendWord(['t', 'e', 'n'], '🔟'),
    BlendWord(['d', 'u', 'ck'], '🦆'), BlendWord(['s', 'o', 'ck'], '🧦'), BlendWord(['r', 'o', 'ck'], '🪨'),
  ],
  4: [
    BlendWord(['b', 'e', 'd'], '🛏️'), BlendWord(['b', 'u', 's'], '🚌'), BlendWord(['h', 'a', 't'], '🎩'),
    BlendWord(['h', 'e', 'n'], '🐔'), BlendWord(['f', 'a', 'n'], '🪭'), BlendWord(['l', 'o', 'g'], '🪵'),
    BlendWord(['l', 'e', 'g'], '🦵'), BlendWord(['b', 'a', 'g'], '👜'), BlendWord(['b', 'a', 't'], '🦇'),
    BlendWord(['b', 'u', 'g'], '🐛'), BlendWord(['h', 'u', 't'], '🛖'), BlendWord(['l', 'i', 'p'], '👄'),
  ],
  5: [
    BlendWord(['b', 'e', 'll'], '🔔'), BlendWord(['d', 'o', 'll'], '🪆'), BlendWord(['h', 'i', 'll'], '⛰️'),
    BlendWord(['k', 'i', 'ss'], '💋'), BlendWord(['m', 'e', 'ss'], '🫠'), BlendWord(['p', 'u', 'ff'], '💨'),
    BlendWord(['c', 'u', 'ff'], '👔'), BlendWord(['f', 'i', 'll'], '🫗'),
  ],
  6: [
    BlendWord(['sh', 'i', 'p'], '🚢'), BlendWord(['f', 'i', 'sh'], '🐟'), BlendWord(['ch', 'i', 'p'], '🍟'),
    BlendWord(['r', 'i', 'ng'], '💍'), BlendWord(['k', 'i', 'ng'], '👑'), BlendWord(['b', 'a', 'th'], '🛁'),
    BlendWord(['sh', 'e', 'll'], '🐚'), BlendWord(['ch', 'i', 'n'], '🧔'), BlendWord(['m', 'o', 'th'], '🦋'),
    BlendWord(['d', 'i', 'sh'], '🍽️'), BlendWord(['ch', 'o', 'p'], '🪓'),
  ],
};
