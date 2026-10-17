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

String _q(LabItem i) => i.name;
String _livingQ(LabItem i) => 'Is the ${i.name} living?';
String _heavyQ(LabItem i) => 'Is the ${i.name} heavy or light?';
String _loudQ(LabItem i) => 'Is a ${i.name} loud or quiet?';
String _foodQ(LabItem i) => '${i.name[0].toUpperCase()}${i.name.substring(1)}: every day, or sometimes?';
String _recycleQ(LabItem i) => 'Where does the ${i.name} go?';
String _travelQ(LabItem i) => 'Where does a ${i.name} go?';
String _babyQ(LabItem i) => 'What is a baby ${i.name} like?';
String _eatQ(LabItem i) => 'What does a ${i.name} eat?';
String _softQ(LabItem i) => 'Is the ${i.name} soft or hard?';

const moreLabTopics = <LabTopic>[
  LabTopic('living', 'Alive or not?', _livingQ, ['🌱', '🪨'], ['Living', 'Not living'], [
    LabItem('🐶', 'dog', 0, 'Living! Dogs eat, grow and breathe.'),
    LabItem('🪨', 'rock', 1, 'Not living. A rock does not eat or grow.'),
    LabItem('🌳', 'tree', 0, 'Living! Trees drink water and grow.'),
    LabItem('🚗', 'car', 1, 'Not living. A car needs a driver to move.'),
    LabItem('🐟', 'fish', 0, 'Living! Fish eat and grow.'),
    LabItem('🧸', 'teddy', 1, 'Not living. A teddy does not grow.'),
    LabItem('🌷', 'flower', 0, 'Living! Flowers grow from seeds.'),
    LabItem('🥄', 'spoon', 1, 'Not living. A spoon does not eat or breathe.'),
  ]),
  LabTopic('heavy', 'Heavy or light?', _heavyQ, ['🏋️', '🪶'], ['Heavy', 'Light'], [
    LabItem('🐘', 'elephant', 0, 'Heavy! An elephant is one of the heaviest animals.'),
    LabItem('🪶', 'feather', 1, 'Light! A feather floats in the air.'),
    LabItem('🎈', 'balloon', 1, 'Light! A balloon is full of air.'),
    LabItem('🚚', 'truck', 0, 'Heavy! Trucks are big and made of metal.'),
    LabItem('🍃', 'leaf', 1, 'Light! The wind can blow a leaf away.'),
    LabItem('🪨', 'big rock', 0, 'Heavy! Big rocks are hard to lift.'),
    LabItem('🧻', 'tissue', 1, 'Light! A tissue is thin and soft.'),
    LabItem('🎹', 'piano', 0, 'Heavy! It takes many people to move a piano.'),
  ]),
  LabTopic('loud', 'Loud or quiet?', _loudQ, ['🔊', '🤫'], ['Loud', 'Quiet'], [
    LabItem('🦁', 'lion roaring', 0, 'Loud! A roar can be heard far away.'),
    LabItem('🐭', 'mouse squeaking', 1, 'Quiet! Squeak, squeak.'),
    LabItem('🚒', 'fire engine', 0, 'Loud! The siren warns people to move.'),
    LabItem('🍂', 'leaf falling', 1, 'Quiet! You can hardly hear it.'),
    LabItem('🥁', 'drum', 0, 'Loud! Boom, boom!'),
    LabItem('🐱', 'cat purring', 1, 'Quiet! A soft purr.'),
    LabItem('⛈️', 'thunder clap', 0, 'Loud! Thunder rumbles in the sky.'),
    LabItem('🤫', 'whisper', 1, 'Quiet! Whispers are soft.'),
  ]),
  LabTopic('food', 'Healthy food', _foodQ, ['💪', '🍬'], ['Every day', 'Sometimes'], [
    LabItem('🥦', 'broccoli', 0, 'Every day! Vegetables help you grow strong.'),
    LabItem('🍭', 'lollipop', 1, 'Sometimes! Too much sugar is not good for teeth.'),
    LabItem('apple', 'apple', 0, 'Every day! Fruit is good for you.'),
    LabItem('🍩', 'doughnut', 1, 'Sometimes! A treat for special days.'),
    LabItem('🥕', 'carrot', 0, 'Every day! Crunchy and good for you.'),
    LabItem('🍟', 'chips', 1, 'Sometimes! Salty food is a treat.'),
    LabItem('🥛', 'milk', 0, 'Every day! Milk helps build strong bones.'),
    LabItem('🍫', 'chocolate', 1, 'Sometimes! Yummy, but just a little.'),
  ]),
  LabTopic('recycle', 'Recycling', _recycleQ, ['♻️', '🍂'], ['Recycle bin', 'Compost'], [
    LabItem('🥫', 'tin can', 0, 'Recycle! Cans can be made into new cans.'),
    LabItem('🍌', 'banana peel', 1, 'Compost! Peels turn into soil for plants.'),
    LabItem('📰', 'newspaper', 0, 'Recycle! Paper can be made into new paper.'),
    LabItem('🍏', 'apple core', 1, 'Compost! It rots and feeds the soil.'),
    LabItem('🍾', 'glass bottle', 0, 'Recycle! Glass can be melted and used again.'),
    LabItem('🥚', 'egg shell', 1, 'Compost! Shells help plants grow.'),
    LabItem('📦', 'cardboard box', 0, 'Recycle! Boxes become new boxes.'),
    LabItem('🍂', 'pile of dry leaves', 1, 'Compost! Leaves become rich soil.'),
  ]),
  LabTopic('travel', 'Land, water or air?', _travelQ, ['🛣️', '🌊', '☁️'], ['Land', 'Water', 'Air'], [
    LabItem('🚗', 'car', 0, 'Land! Cars drive on roads.'),
    LabItem('⛵', 'sailing boat', 1, 'Water! The wind pushes the sail.'),
    LabItem('✈️', 'plane', 2, 'Air! Planes fly high above the clouds.'),
    LabItem('🚂', 'train', 0, 'Land! Trains run on tracks.'),
    LabItem('🚁', 'helicopter', 2, 'Air! Its blades spin round and round.'),
    LabItem('🚢', 'ship', 1, 'Water! Ships carry people across the sea.'),
    LabItem('🚲', 'bike', 0, 'Land! Pedal, pedal.'),
    LabItem('🎈', 'hot air balloon', 2, 'Air! Hot air makes it float up.'),
  ]),
  LabTopic('babies', 'Animal babies', _babyQ, ['🐣', '🐮', '🐸'], ['Chick', 'Calf', 'Tadpole'], [
    LabItem('🐔', 'hen', 0, 'A chick! Chicks hatch from eggs.'),
    LabItem('🐄', 'cow', 1, 'A calf! Calves drink their mother’s milk.'),
    LabItem('🐸', 'frog', 2, 'A tadpole! Tadpoles grow legs and become frogs.'),
    LabItem('🦆', 'duck', 0, 'A duckling! It hatches from an egg, like a chick.'),
    LabItem('🐘', 'elephant', 1, 'A calf! Baby elephants are called calves too.'),
    LabItem('🦢', 'swan', 0, 'A cygnet! It hatches from an egg, like a chick.'),
  ]),
  LabTopic('eat', 'What do animals eat?', _eatQ, ['🥕', '🐟', '🌾'], ['Carrots', 'Fish', 'Seeds'], [
    LabItem('🐰', 'rabbit', 0, 'Carrots and leafy greens!'),
    LabItem('🐧', 'penguin', 1, 'Fish! Penguins dive to catch them.'),
    LabItem('🐦', 'little bird', 2, 'Seeds! Little birds love seeds.'),
    LabItem('🦭', 'seal', 1, 'Fish! Seals are great swimmers.'),
    LabItem('🐹', 'hamster', 2, 'Seeds and grains!'),
    LabItem('🐴', 'horse', 0, 'Carrots, hay and grass!'),
  ]),
  LabTopic('materials', 'Soft or hard?', _softQ, ['☁️', '🧱'], ['Soft', 'Hard'], [
    LabItem('🧸', 'teddy', 0, 'Soft! Lovely to cuddle.'),
    LabItem('🧱', 'brick', 1, 'Hard! Bricks build strong walls.'),
    LabItem('🛏️', 'pillow', 0, 'Soft! Good for sleeping.'),
    LabItem('🪨', 'rock', 1, 'Hard! Rocks do not squish.'),
    LabItem('🧶', 'wool', 0, 'Soft! Wool comes from sheep.'),
    LabItem('🔨', 'hammer', 1, 'Hard! Made of metal and wood.'),
  ]),
  LabTopic('season', 'Seasons', _q, ['☀️', '❄️', '🍂'], ['Summer', 'Winter', 'Autumn'], [
    LabItem('🏖️', 'When do we go to the beach?', 0, 'Summer! It is warm and sunny.'),
    LabItem('⛄', 'When can we build a snowman?', 1, 'Winter! In cold places it snows.'),
    LabItem('🍂', 'When do leaves fall off trees?', 2, 'Autumn! Leaves turn orange and fall.'),
    LabItem('🍉', 'When do we eat cold watermelon?', 0, 'Summer! A cool treat on a hot day.'),
    LabItem('🧣', 'When do we wear warm scarves?', 1, 'Winter! Wrap up warm.'),
    LabItem('🎃', 'When are pumpkins ready to pick?', 2, 'Autumn! It is harvest time.'),
  ]),
  LabTopic('body', 'My body', _q, ['🫁', '❤️', '🦴'], ['Lungs', 'Heart', 'Bones'], [
    LabItem('🌬️', 'What helps you breathe?', 0, 'Your lungs! Breathe in, breathe out.'),
    LabItem('🏃', 'What beats fast when you run?', 1, 'Your heart! Feel it go thump, thump.'),
    LabItem('🧍', 'What helps you stand up tall?', 2, 'Your bones! They hold you up.'),
    LabItem('🎈', 'What helps you blow up a balloon?', 0, 'Your lungs! Big breath in...'),
    LabItem('🩺', 'What does the doctor listen to?', 1, 'Your heart! Ba-dum, ba-dum.'),
    LabItem('🥛', 'What does milk help grow strong?', 2, 'Your bones!'),
  ]),
];

