// Content for Word Garden (vocabulary) and Healthy Me (habits, safety,
// body, feelings and routines). All original. Pictures are system emoji
// or the app's painted art, shown with words too (never colour alone).
import 'dart:math';

/// One quiz question: a prompt (spoken and shown), optional picture, and
/// picture choices with labels.
class QuizQ {
  final String prompt;
  final String? pic;
  final List<String> choices; // picture ids
  final List<String> labels;
  final int answer;
  final String explain;
  const QuizQ(this.prompt, this.pic, this.choices, this.labels, this.answer, this.explain);
}

class Thing {
  final String word, pic, cat;
  const Thing(this.word, this.pic, this.cat);
}

// ---------------------------------------------------------------- vocabulary

const things = <Thing>[
  // animals
  Thing('cat', '🐱', 'animal'), Thing('dog', '🐶', 'animal'), Thing('lion', '🦁', 'animal'),
  Thing('giraffe', '🦒', 'animal'), Thing('elephant', '🐘', 'animal'), Thing('zebra', '🦓', 'animal'),
  Thing('monkey', '🐵', 'animal'), Thing('rabbit', '🐰', 'animal'), Thing('horse', '🐴', 'animal'),
  Thing('cow', '🐄', 'animal'), Thing('pig', '🐷', 'animal'), Thing('sheep', '🐑', 'animal'),
  Thing('frog', '🐸', 'animal'), Thing('tiger', '🐯', 'animal'), Thing('bear', '🐻', 'animal'),
  Thing('penguin', '🐧', 'animal'), Thing('owl', '🦉', 'animal'), Thing('duck', '🦆', 'animal'),
  Thing('fish', '🐟', 'animal'), Thing('whale', '🐋', 'animal'), Thing('octopus', '🐙', 'animal'),
  Thing('crab', '🦀', 'animal'), Thing('snail', '🐌', 'animal'), Thing('bee', '🐝', 'animal'),
  Thing('butterfly', '🦋', 'animal'), Thing('turtle', '🐢', 'animal'), Thing('camel', '🐫', 'animal'),
  Thing('kangaroo', '🦘', 'animal'), Thing('hippo', '🦛', 'animal'), Thing('crocodile', '🐊', 'animal'),
  // fruit and vegetables
  Thing('apple', 'apple', 'fruit'), Thing('banana', '🍌', 'fruit'), Thing('grapes', '🍇', 'fruit'),
  Thing('strawberry', '🍓', 'fruit'), Thing('orange', 'orange', 'fruit'), Thing('pear', '🍐', 'fruit'),
  Thing('watermelon', '🍉', 'fruit'), Thing('pineapple', '🍍', 'fruit'), Thing('cherries', '🍒', 'fruit'),
  Thing('lemon', '🍋', 'fruit'), Thing('mango', '🥭', 'fruit'), Thing('coconut', '🥥', 'fruit'),
  Thing('carrot', '🥕', 'vegetable'), Thing('broccoli', '🥦', 'vegetable'), Thing('corn', '🌽', 'vegetable'),
  Thing('potato', '🥔', 'vegetable'), Thing('tomato', '🍅', 'vegetable'), Thing('cucumber', '🥒', 'vegetable'),
  Thing('pepper', '🫑', 'vegetable'), Thing('onion', '🧅', 'vegetable'), Thing('mushroom', '🍄', 'vegetable'),
  // vehicles
  Thing('car', '🚗', 'vehicle'), Thing('bus', '🚌', 'vehicle'), Thing('train', '🚂', 'vehicle'),
  Thing('plane', '✈️', 'vehicle'), Thing('boat', '⛵', 'vehicle'), Thing('bike', '🚲', 'vehicle'),
  Thing('tractor', '🚜', 'vehicle'), Thing('fire engine', '🚒', 'vehicle'), Thing('helicopter', '🚁', 'vehicle'),
  Thing('rocket', '🚀', 'vehicle'), Thing('ambulance', '🚑', 'vehicle'), Thing('scooter', '🛴', 'vehicle'),
  // clothes
  Thing('hat', '🎩', 'clothes'), Thing('shoe', '👟', 'clothes'), Thing('sock', '🧦', 'clothes'),
  Thing('dress', '👗', 'clothes'), Thing('coat', '🧥', 'clothes'), Thing('scarf', '🧣', 'clothes'),
  Thing('gloves', '🧤', 'clothes'), Thing('boots', '👢', 'clothes'), Thing('t-shirt', '👕', 'clothes'),
  Thing('shorts', '🩳', 'clothes'), Thing('cap', '🧢', 'clothes'), Thing('jeans', '👖', 'clothes'),
  // toys and things
  Thing('ball', '⚽', 'toy'), Thing('teddy', '🧸', 'toy'), Thing('kite', '🪁', 'toy'), Thing('yo-yo', '🪀', 'toy'),
  Thing('blocks', '🧱', 'toy'), Thing('puzzle', '🧩', 'toy'), Thing('balloon', '🎈', 'toy'), Thing('drum', '🥁', 'toy'),
  // home
  Thing('bed', '🛏️', 'home'), Thing('chair', '🪑', 'home'), Thing('door', '🚪', 'home'), Thing('lamp', '💡', 'home'),
  Thing('clock', '🕰️', 'home'), Thing('bath', '🛁', 'home'), Thing('key', '🔑', 'home'), Thing('cup', '☕', 'home'),
  // nature
  Thing('tree', '🌳', 'nature'), Thing('flower', '🌷', 'nature'), Thing('sun', '☀️', 'nature'),
  Thing('moon', '🌙', 'nature'), Thing('star', '⭐', 'nature'), Thing('cloud', '☁️', 'nature'),
  Thing('rainbow', '🌈', 'nature'), Thing('mountain', '⛰️', 'nature'), Thing('leaf', '🍃', 'nature'),
  Thing('rock', '🪨', 'nature'), Thing('snowflake', '❄️', 'nature'), Thing('volcano', '🌋', 'nature'),
  // instruments
  Thing('guitar', '🎸', 'music'), Thing('trumpet', '🎺', 'music'), Thing('violin', '🎻', 'music'),
  Thing('piano', '🎹', 'music'), Thing('saxophone', '🎷', 'music'), Thing('bell', '🔔', 'music'),
];

