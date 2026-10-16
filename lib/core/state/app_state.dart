import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../content/levels.dart';
import '../../learning/mastery.dart';
import '../theme.dart';
import 'models.dart';

/// Preview builds unlock every level so families and testers can try
/// everything before store subscriptions are set up.
const kPreviewUnlock = bool.fromEnvironment('PREVIEW_UNLOCK');

/// All app data. Everything is stored on this device only.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  static const _key = 'little_explorers_v1';
  static const maxProfiles = 4;

  Settings settings = Settings();
  final List<Profile> profiles = [];
  String? currentId;
  bool plus = false;
  bool plusTrial = false;
  int? plusSince;
  String plusProduct = '';

  SharedPreferences? _prefs;
  Timer? _ticker;
  bool _foreground = true;
  bool childMode = true; // false while in the grown-ups area
  DateTime Function() clock = DateTime.now;

  Profile? get current {
    for (final p in profiles) {
      if (p.id == currentId) return p;
    }
    return profiles.isEmpty ? null : profiles.first;
  }

  bool get isUnlockedAll => plus || kPreviewUnlock;

  // ------------------------------------------------------------ persistence

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_key);
      if (raw != null) _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Could not load saved data: $e');
    }
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) => _tick(15));
  }

  void _fromJson(Map<String, dynamic> j) {
    settings = Settings.fromJson(Map<String, dynamic>.from(j['settings'] as Map? ?? {}));
    profiles
      ..clear()
      ..addAll((j['profiles'] as List? ?? []).map((e) => Profile.fromJson(Map<String, dynamic>.from(e as Map))));
    currentId = j['current'] as String?;
    plus = j['plus'] as bool? ?? false;
    plusTrial = j['trial'] as bool? ?? false;
    plusSince = j['since'] as int?;
    plusProduct = j['product'] as String? ?? '';
  }

  Map<String, dynamic> toJson() => {
        'v': 1,
        'settings': settings.toJson(),
        'profiles': profiles.map((p) => p.toJson()).toList(),
        'current': currentId,
        'plus': plus,
        'trial': plusTrial,
        'since': plusSince,
        'product': plusProduct,
      };

  Future<void> save() async {
    notifyListeners();
    try {
      await _prefs?.setString(_key, jsonEncode(toJson()));
    } catch (e) {
      debugPrint('Could not save: $e');
    }
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Future<void> deleteAll() async {
    profiles.clear();
    currentId = null;
    settings = Settings();
    plus = false;
    plusTrial = false;
    plusSince = null;
    plusProduct = '';
    await _prefs?.remove(_key);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) save();
  }

  // ------------------------------------------------------------ time

  void _tick(int seconds) {
    final p = current;
    if (p == null || !_foreground || !childMode) return;
    final k = dayKey(clock());
    p.minutes[k] = (p.minutes[k] ?? 0) + seconds / 60;
    // Keep 60 days of history.
    if (p.minutes.length > 60) {
      final keys = p.minutes.keys.toList()..sort();
      for (final old in keys.take(p.minutes.length - 60)) {
        p.minutes.remove(old);
      }
    }
    save();
  }

  double minutesOn(Profile p, DateTime d) => p.minutes[dayKey(d)] ?? 0;
  double get minutesToday => current == null ? 0 : minutesOn(current!, clock());

  int get allowedToday {
    final p = current;
    final extra = (p != null && p.extraDate == dayKey(clock())) ? p.extraMinutes : 0;
    return settings.dailyLimit + extra;
  }

  bool get isBedtime {
    if (!settings.bedtimeLock) return false;
    final h = clock().hour;
    return h >= 19 || h < 7;
  }

  bool get timeUp => minutesToday >= allowedToday;

  void grantExtraTime(int minutes) {
    final p = current;
    if (p == null) return;
    final today = dayKey(clock());
    if (p.extraDate != today) {
      p.extraDate = today;
      p.extraMinutes = 0;
    }
    p.extraMinutes += minutes;
    // Extra time also lifts tonight's bedtime lock for this child's session.
    _bedtimeOverride = clock().add(Duration(minutes: minutes));
    save();
  }

  DateTime? _bedtimeOverride;
  bool get bedtimeOverridden => _bedtimeOverride != null && clock().isBefore(_bedtimeOverride!);
  bool get restNow => timeUp || (isBedtime && !bedtimeOverridden);

  // ------------------------------------------------------------ profiles

  Profile addProfile({required int age, required Color color, required String hat}) {
    final id = '${clock().millisecondsSinceEpoch}${Random().nextInt(999)}';
    final p = Profile(
        id: id, name: 'Explorer ${profiles.length + 1}', age: age, color: color.toARGB32(), hat: hat);
    profiles.add(p);
    currentId = id;
    save();
    return p;
  }

  void selectProfile(String id) {
    currentId = id;
    save();
  }

  void updateProfile(Profile p, void Function(Profile) f) {
    f(p);
    save();
  }

  void removeProfile(String id) {
    profiles.removeWhere((p) => p.id == id);
    if (currentId == id) currentId = profiles.isEmpty ? null : profiles.first.id;
    save();
  }

  void updateSettings(void Function(Settings) f) {
    f(settings);
    save();
  }

  // ------------------------------------------------------------ learning

  SkillRecord? skill(String id) => current?.skills[id];

  void recordAnswer(String skillId, {required bool ok, bool hint = false}) {
    final p = current;
    if (p == null) return;
    final r = p.skills.putIfAbsent(skillId, SkillRecord.new);
    MasteryEngine.record(r, ok: ok, hint: hint, now: clock());
    p.recentSkills.remove(skillId);
    p.recentSkills.insert(0, skillId);
    if (p.recentSkills.length > 12) p.recentSkills.removeLast();
    // Saved at the end of the level, to keep writes small.
  }

  /// Records a finished level. Rewards are predictable: 3 stars + 1 sticker.
  void completeLevel(Level level, {String? learned}) {
    final p = current;
    if (p == null) return;
    final first = !p.levelStars.containsKey(level.id);
    p.levelStars[level.id] = 3;
    p.stars += 3;
    if (first) p.stickers.add(level.id);
    if (learned != null) {
      _resetAdventureIfNewDay(p);
      if (!p.learnedToday.contains(learned)) p.learnedToday.add(learned);
    }
    save();
  }

  bool isDone(Level l) => current?.levelStars.containsKey(l.id) ?? false;

  /// Levels open in order. Paid levels are simply not offered to the child.
  /// Levels open in order, and only within the family's plan. Levels outside
  /// the plan just show a padlock, exactly like levels not reached yet: the
  /// child never sees a price or an "ask your parents" prompt.
  bool isOpen(Level l) => isInPlan(l) && (l.number == 1 || isDone(allLevels[l.world]![l.number - 2]));
  bool isInPlan(Level l) => isUnlockedAll || l.number <= freeLevelsPerWorld;

  /// Levels the child can play now or has played.
  List<Level> visibleLevels(WorldId w) => allLevels[w]!.where((l) => isInPlan(l) || isDone(l)).toList();

  Level currentLevel(WorldId w) {
    final ls = visibleLevels(w);
    for (final l in ls) {
      if (!isDone(l)) return l;
    }
    return ls.last;
  }

  int doneCount(WorldId w) => allLevels[w]!.where(isDone).length;

  // ------------------------------------------------------------ adventure

  List<WorldId> get adventureWorlds => [
        WorldId.alpha,
        WorldId.math,
        WorldId.story,
        if (settings.moveBreaks) WorldId.move,
      ];

  int get roundsPerStep => switch (settings.adventureMinutes) { 10 => 3, 20 => 5, _ => 4 };

  void _resetAdventureIfNewDay(Profile p) {
    final today = dayKey(clock());
    if (p.advDate != today) {
      p.advDate = today;
      p.advStep = 0;
      p.learnedToday.clear();
    }
  }

  int get adventureStep {
    final p = current;
    if (p == null) return 0;
    _resetAdventureIfNewDay(p);
    return p.advStep;
  }

  bool get adventureDone => adventureStep >= adventureWorlds.length;

  void advanceAdventure() {
    final p = current;
    if (p == null) return;
    _resetAdventureIfNewDay(p);
    p.advStep++;
    save();
  }

  void restartAdventure() {
    final p = current;
    if (p == null) return;
    p.advStep = 0;
    save();
  }

  /// Picks today's level for a world: a due review first, else the next
  /// level. The daily adventure is free, so any level can appear here.
  Level adventureLevel(WorldId w) {
    final p = current;
    final now = clock();
    if (p != null) {
      for (final l in allLevels[w]!) {
        final r = p.skills[l.skill];
        if (isDone(l) && r != null && MasteryEngine.isDue(r, now)) return l;
      }
    }
    for (final l in allLevels[w]!) {
      if (!isDone(l)) return l;
    }
    return allLevels[w]!.last;
  }

  // ------------------------------------------------------------ plan

  void setPlus({required bool active, bool trial = false, String product = ''}) {
    final wasPlus = plus;
    plus = active;
    plusTrial = active && trial;
    plusProduct = product;
    if (active && !wasPlus) plusSince = clock().millisecondsSinceEpoch;
    if (!active) plusSince = null;
    save();
  }

  DateTime? get trialEnds =>
      plusTrial && plusSince != null ? DateTime.fromMillisecondsSinceEpoch(plusSince!).add(const Duration(days: 7)) : null;
}