String _meltQ(LabItem i) => 'Will the ${i.name} melt in the sun?';
String _pushQ(LabItem i) => 'Do we push or pull the ${i.name}?';
String _solidQ(LabItem i) => 'Is ${i.name} a solid or a liquid?';
String _nightQ(LabItem i) => 'Is the ${i.name} awake in the day or at night?';
String _growQ(LabItem i) => 'Will the ${i.name} grow bigger?';

const extraLabTopics = <LabTopic>[
  LabTopic('melt', 'Melt or stay?', _meltQ, ['💧', '🧱'], ['Melts', 'Stays the same'], [
    LabItem('🧊', 'ice cube', 0, 'It melts! Ice turns into water when it is warm.'),
    LabItem('🪨', 'rock', 1, 'It stays the same. Rocks do not melt in the sun.'),
    LabItem('🍦', 'ice cream', 0, 'It melts! Eat it quickly on a hot day.'),
    LabItem('🧸', 'teddy', 1, 'It stays the same. A teddy just gets warm.'),
    LabItem('⛄', 'snowman', 0, 'It melts! Snow is frozen water.'),
    LabItem('🍫', 'chocolate bar', 0, 'It melts! Chocolate goes soft in the heat.'),
    LabItem('🥄', 'spoon', 1, 'It stays the same. Metal needs much more heat to melt.'),
    LabItem('🕯️', 'candle wax', 0, 'It melts slowly when it is very warm.'),
  ]),
  LabTopic('push', 'Push or pull?', _pushQ, ['👉', '👈'], ['Push', 'Pull'], [
    LabItem('🛒', 'shopping trolley', 0, 'Push! We push a trolley in front of us.'),
    LabItem('🚪', 'door handle towards you', 1, 'Pull! We pull a door towards us to open it.'),
    LabItem('🛝', 'swing', 0, 'Push! A push makes the swing go higher.'),
    LabItem('🪁', 'kite string', 1, 'Pull! Pulling the string keeps the kite up.'),
    LabItem('🛷', 'sledge rope', 1, 'Pull! We pull the sledge by its rope.'),
    LabItem('🔘', 'button', 0, 'Push! We press buttons.'),
    LabItem('🧸', 'wagon handle', 1, 'Pull! We pull a wagon behind us.'),
    LabItem('⚽', 'ball with a kick', 0, 'Push! A kick pushes the ball away.'),
  ]),
  LabTopic('solid', 'Solid or liquid?', _solidQ, ['🧱', '💧'], ['Solid', 'Liquid'], [
    LabItem('🧱', 'a brick', 0, 'Solid! It keeps its shape.'),
    LabItem('🥛', 'milk', 1, 'Liquid! It pours and takes the shape of the cup.'),
    LabItem('🧊', 'an ice cube', 0, 'Solid! Ice is frozen water.'),
    LabItem('💧', 'water', 1, 'Liquid! Water flows.'),
    LabItem('🍯', 'honey', 1, 'Liquid! A slow, sticky liquid.'),
    LabItem('🪨', 'a rock', 0, 'Solid! Hard and keeps its shape.'),
    LabItem('🧃', 'juice', 1, 'Liquid! You can pour it.'),
    LabItem('🍎', 'an apple', 0, 'Solid! You can hold it.'),
  ]),
  LabTopic('nocturnal', 'Day or night animals', _nightQ, ['☀️', '🌙'], ['Day', 'Night'], [
    LabItem('🦉', 'owl', 1, 'Night! Owls hunt in the dark.'),
    LabItem('🐝', 'bee', 0, 'Day! Bees visit flowers in the sunshine.'),
    LabItem('🦇', 'bat', 1, 'Night! Bats fly in the dark.'),
    LabItem('🐿️', 'squirrel', 0, 'Day! Squirrels gather nuts in daylight.'),
    LabItem('🦔', 'hedgehog', 1, 'Night! Hedgehogs snuffle about at night.'),
    LabItem('🦋', 'butterfly', 0, 'Day! Butterflies love the warm sun.'),
    LabItem('🦊', 'fox', 1, 'Night! Foxes are often out at night.'),
    LabItem('🐓', 'rooster', 0, 'Day! Roosters crow in the morning.'),
  ]),
  LabTopic('grow', 'Does it grow?', _growQ, ['🌱', '✋'], ['Grows', 'Stays the same size'], [
    LabItem('🌱', 'seedling', 0, 'It grows! Plants grow with water and sun.'),
    LabItem('🪑', 'chair', 1, 'It stays the same. Chairs are not alive.'),
    LabItem('🐣', 'chick', 0, 'It grows into a hen or rooster!'),
    LabItem('🧸', 'teddy', 1, 'It stays the same. Toys do not grow.'),
    LabItem('👶', 'baby', 0, 'It grows! Babies grow into children, like you.'),
    LabItem('🪨', 'pebble', 1, 'It stays the same. Pebbles are not alive.'),
    LabItem('🐛', 'caterpillar', 0, 'It grows and becomes a butterfly!'),
    LabItem('📚', 'book', 1, 'It stays the same, but you grow when you read it!'),
  ]),
];