const categoryNames = {
  'animal': 'an animal', 'fruit': 'a fruit', 'vegetable': 'a vegetable', 'vehicle': 'something we ride in',
  'clothes': 'something we wear', 'toy': 'a toy', 'home': 'something in a home', 'nature': 'something in nature',
  'music': 'a musical instrument',
};

const opposites = <List<(String, String)>>[
  [('hot', '🔥'), ('cold', '❄️')], [('big', '🐘'), ('small', '🐭')], [('day', '☀️'), ('night', '🌙')],
  [('happy', 'face:happy'), ('sad', 'face:sad')], [('up', '⬆️'), ('down', '⬇️')], [('fast', '🐇'), ('slow', '🐢')],
  [('wet', '💧'), ('dry', '🏜️')], [('loud', '📢'), ('quiet', '🤫')], [('tall', '🦒'), ('short', '🐁')],
  [('old', '👴'), ('young', '👶')], [('sweet', '🍬'), ('sour', '🍋')], [('hard', '🪨'), ('soft', '🧸')],
  [('heavy', '🏋️'), ('light', '🪶')], [('awake', '🌅'), ('asleep', 'face:sleepy')],
  [('left', '⬅️'), ('right', '➡️')], [('summer', '🏖️'), ('winter', '⛄')],
];

const colours = <String, (int, List<String>)>{
  'red': (0xFFEF476F, ['apple', '🍓', '🚒', '🌹', '🍒', '🍅']),
  'yellow': (0xFFFFD166, ['🍌', '🌻', '🐥', '⭐', '🍋', '🧀']),
  'green': (0xFF3DBE7A, ['🥦', '🐸', '🍀', '🥒', '🌳', '🦖']),
  'blue': (0xFF4DA3FF, ['🐳', '🫐', '🦋', '💙', '🧢', '🚙']),
  'orange': (0xFFFF9F1C, ['🥕', 'orange', '🎃', '🦊', '🏀', '🦁']),
  'purple': (0xFF9B6BFF, ['🍇', '🍆', '☂️', '💜', '🔮', '🦄']),
  'brown': (0xFF8B5E3C, ['🐻', '🌰', '🪵', '🍫', '🥔', '🐴']),
  'white': (0xFFFFFFFF, ['⛄', '🥚', '☁️', '🦢', '🥛', '🐑']),
};

