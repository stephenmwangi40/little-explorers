// 60 more original Momo stories and 40 more feelings scenarios (v1.3).
import 'stories.dart';
import 'stories_more.dart';

const _h = 'face:happy', _s = 'face:sad', _sl = 'face:sleepy', _sc = 'face:scared', _su = 'face:surprised',
    _c = 'face:cross', _p = 'face:proud';

Story _d(String t, List<String> p, List<String> scene, String q, List<String> ch, int a, String hint, String talk) =>
    Story(t, p, scene, q, ch, a, hint, talk: talk);
Story _f(String t, List<String> p, List<String> scene, String q, List<String> ch, int a, String hint, String talk) =>
    Story(t, p, scene, q, ch, a, hint, feelings: true, talk: talk);

final extraStories = <Story>[
  _d('The garden hose', ['Grandma waters the garden.', 'Splash! The hose sprays Momo.', 'Momo laughs and runs through the water.'], ['🌷', '💦'], 'What sprayed Momo?', ['💦', '🔥', '❄️'], 0, 'Grandma was watering the garden.', 'What do plants need to grow?'),
  _f('Pip’s lost voice', ['Pip has a sore throat.', 'He cannot croak today.', 'Momo brings him warm honey water.'], ['🍯', '🐸'], 'How does Pip feel?', [_s, _p, _su], 0, 'His throat is sore.', 'What helps you feel better when you are poorly?'),
  _d('The new slide', ['The park has a new slide.', 'It is tall and twisty.', 'Momo slides down. Whee!'], ['🛝', '🌳'], 'Where is the new slide?', ['🏞️', '🏠', '🚗'], 0, 'Where do you find slides?', 'What do you like at the park?'),
  _d('Sol’s shell paint', ['Sol paints his shell.', 'He paints dots and stripes.', 'Now his shell is a rainbow!'], ['🎨', '🐌'], 'What did Sol paint?', ['🐚', '🧱', '🍎'], 0, 'It is on his back.', 'What would you paint?'),
  _f('The broken kite', ['A gust of wind snaps Pip’s kite.', 'Pip stamps his feet.', 'Then Grandma helps him make a new one.'], ['🪁', '💨'], 'How did Pip feel when it snapped?', [_c, _sl, _h], 0, 'He stamped his feet.', 'What can you do when you feel cross?'),
  _d('Counting shells', ['Momo finds shells on the beach.', 'One, two, three, four!', 'She puts them in her bucket.'], ['🐚', '🪣'], 'How many shells did Momo find?', ['txt:4', 'txt:2', 'txt:7'], 0, 'One, two, three, four.', 'Count some things in your room.'),
  _d('The busy bees', ['Bees buzz around the flowers.', 'They collect sweet nectar.', 'They make honey in their hive.'], ['🐝', '🌸'], 'What do bees make?', ['🍯', '🧀', '🍞'], 0, 'It is sweet and sticky.', 'Why are bees important?'),
  _f('Momo’s first swim alone', ['Momo swims to the rock by herself.', 'Grandma watches from the shore.', 'Grandma cheers, "Well done!"'], ['🌊', '🐢'], 'How does Momo feel?', [_p, _sc, _s], 0, 'Grandma cheered for her.', 'What can you do by yourself now?'),
  _d('A rainy-day den', ['It rains all morning.', 'Momo and Pip build a den with blankets.', 'They read books inside.'], ['🌧️', '⛺'], 'What did they build the den with?', ['🛏️', '🧱', '🪵'], 0, 'Soft things from the bed.', 'Build a blanket den together!'),
  _d('Duck’s new hat', ['Duck finds a flower.', 'She puts it on her head.', 'It is her new hat!'], ['🌼', '🦆'], 'What did Duck use as a hat?', ['🌼', '🍳', '🧦'], 0, 'It grows in the garden.', 'What could you use as a hat?'),
  _f('The thunder drum', ['Thunder booms outside.', 'Pip shakes with fear.', 'Momo says, "It is just the sky’s drum."'], ['⛈️', '🥁'], 'How did Pip feel?', [_sc, _h, _sl], 0, 'He was shaking.', 'What helps you during a storm?'),
  _d('Snack for the birds', ['Momo puts seeds on a plate.', 'Little birds fly down.', 'Peck, peck, peck!'], ['🌾', '🐦'], 'Who ate the seeds?', ['🐦', '🐟', '🐌'], 0, 'They fly.', 'How can we help birds?'),
  _d('The tall tower race', ['Sol and Pip build towers.', 'Sol’s tower is taller.', 'Pip says, "Let’s build one together!"'], ['🧱', '🐌'], 'What did they do at the end?', ['🤝', '😠', '😴'], 0, 'They worked together.', 'What can we build together?'),
  _f('Momo is sick', ['Momo has a tummy ache.', 'She stays in bed all day.', 'Pip draws her a get-well card.'], ['🛏️', '💌'], 'How does Momo feel?', [_s, _su, _p], 0, 'Her tummy hurts.', 'Make a card for someone.'),
  _d('The moon cake', ['Grandma bakes a round cake.', 'It looks like the full moon.', 'They eat it under the stars.'], ['🎂', '🌕'], 'What shape was the cake?', ['⚪', '🔺', '⬛'], 0, 'Like the full moon.', 'Find round things in your house.'),
  _d('Hopping race', ['Pip hops ten times.', 'Momo crawls ten steps.', 'They both finish and cheer!'], ['🐸', '🐢'], 'How many times did Pip hop?', ['txt:10', 'txt:3', 'txt:6'], 0, 'Count up to...', 'Hop ten times together!'),
  _f('Duck’s lost egg', ['Duck cannot find her egg.', 'Everyone looks in the reeds.', 'Momo finds it safe and warm!'], ['🥚', '🦆'], 'How does Duck feel at the end?', [_h, _c, _sc], 0, 'Her egg is safe!', 'How do you help a friend who lost something?'),
  _d('Mud pies', ['Momo and Sol make mud pies.', 'They decorate them with leaves.', 'Yuck, not for eating!'], ['🟫', '🍃'], 'What did they decorate the pies with?', ['🍃', '🍓', '🍫'], 0, 'They fall from trees.', 'What is fun about messy play?'),
  _d('The sleepy snail', ['Sol is very sleepy.', 'He curls up in his shell.', 'Goodnight, Sol!'], ['🐌', '🌙'], 'Where did Sol sleep?', ['🐚', '🛏️', '🌳'], 0, 'It is on his back.', 'Where do you like to sleep?'),
  _f('Pip’s big win', ['Pip enters the jumping contest.', 'He jumps the highest!', 'He gets a shiny medal.'], ['🏅', '🐸'], 'How does Pip feel?', [_p, _s, _sl], 0, 'He won a medal!', 'What are you good at?'),
  _d('The picnic ants', ['Ants march to the picnic.', 'They carry away a crumb.', 'Momo shares a little more.'], ['🐜', '🧺'], 'Who came to the picnic?', ['🐜', '🐘', '🐟'], 0, 'They are tiny.', 'How many legs does an ant have?'),
  _d('Washing day', ['Grandma washes the clothes.', 'Momo hangs them in the sun.', 'The wind dries them fast.'], ['🧺', '☀️'], 'What dried the clothes?', ['💨', '🌧️', '❄️'], 0, 'Whoosh!', 'Help hang up the washing.'),
  _f('Sol is left out', ['The others play tag.', 'Sol is too slow to catch anyone.', 'Momo says, "Let’s play a slow game!"'], ['🐌', '🏃'], 'How did Sol feel at first?', [_s, _h, _p], 0, 'He could not join in.', 'How can we include everyone?'),
  _d('The lighthouse', ['Momo sees a tall tower by the sea.', 'Its light spins round at night.', 'It helps boats find their way.'], ['🗼', '⛵'], 'What does the lighthouse help?', ['⛵', '🐦', '🚗'], 0, 'They sail on the sea.', 'What helps you find your way home?'),
  _d('Pip’s puddle boat', ['Pip folds a paper boat.', 'He floats it on a puddle.', 'It sails across!'], ['⛵', '💧'], 'What was the boat made of?', ['📄', '🪨', '🧱'], 0, 'He folded it.', 'Fold a paper boat together.'),
  _f('Too much noise', ['Everyone sings very loudly.', 'Grandma covers her ears.', 'They sing softly instead.'], ['🎵', '🐢'], 'How did Grandma feel with the noise?', [_c, _h, _sl], 0, 'She covered her ears.', 'When should we use quiet voices?'),
  _d('The giant pumpkin', ['A pumpkin grows and grows.', 'It is bigger than Momo!', 'Everyone helps roll it home.'], ['🎃', '🐢'], 'What was bigger than Momo?', ['🎃', '🍒', '🐜'], 0, 'It is orange.', 'What is bigger than you?'),
  _d('Breakfast in bed', ['It is Grandma’s birthday.', 'Momo makes toast and tea.', 'She carries it to Grandma’s bed.'], ['🍞', '☕'], 'Whose birthday was it?', ['🐢', '🐸', '🦆'], 0, 'She is very old and wise.', 'How do you celebrate birthdays?'),
  _f('Pip’s nightmare', ['Pip has a bad dream.', 'He wakes up crying.', 'Momo sings him a soft song.'], ['🌙', '🐸'], 'How did Pip feel when he woke up?', [_sc, _p, _h], 0, 'He was crying.', 'What helps after a bad dream?'),
  _d('The ladybird', ['A ladybird lands on Momo.', 'It has seven spots.', 'Then it flies away.'], ['🐞', '🐢'], 'How many spots did it have?', ['txt:7', 'txt:2', 'txt:10'], 0, 'Count the spots.', 'Look for bugs in the garden.'),
  _d('Building a snowman', ['Snow falls all night.', 'Momo rolls a big snowball.', 'Pip adds a carrot nose.'], ['⛄', '🥕'], 'What was the nose made of?', ['🥕', '🍌', '🪨'], 0, 'It is orange and crunchy.', 'What would your snowman wear?'),
  _f('Sharing the crayons', ['Sol has only one crayon.', 'Duck has lots.', 'Duck shares half with Sol.'], ['🖍️', '🦆'], 'How does Sol feel?', [_h, _c, _sc], 0, 'Now he can draw.', 'What can you share today?'),
  _d('The noisy morning', ['The rooster crows.', 'Cock-a-doodle-doo!', 'Everyone wakes up.'], ['🐓', '☀️'], 'Who woke everyone up?', ['🐓', '🦉', '🐟'], 0, 'Cock-a-doodle-doo!', 'What sounds do you hear in the morning?'),
  _d('Momo’s garden', ['Momo plants carrot seeds.', 'She waters them every day.', 'Weeks later she pulls up carrots!'], ['🥕', '🌱'], 'What did Momo grow?', ['🥕', '🍕', '🎈'], 0, 'They are orange.', 'Plant a seed in a cup.'),
  _f('The surprise visit', ['There is a knock at the door.', 'It is Momo’s cousin from far away!', 'Momo jumps for joy.'], ['🚪', '🐢'], 'How does Momo feel?', [_su, _s, _sl], 0, 'She jumped for joy.', 'Who would you love to visit?'),
  _d('Hide the acorns', ['A squirrel hides acorns.', 'It digs little holes.', 'Later it cannot remember where!'], ['🐿️', '🌰'], 'What did the squirrel hide?', ['🌰', '🍎', '🔑'], 0, 'Squirrels love them.', 'Play a hiding game.'),
  _d('Bubble trouble', ['Pip pours too much soap in the bath.', 'Bubbles fill the room!', 'Grandma laughs and helps clean up.'], ['🫧', '🛁'], 'What filled the room?', ['🫧', '🍂', '🎈'], 0, 'Pop, pop!', 'What happens with too much soap?'),
  _f('Sol’s hard day', ['Sol’s tower falls.', 'His drawing tears.', 'Momo says, "Tomorrow is a new day."'], ['🐌', '🌅'], 'How did Sol feel?', [_s, _h, _p], 0, 'Lots went wrong.', 'What helps on a hard day?'),
  _d('The magic seed', ['Pip plants a tiny seed.', 'It grows into a giant bean plant.', 'It reaches the clouds!'], ['🌱', '☁️'], 'How tall did it grow?', ['☁️', '🐜', '🪑'], 0, 'Up to the sky.', 'What would you find at the top?'),
  _d('Grandma’s glasses again', ['Grandma cannot read her book.', 'Her glasses are missing.', 'Momo finds them in the fridge!'], ['👓', '🧊'], 'Where were the glasses?', ['🧊', '🛏️', '🌳'], 0, 'Somewhere cold!', 'Where do things get lost at home?'),
  _f('First day at swim club', ['Duck goes to swim club.', 'She does not know anyone.', 'A friendly goose says hello.'], ['🦆', '🏊'], 'How did Duck feel at first?', [_sc, _p, _c], 0, 'She did not know anyone.', 'How do you make new friends?'),
  _d('Rainbow soup', ['Grandma makes soup.', 'She adds red, orange and green vegetables.', 'It looks like a rainbow!'], ['🍲', '🌈'], 'What did Grandma make?', ['🍲', '🍰', '🍦'], 0, 'You eat it with a spoon.', 'How many colours can you eat today?'),
  _d('The snail mail', ['Momo writes to her cousin.', 'Sol carries the letter.', 'It takes a very long time!'], ['💌', '🐌'], 'Who carried the letter?', ['🐌', '🦅', '🚀'], 0, 'He is very slow.', 'Who would you write a letter to?'),
  _f('Pip tells the truth', ['Pip breaks a cup.', 'He tells Grandma what happened.', 'Grandma says, "Thank you for telling me."'], ['☕', '🐸'], 'How does Pip feel at the end?', [_p, _sc, _c], 0, 'He was brave and honest.', 'Why is telling the truth important?'),
  _d('Shadow puppets', ['Grandma shines a lamp.', 'Momo makes a bird shape with her hands.', 'A shadow bird flies on the wall!'], ['💡', '🐦'], 'What shadow did Momo make?', ['🐦', '🐟', '🐘'], 0, 'It flies.', 'Make shadow puppets together.'),
  _d('Ice-cream day', ['It is a hot day.', 'Momo gets a strawberry ice cream.', 'It melts down her hand!'], ['🍦', '☀️'], 'Why did it melt?', ['☀️', '❄️', '🌧️'], 0, 'It was a hot day.', 'What melts in the sun?'),
  _f('The kind stranger', ['Momo drops her apples.', 'A kind hedgehog helps pick them up.', 'Momo gives him one to say thanks.'], ['apple', '🦔'], 'How does Momo feel?', [_h, _c, _sc], 0, 'Someone helped her.', 'How can you be a helper today?'),
  _d('Five little frogs', ['Five frogs sit on a log.', 'One jumps into the pond.', 'Now there are four.'], ['🐸', '🪵'], 'How many frogs are left?', ['txt:4', 'txt:5', 'txt:2'], 0, 'Five take away one.', 'Act it out with toys!'),
  _d('The stuck boot', ['Pip’s boot sticks in the mud.', 'He pulls and pulls.', 'Pop! Out it comes.'], ['👢', '🟫'], 'What was stuck?', ['👢', '🧢', '🧤'], 0, 'He wears it on his foot.', 'Have you ever got stuck in mud?'),
  _f('Duck’s singing show', ['Duck sings for her friends.', 'She forgets the words.', 'Everyone sings along to help!'], ['🎤', '🦆'], 'How did Duck feel when she forgot?', [_sc, _h, _sl], 0, 'She forgot the words in front of everyone.', 'How can friends help when we forget?'),
  _d('Sorting socks', ['A pile of socks needs sorting.', 'Momo finds the pairs.', 'Red with red, blue with blue.'], ['🧦', '🧺'], 'What did Momo sort?', ['🧦', '🍎', '🧱'], 0, 'We wear them on our feet.', 'Sort socks into pairs together.'),
  _d('The firefly lantern', ['Fireflies glow in a jar.', 'Momo looks for a minute.', 'Then she lets them fly free.'], ['✨', '🫙'], 'What did Momo do with the fireflies?', ['🕊️', '🍽️', '🎁'], 0, 'She let them go.', 'Why should we let bugs go free?'),
  _f('Pip’s big feelings', ['Pip wants to stay at the park.', 'It is time to go home.', 'He takes three deep breaths.'], ['🛝', '🌬️'], 'How did Pip feel about leaving?', [_c, _h, _su], 0, 'He did not want to go.', 'Take three deep breaths together.'),
  _d('The lost mitten', ['Momo finds one red mitten.', 'Inside is a little mouse!', 'It is using it as a bed.'], ['🧤', '🐭'], 'Who was in the mitten?', ['🐭', '🐘', '🐸'], 0, 'Squeak!', 'Where would you sleep if you were tiny?'),
  _d('Grandma’s garden gnome', ['Grandma has a garden gnome.', 'Its hat is red and pointy.', 'Momo says good morning to it every day.'], ['🧙', '🌷'], 'What colour is the gnome’s hat?', ['🔴', '🔵', '🟡'], 0, 'Like a strawberry.', 'What do you say good morning to?'),
  _f('The broken promise', ['Sol promised to play with Pip.', 'Sol forgot and played with Duck.', 'Pip sat alone on the log.'], ['🐌', '🪵'], 'How did Pip feel?', [_s, _p, _su], 0, 'His friend forgot.', 'Why is keeping promises important?'),
  _d('Making music', ['Momo fills glasses with water.', 'She taps them with a spoon.', 'Each one makes a different note!'], ['🥛', '🎵'], 'What did she tap with?', ['🥄', '🪵', '✋'], 0, 'You eat soup with it.', 'Try making water-glass music.'),
  _d('The tall giraffe visit', ['A giraffe visits the pond.', 'She drinks with her long neck.', 'Pip climbs up to say hello!'], ['🦒', '🌊'], 'Who visited?', ['🦒', '🦛', '🐊'], 0, 'She has a very long neck.', 'What animal would you like to meet?'),
  _f('Momo learns to whistle', ['Momo tries to whistle.', 'Only air comes out.', 'She practises every day until she can!'], ['🎵', '🐢'], 'How does Momo feel at the end?', [_p, _s, _c], 0, 'She practised and did it.', 'What are you practising?'),
  _d('Goodnight, pond', ['The sun goes down.', 'The frogs croak a goodnight song.', 'Momo closes her eyes. Sweet dreams!'], ['🌅', '🐸'], 'What happened to the sun?', ['🌅', '☀️', '🌈'], 0, 'It went down.', 'Say goodnight to things in your room.'),
];

