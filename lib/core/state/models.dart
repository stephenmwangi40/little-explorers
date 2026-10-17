import '../../learning/mastery.dart';

class Settings {
  int adventureMinutes; // 15 / 30 / 45 / 60
  int dailyLimit; // 30 / 45 / 60 / 90
  bool bedtimeLock;
  bool moveBreaks;
  String english; // US / UK / AU
  bool slowNarration;
  bool narration;
  bool captions;
  bool reduceMotion;
  bool leftHanded;
  bool sound;
  bool music;
  bool cloudBackup;
  bool reminder; // daily reminder for grown-ups (off by default)
  int reminderHour; // 24-hour clock

  Settings({
    this.adventureMinutes = 45,
    this.dailyLimit = 60,
    this.bedtimeLock = true,
    this.moveBreaks = true,
    this.english = 'US',
    this.slowNarration = false,
    this.narration = true,
    this.captions = true,
    this.reduceMotion = false,
    this.leftHanded = false,
    this.sound = true,
    this.music = true,
    this.cloudBackup = false,
    this.reminder = false,
    this.reminderHour = 17,
  });

  Map<String, dynamic> toJson() => {
        'adv': adventureMinutes,
        'lim': dailyLimit,
        'bed': bedtimeLock,
        'mb': moveBreaks,
        'en': english,
        'slow': slowNarration,
        'nar': narration,
        'cap': captions,
        'rm': reduceMotion,
        'lh': leftHanded,
        'snd': sound,
        'mus': music,
        'cb': cloudBackup,
        'rem': reminder,
        'remH': reminderHour,
      };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
        adventureMinutes: j['adv'] as int? ?? 45,
        dailyLimit: j['lim'] as int? ?? 60,
        bedtimeLock: j['bed'] as bool? ?? true,
        moveBreaks: j['mb'] as bool? ?? true,
        english: j['en'] as String? ?? 'US',
        slowNarration: j['slow'] as bool? ?? false,
        narration: j['nar'] as bool? ?? true,
        captions: j['cap'] as bool? ?? true,
        reduceMotion: j['rm'] as bool? ?? false,
        leftHanded: j['lh'] as bool? ?? false,
        sound: j['snd'] as bool? ?? true,
        music: j['mus'] as bool? ?? true,
        cloudBackup: false, // cloud backup is never on without a parent account
        reminder: j['rem'] as bool? ?? false,
        reminderHour: j['remH'] as int? ?? 17,
      );
}

/// A child profile. Stores only what is needed: an optional nickname, an
/// age band, an avatar and learning progress. No name, birthday or photo.
class Profile {
  final String id;
  String name;
  int age;
  int color;
  String hat;
  int stars;
  Map<String, int> levelStars;
  List<String> stickers; // level ids, in the order earned
  Map<String, SkillRecord> skills;
  Map<String, double> minutes; // yyyy-mm-dd -> minutes
  String advDate;
  int advStep;
  List<String> learnedToday;
  String extraDate;
  int extraMinutes;
  List<String> recentSkills;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.color,
    required this.hat,
    this.stars = 0,
    Map<String, int>? levelStars,
    List<String>? stickers,
    Map<String, SkillRecord>? skills,
    Map<String, double>? minutes,
    this.advDate = '',
    this.advStep = 0,
    List<String>? learnedToday,
    this.extraDate = '',
    this.extraMinutes = 0,
    List<String>? recentSkills,
  })  : levelStars = levelStars ?? {},
        stickers = stickers ?? [],
        skills = skills ?? {},
        minutes = minutes ?? {},
        learnedToday = learnedToday ?? [],
        recentSkills = recentSkills ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'color': color,
        'hat': hat,
        'stars': stars,
        'ls': levelStars,
        'st': stickers,
        'sk': skills.map((k, v) => MapEntry(k, v.toJson())),
        'min': minutes,
        'ad': advDate,
        'as': advStep,
        'lt': learnedToday,
        'xd': extraDate,
        'xm': extraMinutes,
        'rs': recentSkills,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'Explorer',
        age: j['age'] as int? ?? 4,
        color: j['color'] as int? ?? 0xFFFF7A59,
        hat: j['hat'] as String? ?? 'cap',
        stars: j['stars'] as int? ?? 0,
        levelStars: Map<String, int>.from(j['ls'] as Map? ?? {}),
        stickers: List<String>.from(j['st'] as List? ?? []),
        skills: (j['sk'] as Map? ?? {})
            .map((k, v) => MapEntry(k as String, SkillRecord.fromJson(Map<String, dynamic>.from(v as Map)))),
        minutes: (j['min'] as Map? ?? {}).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        advDate: j['ad'] as String? ?? '',
        advStep: j['as'] as int? ?? 0,
        learnedToday: List<String>.from(j['lt'] as List? ?? []),
        extraDate: j['xd'] as String? ?? '',
        extraMinutes: j['xm'] as int? ?? 0,
        recentSkills: List<String>.from(j['rs'] as List? ?? []),
      );
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
