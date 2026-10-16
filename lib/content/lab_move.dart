/// Wonder Lab (predict -> test -> explain) and Move & Groove content.
library;

class LabItem {
  final String pic;
  final String name;
  final int truth; // index into the topic's options
  final String explain;
  const LabItem(this.pic, this.name, this.truth, this.explain);
}

class LabTopic {
  final String id;
  final String title;
  final String Function(LabItem) question;
  final List<String> options; // picture ids (or words, see optionLabels)
  final List<String> optionLabels;
  final List<LabItem> items;
  const LabTopic(this.id, this.title, this.question, this.options, this.optionLabels, this.items);
}

String _floatQ(LabItem i) => 'Will the ${i.name} float or sink?';
String _magQ(LabItem i) => 'Will the magnet pull the ${i.name}?';
String _hotQ(LabItem i) => 'Is the ${i.name} hot or cold?';
String _dayQ(LabItem i) => 'Day or night: ${i.name}?';
String _plantQ(LabItem i) => i.name;
String _lightQ(LabItem i) => 'Will the ${i.name} make a shadow?';
String _weatherQ(LabItem i) => i.name;
String _homeQ(LabItem i) => 'Where does the ${i.name} live?';
String _senseQ(LabItem i) => i.name;

const labTopics = <LabTopic>[
  LabTopic('float', 'Float or sink?', _floatQ, ['⬆️', '⬇️'], ['Float', 'Sink'], [
    LabItem('apple', 'apple', 0, 'It floats! Apples have air inside.'),
    LabItem('🪨', 'rock', 1, 'It sinks! A rock is heavy for its size.'),
    LabItem('🍃', 'leaf', 0, 'It floats! A leaf is light and flat.'),
    LabItem('🔑', 'key', 1, 'It sinks! Metal keys are heavy for their size.'),
    LabItem('🦆', 'toy duck', 0, 'It floats! The toy duck is full of air.'),
    LabItem('🥄', 'spoon', 1, 'It sinks! A metal spoon is heavy for its size.'),
    LabItem('🪵', 'wood block', 0, 'It floats! Wood is lighter than water.'),
    LabItem('⚽', 'ball', 0, 'It floats! The ball is full of air.'),
    LabItem('🪶', 'feather', 0, 'It floats! A feather is very light.'),
    LabItem('🔩', 'bolt', 1, 'It sinks! The bolt is solid metal.'),
    LabItem('🧽', 'sponge', 0, 'It floats! A sponge has lots of air holes.'),
    LabItem('🐚', 'shell', 1, 'It sinks! A shell is hard and heavy for its size.'),
  ]),
  LabTopic('magnet', 'Magnet magic', _magQ, ['🧲', '✋'], ['Yes', 'No'], [
    LabItem('📎', 'paper clip', 0, 'Yes! Magnets pull things made of iron, like this clip.'),
    LabItem('🪵', 'wood block', 1, 'No! Magnets do not pull wood.'),
    LabItem('🔩', 'bolt', 0, 'Yes! The bolt is made of iron.'),
    LabItem('apple', 'apple', 1, 'No! Magnets do not pull food.'),
    LabItem('🖍️', 'crayon', 1, 'No! A crayon is made of wax.'),
    LabItem('🧷', 'safety pin', 0, 'Yes! The safety pin has iron in it.'),
    LabItem('🧦', 'sock', 1, 'No! Magnets do not pull cloth.'),
    LabItem('🪛', 'screwdriver', 0, 'Yes! The metal tip is pulled by the magnet.'),
  ]),
  LabTopic('hot', 'Hot or cold?', _hotQ, ['🔥', '❄️'], ['Hot', 'Cold'], [
    LabItem('🍦', 'ice cream', 1, 'Cold! Ice cream melts when it gets warm.'),
    LabItem('🍲', 'soup', 0, 'Hot! Soup is cooked on the stove. Blow on it first.'),
    LabItem('⛄', 'snowman', 1, 'Cold! Snow is frozen water.'),
    LabItem('☀️', 'sun', 0, 'Hot! The sun warms the whole world.'),
    LabItem('🧊', 'ice cube', 1, 'Cold! Ice is frozen water.'),
    LabItem('☕', 'cup of cocoa', 0, 'Hot! Warm drinks are made with hot water.'),
    LabItem('🐧', 'penguin’s home', 1, 'Cold! Penguins live where there is ice and snow.'),
    LabItem('🌋', 'volcano', 0, 'Hot! Very hot melted rock comes out.'),
  ]),
  LabTopic('day', 'Day and night', _dayQ, ['☀️', '🌙'], ['Day', 'Night'], [
    LabItem('🌙', 'the moon is out', 1, 'Night! We often see the moon at night.'),
    LabItem('🐓', 'the rooster crows', 0, 'Day! Roosters crow when the sun comes up.'),
    LabItem('🦉', 'owls go hunting', 1, 'Night! Owls are awake at night, like Tiko’s cousins.'),
    LabItem('⭐', 'we see stars', 1, 'Night! Stars shine when the sky is dark.'),
    LabItem('🥞', 'we eat breakfast', 0, 'Day! Breakfast is the first meal of the day.'),
    LabItem('🛌', 'we go to sleep', 1, 'Night! Our bodies rest at night.'),
    LabItem('🌻', 'sunflowers face the sun', 0, 'Day! Sunflowers turn toward the sun.'),
    LabItem('🦇', 'bats fly about', 1, 'Night! Bats come out when it is dark.'),
  ]),
  LabTopic('plant', 'Grow a bean', _plantQ, ['💧', '🍬', '☀️'], ['Water', 'Sweets', 'Sunlight'], [
    LabItem('🌱', 'What does a plant drink?', 0, 'Water! Roots drink water from the soil.'),
    LabItem('🌿', 'What helps leaves make food?', 2, 'Sunlight! Leaves use sunlight to make food.'),
    LabItem('🌷', 'What do flowers need to grow?', 0, 'Water! And sunlight and soil too.'),
    LabItem('🌰', 'What wakes up a seed in the soil?', 0, 'Water! A seed needs water to start growing.'),
    LabItem('🪴', 'Where should we put a plant?', 2, 'In the sunlight! Plants grow toward the light.'),
    LabItem('🌾', 'What makes grass green and tall?', 2, 'Sunlight! And rain to drink.'),
  ]),
  LabTopic('light', 'Shadows', _lightQ, ['👤', '✨'], ['Shadow', 'No shadow'], [
    LabItem('✋', 'hand', 0, 'Yes! Your hand blocks the light, so it makes a shadow.'),
    LabItem('📕', 'book', 0, 'Yes! Light cannot shine through a book.'),
    LabItem('🪟', 'clear window', 1, 'Hardly! Light shines through clear glass.'),
    LabItem('🌳', 'tree', 0, 'Yes! Trees make big shady shadows.'),
    LabItem('🧸', 'teddy', 0, 'Yes! The teddy blocks the light.'),
    LabItem('🫧', 'bubble', 1, 'Hardly! Light passes through a bubble.'),
    LabItem('🐈', 'cat', 0, 'Yes! Cats make shadows when the sun shines.'),
    LabItem('💧', 'clear water', 1, 'Hardly! Light passes through clear water.'),
  ]),
  LabTopic('weather', 'Weather', _weatherQ, ['☂️', '🧢', '🧣'], ['Umbrella', 'Sun hat', 'Scarf'], [
    LabItem('🌧️', 'It is raining! What should Momo take?', 0, 'An umbrella keeps the rain off.'),
    LabItem('☀️', 'It is sunny and hot! What should Momo wear?', 1, 'A sun hat keeps the sun off your face.'),
    LabItem('❄️', 'It is snowing! What should Momo wear?', 2, 'A scarf keeps your neck warm.'),
    LabItem('⛈️', 'A storm is coming! What should Momo take?', 0, 'An umbrella. And stay inside if there is thunder!'),
    LabItem('🌤️', 'Bright sunshine at the beach! What should Momo wear?', 1, 'A sun hat, and sun cream too.'),
    LabItem('🌨️', 'Cold and frosty! What should Momo wear?', 2, 'A scarf to stay cosy.'),
  ]),
  LabTopic('homes', 'Animal homes', _homeQ, ['🪺', '🌊', '🕸️'], ['Nest', 'Water', 'Web'], [
    LabItem('🐦', 'bird', 0, 'In a nest! Birds build nests from twigs.'),
    LabItem('🐟', 'fish', 1, 'In water! Fish breathe with gills.'),
    LabItem('🕷️', 'spider', 2, 'In a web! Spiders spin silky webs.'),
    LabItem('🐙', 'octopus', 1, 'In the sea! Octopuses hide in rocks underwater.'),
    LabItem('🦅', 'eagle', 0, 'In a nest, high up on a cliff.'),
    LabItem('🐬', 'dolphin', 1, 'In the sea! Dolphins swim and play in waves.'),
  ]),
  LabTopic('senses', 'My five senses', _senseQ, ['👀', '👂', '👃'], ['Eyes', 'Ears', 'Nose'], [
    LabItem('🌈', 'What helps you see a rainbow?', 0, 'Your eyes! We see colours with our eyes.'),
    LabItem('🎵', 'What helps you hear music?', 1, 'Your ears! We hear sounds with our ears.'),
    LabItem('🌸', 'What helps you smell a flower?', 2, 'Your nose! We smell with our nose.'),
    LabItem('🔔', 'What helps you hear a bell?', 1, 'Your ears! Ding, ding!'),
    LabItem('🍪', 'What tells you cookies are baking?', 2, 'Your nose! Mmm, what a smell.'),
    LabItem('⭐', 'What helps you see the stars?', 0, 'Your eyes! Look up on a clear night.'),
  ]),
];

