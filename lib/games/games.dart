import 'package:flutter/widgets.dart';

import '../content/lab_move.dart';
import '../content/levels.dart';
import '../content/stories_more.dart';
import 'game_shell.dart';
import 'letters_games.dart';
import 'math_games.dart';
import 'new_games.dart';
import 'other_games.dart';
import 'shape_games.dart';

/// How many rounds a level has. [standard] is 5 normally, or the adventure
/// setting inside Today's Adventure.
int roundsFor(Level l, int standard) => switch (l.type) {
      GameType.trace => 2,
      GameType.story => 1,
      GameType.move => (l.p['moves'] as List).length,
      GameType.shapeSort => standard >= 5 ? 2 : 1,
      GameType.lab => 4,
      GameType.feelings => 4,
      _ => standard,
    };

/// A short label for the Rest screen ("Today you learned").
String learnedLabel(Level l) => switch (l.type) {
      GameType.story => allStories[l.p['story'] as int].feelings ? 'How Momo felt' : 'Momo’s story',
      GameType.feelings => 'Talking about feelings',
      GameType.move => moves[(l.p['moves'] as List).first as int].name,
      _ => l.title,
    };

Widget buildGame(Level level, GameApi api, String coach) {
  final k = ValueKey('${level.id}-${api.round}');
  return switch (level.type) {
    GameType.letterSound => LetterSoundGame(key: k, level: level, api: api, coach: coach),
    GameType.trace => TraceGame(key: k, level: level, api: api, coach: coach),
    GameType.blend => BlendGame(key: k, level: level, api: api, coach: coach),
    GameType.caseMatch => CaseMatchGame(key: k, level: level, api: api, coach: coach),
    GameType.sightWord => SightWordGame(key: k, level: level, api: api, coach: coach),
    GameType.rhyme => RhymeGame(key: k, level: level, api: api, coach: coach),
    GameType.count => CountGame(key: k, level: level, api: api, coach: coach),
    GameType.numeral => NumeralGame(key: k, level: level, api: api, coach: coach),
    GameType.quickLook => QuickLookGame(key: k, level: level, api: api, coach: coach),
    GameType.compare => CompareGame(key: k, level: level, api: api, coach: coach),
    GameType.makeN => MakeNGame(key: k, level: level, api: api, coach: coach),
    GameType.addSub => AddSubGame(key: k, level: level, api: api, coach: coach),
    GameType.numberOrder => NumberOrderGame(key: k, level: level, api: api, coach: coach),
    GameType.compareNumbers => CompareNumbersGame(key: k, level: level, api: api, coach: coach),
    GameType.shapeSort => ShapeSortGame(key: k, level: level, api: api, coach: coach),
    GameType.pattern => PatternGame(key: k, level: level, api: api, coach: coach),
    GameType.shapeFind => ShapeFindGame(key: k, level: level, api: api, coach: coach),
    GameType.size => SizeGame(key: k, level: level, api: api, coach: coach),
    GameType.solid => SolidGame(key: k, level: level, api: api, coach: coach),
    GameType.position => PositionGame(key: k, level: level, api: api, coach: coach),
    GameType.shapeCount => ShapeCountGame(key: k, level: level, api: api, coach: coach),
    GameType.story => StoryGame(key: k, level: level, api: api, coach: coach),
    GameType.feelings => FeelingsGame(key: k, level: level, api: api, coach: coach),
    GameType.lab => LabGame(key: k, level: level, api: api, coach: coach),
    GameType.move => MoveGame(key: k, level: level, api: api, coach: coach),
  };
}