const uses = <(String, String, String)>[
  ('cut paper', '✂️', 'scissors'), ('eat soup', '🥄', 'spoon'), ('write', '✏️', 'pencil'),
  ('brush our teeth', '🪥', 'toothbrush'), ('see in the dark', '🔦', 'torch'), ('open a door', '🔑', 'key'),
  ('sweep the floor', '🧹', 'broom'), ('tell the time', '⏰', 'clock'), ('call someone', '📱', 'phone'),
  ('stay dry in the rain', '☂️', 'umbrella'), ('sit on', '🪑', 'chair'), ('sleep in', '🛏️', 'bed'),
  ('paint a picture', '🖌️', 'paintbrush'), ('cook food', '🍳', 'pan'), ('drink from', '🥤', 'cup'),
  ('build things', '🔨', 'hammer'), ('read a story', '📖', 'book'), ('carry things', '🎒', 'backpack'),
  ('take a photo', '📷', 'camera'), ('wash our hands', '🧼', 'soap'), ('blow our nose', '🧻', 'tissue'),
  ('comb our hair', '🪮', 'comb'), ('dig in the sand', '🪣', 'bucket'), ('listen to music', '🎧', 'headphones'),
];

/// Generates a Word Garden question of [kind] for round [round].
QuizQ wordQuestion(String kind, int round, int offset, int choices, Random r) {
  List<T> pick<T>(T must, List<T> pool, int n) {
    final others = pool.where((x) => x != must).toList()..shuffle(r);
    return [must, ...others.take(n - 1)]..shuffle(r);
  }

  switch (kind) {
    case 'name':
      // Find the named thing among things from the same group.
      final t = things[(offset + round * 7 + r.nextInt(5)) % things.length];
      final pool = things.where((x) => x.cat == t.cat).toList();
      final opts = pick(t, pool.length >= choices ? pool : things, choices);
      return QuizQ('Find the ${t.word}!', null, [for (final o in opts) o.pic], [for (final o in opts) o.word],
          opts.indexOf(t), 'That’s the ${t.word}!');
    case 'category':
      final cats = categoryNames.keys.toList();
      final cat = cats[(offset + round) % cats.length];
      final inCat = things.where((x) => x.cat == cat).toList();
      final right = inCat[r.nextInt(inCat.length)];
      final notCat = things.where((x) => x.cat != cat && !(cat == 'fruit' && x.cat == 'vegetable')).toList()..shuffle(r);
      final opts = [right, ...notCat.take(choices - 1)]..shuffle(r);
      return QuizQ('Which one is ${categoryNames[cat]}?', null, [for (final o in opts) o.pic],
          [for (final o in opts) o.word], opts.indexOf(right), 'Yes, a ${right.word} is ${categoryNames[cat]}.');
    case 'opposite':
      final pair = opposites[(offset + round * 3 + r.nextInt(3)) % opposites.length];
      final flip = r.nextBool();
      final a = flip ? pair[1] : pair[0], b = flip ? pair[0] : pair[1];
      final seen = <String>{a.$2, b.$2};
      final others = [for (final p in opposites) if (!identical(p, pair)) ...p].where((o) => seen.add(o.$2)).toList()..shuffle(r);
      final opts = [b, ...others.take(choices - 1)]..shuffle(r);
      return QuizQ('What is the opposite of ${a.$1}?', a.$2, [for (final o in opts) o.$2], [for (final o in opts) o.$1],
          opts.indexOf(b), 'The opposite of ${a.$1} is ${b.$1}.');
    case 'colour':
      final names = colours.keys.toList();
      final c = names[(offset + round * 3 + r.nextInt(2)) % names.length];
      final right = colours[c]!.$2[r.nextInt(colours[c]!.$2.length)];
      final others = [for (final n in names) if (n != c) colours[n]!.$2[r.nextInt(colours[n]!.$2.length)]]..shuffle(r);
      final opts = [right, ...others.take(choices - 1)]..shuffle(r);
      return QuizQ('Find something $c!', 'swatch:${colours[c]!.$1.toRadixString(16)}', opts,
          [for (final o in opts) o == right ? c : 'not $c'], opts.indexOf(right), 'Yes! That is $c.');
    case 'use':
    default:
      final u = uses[(offset + round * 5 + r.nextInt(3)) % uses.length];
      final opts = pick(u, uses, choices);
      return QuizQ('What do we use to ${u.$1}?', null, [for (final o in opts) o.$2], [for (final o in opts) o.$3],
          opts.indexOf(u), 'We use a ${u.$3} to ${u.$1}.');
  }
}

// ---------------------------------------------------------------- healthy me

class HealthQ {
  final String topic, prompt;
  final List<(String, String)> choices; // (picture, label); the first is right
  final String explain;
  const HealthQ(this.topic, this.prompt, this.choices, this.explain);
}

