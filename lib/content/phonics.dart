/// Systematic phonics content. Letter SOUNDS first, in a fixed order.
/// set 1 s a t p i n; set 2 m d g o c k; set 3 ck e u r; set 4 h b f l;
/// set 5 ss ff ll; set 6 sh ch th ng; set 7 j v w x y z qu;
/// set 8 ai ee igh oa oo ar or ur ow oi.
library;

const phonicsSets = [
  ['s', 'a', 't', 'p', 'i', 'n'],
  ['m', 'd', 'g', 'o', 'c', 'k'],
  ['ck', 'e', 'u', 'r'],
  ['h', 'b', 'f', 'l'],
  ['ss', 'ff', 'll'],
  ['sh', 'ch', 'th', 'ng'],
  ['j', 'v', 'w', 'x', 'y', 'z', 'qu'],
  ['ai', 'ee', 'igh', 'oa', 'oo', 'ar', 'or', 'ur', 'ow', 'oi'],
];

/// Graphemes taught up to and including [set] (1-based).
List<String> taughtUpTo(int set) => [for (var i = 0; i < set; i++) ...phonicsSets[i]];

int setOf(String g) => phonicsSets.indexWhere((s) => s.contains(g)) + 1;

/// How the narrator should SAY a sound (text-to-speech cannot read /a/).
const speakSound = {
  's': 'sss', 'a': 'ah', 't': 'tuh', 'p': 'puh', 'i': 'ih', 'n': 'nnn',
  'm': 'mmm', 'd': 'duh', 'g': 'guh', 'o': 'aw', 'c': 'kuh', 'k': 'kuh',
  'ck': 'kuh', 'e': 'eh', 'u': 'uh', 'r': 'rrr', 'h': 'huh', 'b': 'buh',
  'f': 'fff', 'l': 'lll', 'ss': 'sss', 'ff': 'fff', 'll': 'lll',
  'sh': 'shh', 'ch': 'chuh', 'th': 'thh', 'ng': 'ng',
  'j': 'juh', 'v': 'vvv', 'w': 'wuh', 'x': 'ks', 'y': 'yuh', 'z': 'zzz', 'qu': 'kwuh',
  'ai': 'ay', 'ee': 'ee', 'igh': 'eye', 'oa': 'oh', 'oo': 'oo', 'ar': 'ar', 'or': 'or',
  'ur': 'er', 'ow': 'ow', 'oi': 'oy',
};

class Keyword {
  final String word;
  final String pic;
  final bool ending; // the sound is at the end (ck, ss, ff, ll, ng, x)
  // Otherwise the first place the sound appears is left blank (start or middle).
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
  'j': [Keyword('jellyfish', '🪼'), Keyword('jar', '🫙'), Keyword('juice', '🧃')],
  'v': [Keyword('van', '🚐'), Keyword('violin', '🎻'), Keyword('volcano', '🌋')],
  'w': [Keyword('web', '🕸️'), Keyword('whale', '🐋'), Keyword('watch', '⌚')],
  'x': [Keyword('fox', '🦊', ending: true), Keyword('box', '📦', ending: true), Keyword('six', '6️⃣', ending: true)],
  'y': [Keyword('yo-yo', '🪀'), Keyword('yak', '🐃'), Keyword('yarn', '🧶')],
  'z': [Keyword('zebra', '🦓'), Keyword('zip', '🤐'), Keyword('zero', '0️⃣')],
  'qu': [Keyword('queen', '👸'), Keyword('question', '❓'), Keyword('quack', '🦆')],
  'ai': [Keyword('rain', '🌧️'), Keyword('snail', '🐌'), Keyword('train', '🚆')],
  'ee': [Keyword('bee', '🐝'), Keyword('tree', '🌳'), Keyword('feet', '🦶')],
  'igh': [Keyword('night', '🌃'), Keyword('light', '💡'), Keyword('flight', '✈️')],
  'oa': [Keyword('boat', '⛵'), Keyword('goat', '🐐'), Keyword('coat', '🧥')],
  'oo': [Keyword('moon', '🌙'), Keyword('boot', '👢'), Keyword('spoon', '🥄')],
  'ar': [Keyword('car', '🚗'), Keyword('star', '⭐'), Keyword('farm', '🚜')],
  'or': [Keyword('fork', '🍴'), Keyword('corn', '🌽'), Keyword('horse', '🐴')],
  'ur': [Keyword('purse', '👛'), Keyword('turtle', '🐢'), Keyword('surf', '🏄')],
  'ow': [Keyword('cow', '🐄'), Keyword('owl', '🦉'), Keyword('crown', '👑')],
  'oi': [Keyword('coin', '🪙'), Keyword('oil', '🛢️'), Keyword('point', '👉')],
};