class Move {
  final String name; // "Jump like a frog"
  final String verb; // "jump"
  final String pic;
  final bool breath;
  const Move(this.name, this.verb, this.pic, {this.breath = false});
}

const moves = <Move>[
  Move('Stretch up tall', 'stretch', '🙆'),
  Move('Flap your owl wings', 'flap', '🦉'),
  Move('Jump like a frog', 'jump', '🐸'),
  Move('March on the spot', 'march', '🥁'),
  Move('Touch your toes', 'touch', '🦶'),
  Move('Big breath in and out', 'breathe', '🌬️', breath: true),
  Move('Hop like a bunny', 'hop', '🐰'),
  Move('Stomp like a dinosaur', 'stomp', '🦖'),
  Move('Reach for the stars', 'reach', '⭐'),
  Move('Wiggle like a worm', 'wiggle', '🪱'),
  Move('Swim like a fish', 'swim', '🐟'),
  Move('Clap your hands', 'clap', '👏'),
  Move('Tiptoe like a mouse', 'tiptoe', '🐭'),
  Move('Shake like a wet dog', 'shake', '🐶'),
  Move('Spin around slowly', 'spin', '🌀'),
  Move('Stand like a flamingo', 'balance', '🦩'),
  Move('Row your boat', 'row', '🚣'),
  Move('Sway like a tree', 'sway', '🌳'),
  Move('Freeze like a statue', 'freeze', '🗿'),
  Move('Waddle like a penguin', 'waddle', '🐧'),
];