/// All Wonder Lab topics, in teaching order.
const allLabTopics = <LabTopic>[...labTopics, ...moreLabTopics, ...extraLabTopics];

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
  Move('Gallop like a horse', 'gallop', '🐴'),
  Move('Wave like an octopus', 'wave', '🐙'),
  Move('Slither like a snake', 'slither', '🐍'),
  Move('Buzz like a busy bee', 'buzz', '🐝'),
  Move('Do star jumps', 'jump', '⭐'),
  Move('Pop like popcorn', 'pop', '🍿'),
  Move('Melt like a snowman', 'melt', '⛄'),
  Move('Crawl like a bear', 'crawl', '🐻'),
  Move('Smell the flower, blow the candle', 'breathe', '🌸', breath: true),
  Move('Kick like a football star', 'kick', '⚽'),
  Move('Skate on the spot', 'skate', '⛸️'),
  Move('Paddle like a duck', 'paddle', '🦆'),
  Move('Box like a kangaroo', 'punch', '🦘'),
  Move('Bend like a bridge', 'bend', '🌉'),
  Move('Twist like a corkscrew', 'twist', '🌀'),
  Move('Climb an imaginary ladder', 'climb', '🪜'),
  Move('Bounce like a ball', 'bounce', '🏀'),
  Move('Fly like a rocket', 'blast off', '🚀'),
  Move('Hug yourself tight, then let go', 'breathe', '🤗', breath: true),
  Move('Shake your sillies out', 'shake', '🎉'),
];