/// Rhyming families (phonological awareness). Each entry: word, picture.
const rhymeSets = <List<(String, String)>>[
  [('cat', '🐱'), ('hat', '🎩'), ('bat', '🦇')],
  [('dog', '🐶'), ('frog', '🐸'), ('log', '🪵')],
  [('bee', '🐝'), ('tree', '🌳'), ('key', '🔑')],
  [('star', '⭐'), ('car', '🚗'), ('jar', '🫙')],
  [('mouse', '🐭'), ('house', '🏠')],
  [('bear', '🐻'), ('pear', '🍐'), ('chair', '🪑')],
  [('cake', '🎂'), ('snake', '🐍')],
  [('moon', '🌙'), ('spoon', '🥄')],
  [('goat', '🐐'), ('boat', '⛵'), ('coat', '🧥')],
  [('fish', '🐟'), ('dish', '🍽️')],
  [('bed', '🛏️'), ('bread', '🍞')],
  [('ring', '💍'), ('king', '👑')],
  [('fox', '🦊'), ('box', '📦'), ('socks', '🧦')],
  [('snow', '❄️'), ('bow', '🎀')],
  [('rain', '🌧️'), ('train', '🚆'), ('chain', '⛓️')],
  [('whale', '🐋'), ('snail', '🐌'), ('mail', '📬')],
  [('night', '🌃'), ('kite', '🪁'), ('light', '💡')],
  [('shell', '🐚'), ('bell', '🔔')],
  [('ten', '🔟'), ('hen', '🐔'), ('pen', '🖊️')],
  [('nose', '👃'), ('rose', '🌹')],
  [('clock', '🕰️'), ('sock', '🧦'), ('rock', '🪨')],
  [('sun', '☀️'), ('bun', '🥯')],
  [('mug', '☕'), ('bug', '🐛')],
  [('car', '🚗'), ('guitar', '🎸')],
];

/// Common "tricky" words, taught by sight, in order.
const sightWords = [
  'I', 'a', 'the', 'to', 'no', 'go', 'is', 'it', 'in', 'and', 'he', 'she',
  'we', 'me', 'be', 'was', 'my', 'you', 'they', 'her', 'all', 'are', 'said', 'have',
  'like', 'so', 'do', 'some', 'come', 'here', 'there', 'little', 'one', 'what', 'when', 'out',
  'see', 'look', 'can', 'up', 'down', 'big', 'play', 'yes',
];

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
  7: [
    BlendWord(['j', 'a', 'm'], '🍯'), BlendWord(['j', 'e', 't'], '✈️'), BlendWord(['v', 'a', 'n'], '🚐'),
    BlendWord(['w', 'e', 'b'], '🕸️'), BlendWord(['b', 'o', 'x'], '📦'), BlendWord(['f', 'o', 'x'], '🦊'),
    BlendWord(['s', 'i', 'x'], '6️⃣'), BlendWord(['y', 'a', 'k'], '🐃'), BlendWord(['z', 'i', 'p'], '🤐'),
    BlendWord(['qu', 'i', 'z'], '❓'), BlendWord(['qu', 'a', 'ck'], '🦆'), BlendWord(['w', 'i', 'g'], '💇'),
  ],
  8: [
    BlendWord(['r', 'ai', 'n'], '🌧️'), BlendWord(['t', 'ai', 'l'], '🐕'), BlendWord(['b', 'ee'], '🐝'),
    BlendWord(['f', 'ee', 't'], '🦶'), BlendWord(['n', 'igh', 't'], '🌃'), BlendWord(['l', 'igh', 't'], '💡'),
    BlendWord(['b', 'oa', 't'], '⛵'), BlendWord(['g', 'oa', 't'], '🐐'), BlendWord(['c', 'oa', 't'], '🧥'),
    BlendWord(['m', 'oo', 'n'], '🌙'), BlendWord(['f', 'oo', 'd'], '🍲'), BlendWord(['c', 'ar'], '🚗'),
    BlendWord(['f', 'ar', 'm'], '🚜'), BlendWord(['f', 'or', 'k'], '🍴'), BlendWord(['c', 'or', 'n'], '🌽'),
    BlendWord(['c', 'ow'], '🐄'), BlendWord(['ow', 'l'], '🦉'), BlendWord(['c', 'oi', 'n'], '🪙'),
  ],
  // Words with two consonants together (CCVC and CVCC).
  9: [
    BlendWord(['f', 'r', 'o', 'g'], '🐸'), BlendWord(['c', 'r', 'a', 'b'], '🦀'), BlendWord(['d', 'r', 'u', 'm'], '🥁'),
    BlendWord(['f', 'l', 'a', 'g'], '🚩'), BlendWord(['s', 't', 'o', 'p'], '🛑'), BlendWord(['s', 'w', 'i', 'm'], '🏊'),
    BlendWord(['s', 'l', 'e', 'd'], '🛷'), BlendWord(['t', 'e', 'n', 't'], '⛺'), BlendWord(['h', 'a', 'n', 'd'], '✋'),
    BlendWord(['m', 'i', 'l', 'k'], '🥛'), BlendWord(['n', 'e', 's', 't'], '🪺'), BlendWord(['j', 'u', 'm', 'p'], '🦘'),
    BlendWord(['g', 'i', 'f', 't'], '🎁'), BlendWord(['p', 'l', 'u', 'g'], '🔌'), BlendWord(['s', 'n', 'a', 'ck'], '🍿'),
  ],
};