const healthQs = <HealthQ>[
  // hygiene
  HealthQ('clean', 'What do we use to wash our hands?', [('🧼', 'soap'), ('🍫', 'chocolate'), ('🧸', 'teddy')], 'Soap and water wash germs away.'),
  HealthQ('clean', 'When should we wash our hands?', [('🍽️', 'before eating'), ('📺', 'watching TV'), ('🛝', 'on the swing')], 'Always wash your hands before you eat.'),
  HealthQ('clean', 'What do we brush our teeth with?', [('🪥', 'toothbrush'), ('🖌️', 'paintbrush'), ('🧹', 'broom')], 'A toothbrush and toothpaste keep teeth healthy.'),
  HealthQ('clean', 'What helps when we sneeze?', [('🧻', 'a tissue'), ('🍦', 'ice cream'), ('🎈', 'a balloon')], 'Sneeze into a tissue or your elbow.'),
  HealthQ('clean', 'What do we do after the toilet?', [('🧼', 'wash hands'), ('🏃', 'run away'), ('😴', 'go to sleep')], 'Wash your hands after the toilet.'),
  HealthQ('clean', 'What gets us clean all over?', [('🛁', 'a bath'), ('🟫', 'mud'), ('🍝', 'spaghetti')], 'A bath or shower washes your body.'),
  HealthQ('clean', 'How many times a day do we brush our teeth?', [('txt:2', 'two times'), ('txt:0', 'zero'), ('txt:9', 'nine')], 'Brush twice a day: morning and bedtime.'),
  HealthQ('clean', 'What do we use to dry our hands?', [('🧺', 'a towel'), ('🔥', 'a fire'), ('🧊', 'ice')], 'A clean towel dries your hands.'),
  // healthy food and drink
  HealthQ('food', 'What is the best drink when you are thirsty?', [('💧', 'water'), ('🥤', 'fizzy drink'), ('🧃', 'sweet juice')], 'Water is the best drink for your body.'),
  HealthQ('food', 'Which food helps you grow strong?', [('🥦', 'broccoli'), ('🍭', 'lollipop'), ('🍩', 'doughnut')], 'Vegetables help you grow.'),
  HealthQ('food', 'Which is a healthy snack?', [('apple', 'apple'), ('🍬', 'sweets'), ('🍟', 'chips')], 'Fruit is a great snack.'),
  HealthQ('food', 'What is a good breakfast?', [('🥣', 'porridge'), ('🍰', 'cake'), ('🍫', 'chocolate')], 'Porridge gives you energy for the morning.'),
  HealthQ('food', 'Which helps build strong bones?', [('🥛', 'milk'), ('🍭', 'lollipop'), ('🥤', 'fizzy drink')], 'Milk and yoghurt help your bones.'),
  HealthQ('food', 'Which treat is just for sometimes?', [('🍩', 'doughnut'), ('🥕', 'carrot'), ('🍌', 'banana')], 'Treats are fine sometimes, not every day.'),
  HealthQ('food', 'Which one is a vegetable?', [('🥕', 'carrot'), ('🍰', 'cake'), ('🍕', 'pizza')], 'Carrots are crunchy vegetables.'),
  HealthQ('food', 'What should we eat lots of?', [('🍎', 'fruit and vegetables'), ('🍬', 'sweets'), ('🍟', 'chips')], 'Eat a rainbow of fruit and vegetables.'),
  // sleep and routines
  HealthQ('routine', 'What do we do when we wake up?', [('🪥', 'brush our teeth'), ('🛏️', 'go to bed'), ('🌙', 'look at the moon')], 'Good morning! Brush your teeth.'),
  HealthQ('routine', 'What helps us get ready for sleep?', [('📖', 'a bedtime story'), ('🥁', 'loud drums'), ('🎢', 'a roller coaster')], 'A quiet story helps your body rest.'),
  HealthQ('routine', 'When do we sleep?', [('🌙', 'at night'), ('☀️', 'at lunch time'), ('🏫', 'at school')], 'We sleep at night when it is dark.'),
  HealthQ('routine', 'What do we put on before going outside?', [('👟', 'shoes'), ('🛁', 'a bath'), ('🍽️', 'a plate')], 'Shoes keep our feet safe.'),
  HealthQ('routine', 'What do we do after playing with toys?', [('🧺', 'tidy up'), ('🙈', 'hide'), ('😴', 'fall asleep')], 'Tidy up so toys are ready next time.'),
  HealthQ('routine', 'What do we wear to bed?', [('👚', 'pyjamas'), ('🧥', 'a winter coat'), ('🥾', 'boots')], 'Soft pyjamas are comfy for sleeping.'),
  HealthQ('routine', 'What do we eat in the morning?', [('🥞', 'breakfast'), ('🍝', 'dinner'), ('🎂', 'birthday cake')], 'Breakfast is the first meal of the day.'),
  HealthQ('routine', 'What tells us the time?', [('⏰', 'a clock'), ('🥄', 'a spoon'), ('🧦', 'a sock')], 'A clock tells the time.'),
  // safety
  HealthQ('safety', 'Who do we hold hands with to cross the road?', [('🧑‍🍼', 'a grown-up'), ('🐶', 'a dog'), ('🧸', 'a teddy')], 'Always hold a grown-up\'s hand near roads.'),
  HealthQ('safety', 'What does a red traffic light mean?', [('🛑', 'stop'), ('🏃', 'run'), ('💃', 'dance')], 'Red means stop.'),
  HealthQ('safety', 'What should we wear on a bike?', [('⛑️', 'a helmet'), ('👑', 'a crown'), ('🎩', 'a top hat')], 'A helmet keeps your head safe.'),
  HealthQ('safety', 'The oven is hot. What do we do?', [('✋', 'keep away'), ('👆', 'touch it'), ('😛', 'lick it')], 'Hot things can burn. Keep away.'),
  HealthQ('safety', 'If you get lost, who can help?', [('👮', 'a police officer'), ('🐦', 'a bird'), ('🚗', 'a parked car')], 'Find a police officer or a shop helper.'),
  HealthQ('safety', 'What do we do with medicine?', [('🧑‍🍼', 'only from a grown-up'), ('🍬', 'eat it like sweets'), ('🙈', 'hide it')], 'Only take medicine from a trusted grown-up.'),
  HealthQ('safety', 'What keeps us safe in a car?', [('🔒', 'a seat belt'), ('🎈', 'a balloon'), ('🧦', 'socks')], 'Click! Seat belts keep us safe.'),
  HealthQ('safety', 'What do we wear in strong sun?', [('🧢', 'a sun hat'), ('🧤', 'gloves'), ('🧣', 'a scarf')], 'A hat and sun cream protect your skin.'),
  HealthQ('safety', 'Where is safe to swim?', [('🏊', 'with a grown-up watching'), ('🌊', 'alone in the sea'), ('🛁', 'in the sink')], 'Only swim when a grown-up is watching.'),
  HealthQ('safety', 'A stranger offers you sweets. What do you do?', [('🙅', 'say no and tell a grown-up'), ('🍬', 'take them'), ('🚶', 'go with them')], 'Say no, and tell a grown-up you trust.'),
  // body
  HealthQ('body', 'What do we see with?', [('👀', 'eyes'), ('👂', 'ears'), ('👃', 'nose')], 'We see with our eyes.'),
  HealthQ('body', 'What do we hear with?', [('👂', 'ears'), ('🦶', 'feet'), ('👀', 'eyes')], 'We hear with our ears.'),
  HealthQ('body', 'What do we walk with?', [('🦶', 'feet'), ('👂', 'ears'), ('👃', 'nose')], 'Our feet help us walk and run.'),
  HealthQ('body', 'What do we smell with?', [('👃', 'nose'), ('✋', 'hands'), ('🦵', 'legs')], 'Sniff! We smell with our nose.'),
  HealthQ('body', 'What do we chew food with?', [('🦷', 'teeth'), ('👂', 'ears'), ('🦶', 'feet')], 'Our teeth chew our food.'),
  HealthQ('body', 'What do we clap with?', [('👏', 'hands'), ('🦶', 'feet'), ('👃', 'nose')], 'Clap, clap with your hands!'),
  HealthQ('body', 'What beats inside our chest?', [('❤️', 'heart'), ('⚽', 'ball'), ('🥁', 'drum')], 'Your heart beats all day and night.'),
  HealthQ('body', 'What do we think with?', [('🧠', 'brain'), ('🦶', 'foot'), ('👂', 'ear')], 'Your brain helps you think and learn.'),
  // calm feelings
  HealthQ('calm', 'You feel cross. What helps?', [('🌬️', 'a deep breath'), ('😠', 'shouting'), ('🦶', 'kicking')], 'Breathe in slowly, and out slowly.'),
  HealthQ('calm', 'You feel sad. What helps?', [('🤗', 'a hug'), ('🙈', 'hiding alone'), ('💥', 'breaking toys')], 'Hugs and talking help when we are sad.'),
  HealthQ('calm', 'You feel worried. Who can you tell?', [('🧑‍🍼', 'a grown-up you trust'), ('🪨', 'a rock'), ('📺', 'the TV')], 'Telling someone helps worries shrink.'),
  HealthQ('calm', 'Your friend is sad. What can you do?', [('🤝', 'be kind'), ('😂', 'laugh at them'), ('🏃', 'run away')], 'Being kind helps friends feel better.'),
  HealthQ('calm', 'What helps us calm down?', [('🧘', 'sitting quietly'), ('📢', 'yelling'), ('🥁', 'banging')], 'Sitting quietly helps our body calm down.'),
  HealthQ('calm', 'Someone shares with you. What do you say?', [('💬', 'thank you'), ('🙉', 'nothing'), ('😛', 'yuck')], 'Saying thank you is kind.'),
  HealthQ('calm', 'You made a mistake. What can you do?', [('🔁', 'try again'), ('😭', 'give up'), ('🗑️', 'throw it away')], 'Mistakes help us learn. Try again!'),
  HealthQ('calm', 'You bumped into someone. What do you say?', [('💬', 'sorry'), ('😝', 'ha ha'), ('🙉', 'nothing')], 'Saying sorry shows you care.'),
  // moving and days
  HealthQ('active', 'What keeps our body strong?', [('🏃', 'running and playing'), ('🛋️', 'sitting all day'), ('🍬', 'sweets')], 'Moving every day keeps you strong.'),
  HealthQ('active', 'What should we drink after running?', [('💧', 'water'), ('☕', 'coffee'), ('🥤', 'fizzy drink')], 'Water cools your body down.'),
  HealthQ('active', 'What helps our body after a busy day?', [('😴', 'sleep'), ('📱', 'more screens'), ('🍰', 'cake')], 'Sleep helps your body grow and rest.'),
  HealthQ('days', 'Which day comes after Monday?', [('txt:Tue', 'Tuesday'), ('txt:Sun', 'Sunday'), ('txt:Fri', 'Friday')], 'Monday, then Tuesday!'),
  HealthQ('days', 'Which day comes after Friday?', [('txt:Sat', 'Saturday'), ('txt:Mon', 'Monday'), ('txt:Wed', 'Wednesday')], 'Friday, then Saturday!'),
  HealthQ('days', 'Which day comes before Sunday?', [('txt:Sat', 'Saturday'), ('txt:Tue', 'Tuesday'), ('txt:Thu', 'Thursday')], 'Saturday, then Sunday!'),
  HealthQ('days', 'How many days are in a week?', [('txt:7', 'seven'), ('txt:3', 'three'), ('txt:10', 'ten')], 'There are seven days in a week.'),
  HealthQ('days', 'When do we eat lunch?', [('🕛', 'in the middle of the day'), ('🌙', 'at midnight'), ('🌅', 'before sunrise')], 'Lunch is in the middle of the day.'),
  HealthQ('days', 'What season is cold and snowy?', [('⛄', 'winter'), ('🏖️', 'summer'), ('🌷', 'spring')], 'Winter is the coldest season.'),
  HealthQ('days', 'When do flowers start to grow?', [('🌷', 'spring'), ('⛄', 'winter'), ('🌙', 'at night')], 'Flowers bloom in spring.'),
];

const healthTopics = ['clean', 'food', 'routine', 'safety', 'body', 'calm', 'active', 'days'];
const healthTitles = {
  'clean': 'Clean and healthy', 'food': 'Healthy eating', 'routine': 'My day', 'safety': 'Staying safe',
  'body': 'My body', 'calm': 'Calm and kind', 'active': 'Active and rested', 'days': 'Days and seasons',
};

QuizQ healthQuestion(String topic, int round, int offset, int choices, Random r) {
  final pool = healthQs.where((q) => q.topic == topic || topic == 'mix').toList();
  final q = pool[(offset + round * 3 + r.nextInt(2)) % pool.length];
  final opts = q.choices.take(max(2, min(choices, q.choices.length))).toList();
  final right = opts.first;
  opts.shuffle(r);
  return QuizQ(q.prompt, null, [for (final o in opts) o.$1], [for (final o in opts) o.$2], opts.indexOf(right), q.explain);
}