const extraScenarios = <Scenario>[
  Scenario('You get a sticker for being kind.', '⭐', _p),
  Scenario('Your tower falls down again and again.', '🧱', _c),
  Scenario('You stay up very, very late.', '🥱', _sl),
  Scenario('A dog runs at you barking.', '🐕', _sc),
  Scenario('There is a big cake with your name on it!', '🎂', _su),
  Scenario('Your friend will not let you have a turn.', '🛝', _c),
  Scenario('You lose your favourite teddy.', '🧸', _s),
  Scenario('You climb to the top of the climbing frame.', '🧗', _p),
  Scenario('You play with bubbles in the garden.', '🫧', _h),
  Scenario('Your pet fish is poorly.', '🐟', _s),
  Scenario('You hear a strange noise in the dark.', '🌑', _sc),
  Scenario('Grandpa gives you a surprise present.', '🎁', _su),
  Scenario('You read a book all by yourself.', '📖', _p),
  Scenario('Your painting gets rained on.', '🎨', _s),
  Scenario('You go on a train ride.', '🚂', _h),
  Scenario('Someone says unkind words to you.', '💬', _s),
  Scenario('You have had a long walk.', '🚶', _sl),
  Scenario('You go to the doctor for an injection.', '💉', _sc),
  Scenario('Snow falls for the first time this year!', '❄️', _su),
  Scenario('You count all the way to twenty.', '🔢', _p),
  Scenario('You dance at a party.', '💃', _h),
  Scenario('Your sandcastle is knocked over on purpose.', '🏰', _c),
  Scenario('Your friend is moving to a new school.', '🏫', _s),
  Scenario('You find a frog in your shoe!', '🐸', _su),
  Scenario('You help a friend who fell over.', '🤝', _p),
  Scenario('You eat your favourite dinner.', '🍝', _h),
  Scenario('You must wait a long time in a queue.', '⏳', _c),
  Scenario('You see a big spider web.', '🕸️', _sc),
  Scenario('You stay at Grandma’s house.', '🏡', _h),
  Scenario('You finish your first swimming lesson.', '🏊', _p),
  Scenario('The car ride is very long.', '🚗', _sl),
  Scenario('Your sibling breaks your new toy.', '🧩', _c),
  Scenario('A shooting star crosses the sky!', '🌠', _su),
  Scenario('Your balloon pops with a bang.', '🎈', _sc),
  Scenario('Your friend gives you a hug.', '🤗', _h),
  Scenario('You can’t find your mum in the park.', '🌳', _sc),
  Scenario('You tidy your whole room.', '🧺', _p),
  Scenario('You miss the birthday party.', '🎉', _s),
  Scenario('You open your eyes after a long nap.', '🛏️', _sl),
  Scenario('You win a race at sports day.', '🏅', _p),
];

/// Every story, in level order: 120 earlier stories, then 60 more.
final storyBook = <Story>[...allStories, ...extraStories];

/// Every feelings scenario.
const feelingsBook = <Scenario>[...scenarios, ...extraScenarios];

// Keeps the base story class import used.
typedef StoryT = Story;
